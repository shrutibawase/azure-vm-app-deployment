#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Nginx Proxy Configuration Validator & HTTP Test Suite
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

echo "================================================="
echo "🧪 Running Nginx Configuration & Smoke Tests"
echo "================================================="

# 1. Static Configuration Test using isolated container
echo "1. Validating Nginx configuration syntax with 'nginx -t'..."
docker run --rm \
    -v "$ROOT_DIR/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" \
    -v "$ROOT_DIR/nginx/conf.d:/etc/nginx/conf.d:ro" \
    -v "$ROOT_DIR/nginx/snippets:/etc/nginx/snippets:ro" \
    nginx:1.25-alpine nginx -t

echo "✅ Nginx syntax and configuration test passed!"

# 2. Endpoint Health Smoke Test (optional if running locally)
HOST_URL="${1:-http://localhost}"
echo "2. Testing HTTP endpoint response on $HOST_URL/healthz..."
if command -v curl &> /dev/null; then
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HOST_URL/healthz" || echo "000")
    if [[ "$STATUS_CODE" == "200" ]]; then
        echo "✅ Health endpoint responded with HTTP 200 OK"
    else
        echo "ℹ️ Note: Server not running or returned $STATUS_CODE (Expected if testing offline)"
    fi
fi
