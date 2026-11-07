#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Zero-Downtime Rolling Deployment for Azure Linux VM
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

COMPOSE_FILE="docker-compose.prod.yml"

echo "================================================="
echo "🚀 Initiating Zero-Downtime Deployment"
echo "Timestamp: $(date -u)"
echo "Directory: $(pwd)"
echo "================================================="

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Error: $COMPOSE_FILE not found in $ROOT_DIR."
    exit 1
fi

# 1. Pull Latest Container Images
echo "1. Pulling latest application & proxy images..."
docker compose -f "$COMPOSE_FILE" pull api nginx || true

# 2. Ensure Database is Healthy
echo "2. Verifying database container..."
docker compose -f "$COMPOSE_FILE" up -d db

# 3. Rolling recreate of application container
echo "3. Starting updated application service..."
docker compose -f "$COMPOSE_FILE" up -d --no-deps api

# 4. Wait for Application Healthcheck
echo "4. Awaiting application health verification..."
MAX_ATTEMPTS=20
ATTEMPT=0
HEALTH_URL="http://localhost:8000/healthz"

until [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]
do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || echo "000")
    if [ "$STATUS" -eq 200 ]; then
        echo "✅ Application healthcheck passed (HTTP 200 OK)!"
        break
    fi
    ATTEMPT=$((ATTEMPT+1))
    echo "⏳ Waiting for healthcheck ($ATTEMPT/$MAX_ATTEMPTS)... Status: $STATUS"
    sleep 3
done

if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "❌ Deployment Failed: Application container failed to report healthy."
    docker compose -f "$COMPOSE_FILE" logs --tail 50 api
    exit 1
fi

# 5. Reload Nginx without dropping client connections
echo "5. Reloading Nginx reverse proxy..."
docker compose -f "$COMPOSE_FILE" up -d nginx
docker compose -f "$COMPOSE_FILE" exec nginx nginx -s reload || true

# 6. Cleanup Unused Container Images
echo "6. Pruning old and dangling container images..."
docker image prune -f

echo "================================================="
echo "🎉 Deployment Successfully Completed!"
echo "================================================="
