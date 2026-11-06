#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Automated TLS / SSL Certificate Initialization with Let's Encrypt
# ==============================================================================

DOMAIN="${1:-}"
EMAIL="${2:-}"

if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
    echo "❌ Error: Missing domain or email."
    echo "Usage: ./init-ssl.sh <your-domain.com> <your-email@domain.com>"
    exit 1
fi

echo "================================================="
echo "🔒 Initializing SSL for Domain: $DOMAIN ($EMAIL)"
echo "================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
cd "$ROOT_DIR"

DATA_PATH="./certbot_data"
CERT_PATH="$DATA_PATH/conf/live/$DOMAIN"

mkdir -p "$DATA_PATH/conf/live/$DOMAIN"
mkdir -p "$DATA_PATH/www"

# 1. Generate temporary self-signed certificate so Nginx can boot if SSL enabled
if [ ! -e "$CERT_PATH/cert.pem" ]; then
    echo "🔑 Creating temporary self-signed certificate for initial bootstrapping..."
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
        -keyout "$CERT_PATH/privkey.pem" \
        -out "$CERT_PATH/fullchain.pem" \
        -subj "/CN=localhost"
fi

# 2. Start Nginx
echo "🚀 Starting Nginx..."
docker compose -f docker-compose.prod.yml up -d nginx

# 3. Request genuine certificate from Let's Encrypt
echo "🌐 Requesting official certificate from Let's Encrypt..."
docker compose -f docker-compose.prod.yml run --rm --entrypoint "\
    certbot certonly --webroot -w /var/www/certbot \
    --email $EMAIL \
    -d $DOMAIN \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal \
    --non-interactive" certbot

# 4. Reload Nginx with new certificate
echo "🔄 Reloading Nginx configuration..."
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload

echo "✅ SSL certificate issued and Nginx reloaded successfully!"
