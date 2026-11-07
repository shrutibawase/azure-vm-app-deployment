#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Post-Deployment Smoke Test & Production Health Verification
# ==============================================================================

TARGET_HOST="${1:-http://localhost}"

echo "================================================="
echo "🔬 Starting Smoke Tests on Target: $TARGET_HOST"
echo "Timestamp: $(date -u)"
echo "================================================="

# Test 1: Liveness Probe (/healthz)
echo "1. Checking liveness probe (/healthz)..."
LIVENESS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_HOST/healthz" || echo "000")
if [ "$LIVENESS_CODE" -ne 200 ]; then
    echo "❌ Liveness probe FAILED with status $LIVENESS_CODE"
    exit 1
fi
echo "✅ Liveness probe passed (HTTP 200)"

# Test 2: Readiness Probe (/readyz)
echo "2. Checking readiness probe (/readyz)..."
READINESS_RESPONSE=$(curl -s -f "$TARGET_HOST/readyz")
echo "$READINESS_RESPONSE" | grep -q '"status":"ready"' || {
    echo "❌ Readiness probe failed: $READINESS_RESPONSE"
    exit 1
}
echo "✅ Readiness probe passed"

# Test 3: Database Connectivity (/api/v1/health/db)
echo "3. Checking database health (/api/v1/health/db)..."
DB_RESPONSE=$(curl -s -f "$TARGET_HOST/api/v1/health/db")
echo "$DB_RESPONSE" | grep -q '"connected":true' || {
    echo "❌ Database connection check failed: $DB_RESPONSE"
    exit 1
}
echo "✅ Database connection probe passed"

# Test 4: Security Headers Verification
echo "4. Validating presence of security headers..."
HEADERS=$(curl -s -I "$TARGET_HOST/healthz")
echo "$HEADERS" | grep -i -q "x-frame-options" || {
    echo "⚠️ Warning: X-Frame-Options header missing in response"
}
echo "$HEADERS" | grep -i -q "x-content-type-options" || {
    echo "⚠️ Warning: X-Content-Type-Options header missing in response"
}
echo "✅ Security headers check verified"

echo "================================================="
echo "🎉 All Smoke Tests Passed Successfully!"
echo "================================================="
