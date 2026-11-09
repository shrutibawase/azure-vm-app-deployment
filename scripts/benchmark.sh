#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: API Latency & Rate Limiting Benchmark Suite
# ==============================================================================

TARGET_URL="${1:-http://localhost}"
REQUESTS="${2:-50}"

echo "================================================="
echo "⚡ Benchmarking API Performance & Latency"
echo "Target: $TARGET_URL"
echo "Requests: $REQUESTS"
echo "Timestamp: $(date -u)"
echo "================================================="

# 1. Warm-up Request
echo "1. Performing warm-up probe..."
curl -s -o /dev/null -w "Warm-up HTTP Status: %{http_code} (Time: %{time_total}s)\n" "$TARGET_URL/healthz"

# 2. Sequential Latency Sampling
echo "2. Measuring endpoint latency distribution..."
TOTAL_TIME=0
COUNT=0
STATUS_200=0
STATUS_429=0

for i in $(seq 1 "$REQUESTS"); do
    RESULT=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" "$TARGET_URL/api/v1/resources")
    CODE=$(echo "$RESULT" | cut -d' ' -f1)
    TIME=$(echo "$RESULT" | cut -d' ' -f2)

    TOTAL_TIME=$(echo "$TOTAL_TIME + $TIME" | bc 2>/dev/null || awk "BEGIN {print $TOTAL_TIME + $TIME}")
    COUNT=$((COUNT + 1))

    if [ "$CODE" -eq 200 ] || [ "$CODE" -eq 201 ]; then
        STATUS_200=$((STATUS_200 + 1))
    elif [ "$CODE" -eq 429 ]; then
        STATUS_429=$((STATUS_429 + 1))
    fi
done

AVG_TIME=$(awk "BEGIN {printf \"%.4f\", $TOTAL_TIME / $COUNT}")

echo "================================================="
echo "📊 Benchmark Results Summary:"
echo "Total Requests:   $COUNT"
echo "Success (2xx):    $STATUS_200"
echo "Throttled (429):  $STATUS_429"
echo "Average Latency:  ${AVG_TIME}s"
echo "Rate Limiter:     $([ "$STATUS_429" -gt 0 ] && echo 'Active & Enforcing (Pass)' || echo 'Within Rate Limit')"
echo "================================================="
