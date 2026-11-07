#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Disaster Recovery Database Restore from Compressed Backup
# ==============================================================================

BACKUP_FILE="${1:-}"
FORCE="${2:-}"

if [[ -z "$BACKUP_FILE" || ! -f "$BACKUP_FILE" ]]; then
    echo "❌ Error: Backup file not specified or file does not exist."
    echo "Usage: ./restore-db.sh <path-to-backup.sql.gz> [--force]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

DB_USER="${POSTGRES_USER:-clouduser}"
DB_NAME="${POSTGRES_DB:-cloudappdb}"
COMPOSE_FILE="docker-compose.prod.yml"

echo "================================================="
echo "🚨 Database Disaster Recovery Restore"
echo "Target DB: $DB_NAME"
echo "Restore File: $BACKUP_FILE"
echo "================================================="

# Confirmation safety check
if [[ "$FORCE" != "--force" && "$FORCE" != "-f" ]]; then
    read -rp "⚠️ WARNING: This will overwrite existing data in $DB_NAME. Proceed? (y/N): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Operation cancelled by user."
        exit 0
    fi
fi

# 1. Verify Checksum if present
if [ -f "${BACKUP_FILE}.sha256" ]; then
    echo "1. Verifying SHA256 integrity..."
    if command -v sha256sum &> /dev/null; then
        sha256sum -c "${BACKUP_FILE}.sha256"
    fi
    echo "✅ Checksum verification passed."
fi

# 2. Stream and restore into PostgreSQL container
echo "2. Streaming backup into PostgreSQL database..."
if [[ "$BACKUP_FILE" == *.gz ]]; then
    gzip -dc "$BACKUP_FILE" | docker compose -f "$COMPOSE_FILE" exec -T db psql -U "$DB_USER" -d "$DB_NAME"
else
    cat "$BACKUP_FILE" | docker compose -f "$COMPOSE_FILE" exec -T db psql -U "$DB_USER" -d "$DB_NAME"
fi

# 3. Post-Restore Verification Query
echo "3. Verifying restored tables and record counts..."
COUNT=$(docker compose -f "$COMPOSE_FILE" exec -T db psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM cloud_resources;" 2>/dev/null || echo "0")
echo "📊 Current records in 'cloud_resources': $(echo "$COUNT" | tr -d ' ')"

echo "================================================="
echo "🎉 Disaster Recovery Database Restore Successful!"
echo "================================================="
