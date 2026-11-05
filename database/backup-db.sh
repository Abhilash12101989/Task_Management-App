#!/usr/bin/env bash
# ==============================================================================
# Automated Database Backup Script for PostgreSQL
# Can be run via cron (e.g. 0 2 * * * /path/to/backup-db.sh)
# ==============================================================================

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/taskdb}"
DB_NAME="${DB_NAME:-taskdb}"
DB_USER="${DB_USER:-taskuser}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo ">>> Starting PostgreSQL backup at $(date) for database: $DB_NAME"
sudo -u postgres pg_dump "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ -s "$BACKUP_FILE" ]; then
    echo "✅ Backup completed successfully: $BACKUP_FILE (Size: $(du -h "$BACKUP_FILE" | cut -f1))"
else
    echo "❌ Backup file is empty or failed!"
    exit 1
fi

# Cleanup old backups older than retention period
echo ">>> Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "${DB_NAME}_backup_*.sql.gz" -mtime +"$RETENTION_DAYS" -exec rm -f {} \;
echo "✅ Backup process finished."

