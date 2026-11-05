#!/usr/bin/env bash
# ==============================================================================
# Database Restore Script for PostgreSQL
# Usage: ./restore-db.sh /path/to/backup_file.sql.gz
# ==============================================================================

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <backup-file.sql.gz or backup-file.sql>"
    exit 1
fi

BACKUP_FILE="$1"
DB_NAME="${DB_NAME:-taskdb}"
DB_USER="${DB_USER:-taskuser}"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: File not found: $BACKUP_FILE"
    exit 1
fi

echo "⚠️ WARNING: This will overwrite data in database '$DB_NAME' from '$BACKUP_FILE'!"
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

echo ">>> Terminating active connections to $DB_NAME..."
sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" || true

echo ">>> Restoring database..."
if [[ "$BACKUP_FILE" == *.gz ]]; then
    gunzip -c "$BACKUP_FILE" | sudo -u postgres psql -d "$DB_NAME"
else
    sudo -u postgres psql -d "$DB_NAME" < "$BACKUP_FILE"
fi

echo "✅ Database restore completed successfully!"

