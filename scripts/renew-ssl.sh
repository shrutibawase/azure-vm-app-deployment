#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated SSL Certificate Renewal & Nginx Reload
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

echo "================================================="
echo "🔄 Checking for SSL Certificate Renewal"
echo "Timestamp: $(date -u)"
echo "================================================="

# Trigger Certbot Renewal
docker compose -f docker-compose.prod.yml run --rm --entrypoint "certbot renew --no-random-sleep-on-renew" certbot

# Reload Nginx daemon to pick up renewed certificates
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload

echo "✅ SSL certificate check and renewal completed successfully."
