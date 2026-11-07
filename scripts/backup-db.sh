#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated PostgreSQL Database Backup with Gzip & 7-Day Retention
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

BACKUP_DIR="$ROOT_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DB_USER="${POSTGRES_USER:-clouduser}"
DB_NAME="${POSTGRES_DB:-cloudappdb}"
COMPOSE_FILE="docker-compose.prod.yml"

mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/db_${DB_NAME}_${TIMESTAMP}.sql.gz"

echo "================================================="
echo "💾 Starting Database Backup"
echo "Target DB: $DB_NAME"
echo "Backup File: $BACKUP_FILE"
echo "Timestamp: $(date -u)"
echo "================================================="

# 1. Verify DB container is running
if ! docker compose -f "$COMPOSE_FILE" ps --services --filter "status=running" | grep -q "^db$"; then
    echo "❌ Error: Database service is not running."
    exit 1
fi

# 2. Execute pg_dump inside container and pipe to gzip
echo "1. Exporting and compressing database schema & data..."
docker compose -f "$COMPOSE_FILE" exec -T db \
    pg_dump -U "$DB_USER" -d "$DB_NAME" --clean --if-exists | gzip -9 > "$BACKUP_FILE"

# 3. Generate SHA256 Checksum
echo "2. Generating checksum verification..."
if command -v sha256sum &> /dev/null; then
    sha256sum "$BACKUP_FILE" > "${BACKUP_FILE}.sha256"
elif command -v shasum &> /dev/null; then
    shasum -a 256 "$BACKUP_FILE" > "${BACKUP_FILE}.sha256"
fi

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "✅ Backup successfully created (Size: $BACKUP_SIZE)"

# 4. Prune backups older than 7 days
echo "3. Enforcing 7-day backup retention policy..."
find "$BACKUP_DIR" -type f -name "db_*.sql.gz*" -mtime +7 -exec rm -f {} \;

echo "================================================="
echo "🎉 Database Backup & Rotation Complete!"
echo "================================================="
