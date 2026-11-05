#!/usr/bin/env bash
# ==============================================================================
# Script to install and configure PostgreSQL 16 on VM 2 (Database Server)
# Target OS: Ubuntu 22.04 LTS / 24.04 LTS
# ==============================================================================

set -euo pipefail

DB_NAME="${DB_NAME:-taskdb}"
DB_USER="${DB_USER:-taskuser}"
DB_PASSWORD="${DB_PASSWORD:-SecureTaskPass123!}"
APP_SUBNET_CIDR="${APP_SUBNET_CIDR:-10.0.1.0/24}"

echo ">>> [1/5] Updating packages and installing PostgreSQL..."
sudo apt-get update -y
sudo apt-get install -y postgresql postgresql-contrib

echo ">>> [2/5] Configuring PostgreSQL to listen on all interfaces (secured by NSG)..."
PG_CONF=$(sudo -u postgres psql -t -P format=unaligned -c 'show config_file;')
PG_DIR=$(dirname "$PG_CONF")

# Listen on all IP addresses (network security group restricts who can connect)
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" "$PG_CONF"
sudo sed -i "s/listen_addresses = 'localhost'/listen_addresses = '*'/g" "$PG_CONF"

echo ">>> [3/5] Updating pg_hba.conf to allow connection from Application Subnet ($APP_SUBNET_CIDR)..."
PG_HBA="$PG_DIR/pg_hba.conf"
if ! grep -q "$APP_SUBNET_CIDR" "$PG_HBA"; then
    echo "# Allow connections from Application Subnet VM1" | sudo tee -a "$PG_HBA"
    echo "host    $DB_NAME     $DB_USER     $APP_SUBNET_CIDR            scram-sha-256" | sudo tee -a "$PG_HBA"
    echo "host    $DB_NAME     $DB_USER     $APP_SUBNET_CIDR            md5" | sudo tee -a "$PG_HBA"
fi

echo ">>> [4/5] Creating Database and User..."
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
      CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASSWORD';
   ELSE
      ALTER ROLE $DB_USER WITH PASSWORD '$DB_PASSWORD';
   END IF;
END
\$\$;

SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
EOF

echo ">>> [5/5] Initializing Database Schema..."
if [ -f "init.sql" ]; then
    PGPASSWORD="$DB_PASSWORD" psql -h localhost -U "$DB_USER" -d "$DB_NAME" -f init.sql || true
fi

echo ">>> Restarting PostgreSQL service..."
sudo systemctl restart postgresql
sudo systemctl enable postgresql

echo ">>> Verification: Checking PostgreSQL service status..."
sudo systemctl is-active --quiet postgresql && echo "✅ PostgreSQL is running successfully!"

