#!/bin/bash
# ==============================================================================
# Cloud-init provisioning script for VM 2 (Database Server)
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo ">>> [1/5] Installing PostgreSQL 16..."
apt-get update -y
apt-get install -y postgresql postgresql-contrib

echo ">>> [2/5] Configuring PostgreSQL listen addresses..."
PG_CONF=$(sudo -u postgres psql -t -P format=unaligned -c 'show config_file;')
PG_DIR=$(dirname "$PG_CONF")

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" "$PG_CONF"
sed -i "s/listen_addresses = 'localhost'/listen_addresses = '*'/g" "$PG_CONF"

echo ">>> [3/5] Configuring pg_hba.conf for Application Subnet (${APP_SUBNET_CIDR})..."
PG_HBA="$PG_DIR/pg_hba.conf"
if ! grep -q "${APP_SUBNET_CIDR}" "$PG_HBA"; then
    echo "# Allow connections from Application Subnet VM1" >> "$PG_HBA"
    echo "host    taskdb     taskuser     ${APP_SUBNET_CIDR}            scram-sha-256" >> "$PG_HBA"
    echo "host    taskdb     taskuser     ${APP_SUBNET_CIDR}            md5" >> "$PG_HBA"
fi

echo ">>> [4/5] Creating Database, User, and Schema..."
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'taskuser') THEN
      CREATE ROLE taskuser WITH LOGIN PASSWORD '${DB_PASSWORD}';
   ELSE
      ALTER ROLE taskuser WITH PASSWORD '${DB_PASSWORD}';
   END IF;
END
\$\$;

SELECT 'CREATE DATABASE taskdb OWNER taskuser'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'taskdb')\gexec

GRANT ALL PRIVILEGES ON DATABASE taskdb TO taskuser;
ALTER DATABASE taskdb OWNER TO taskuser;
EOF

# Initialize tasks table
sudo -u postgres psql -d taskdb <<'EOF'
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(50) DEFAULT 'medium' NOT NULL,
    category VARCHAR(50) DEFAULT 'DevOps' NOT NULL,
    completed BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO taskuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO taskuser;
EOF

echo ">>> [5/5] Enabling and starting PostgreSQL service..."
systemctl restart postgresql
systemctl enable postgresql

# Daily automated backup cron job
mkdir -p /var/backups/taskdb
cat << 'EOF' > /usr/local/bin/backup-taskdb.sh
#!/bin/bash
BACKUP_DIR="/var/backups/taskdb"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
sudo -u postgres pg_dump taskdb | gzip > "$BACKUP_DIR/taskdb_backup_$TIMESTAMP.sql.gz"
find "$BACKUP_DIR" -type f -name "taskdb_backup_*.sql.gz" -mtime +7 -delete
EOF
chmod +x /usr/local/bin/backup-taskdb.sh
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-taskdb.sh") | crontab -

echo "✅ VM 2 database provisioning complete!"

