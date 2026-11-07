#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Host Security Audit & Open Ports Inspection
# ==============================================================================

echo "================================================="
echo "🔍 Host Security & Port Audit Report"
echo "Timestamp: $(date -u)"
echo "================================================="

# 1. Active Listening Network Ports
echo "1. Active TCP/UDP Listening Ports:"
if command -v ss &> /dev/null; then
    ss -tuln | grep -E "LISTEN"
elif command -v netstat &> /dev/null; then
    netstat -tuln | grep -E "LISTEN"
fi

# 2. UFW Firewall Rules
echo ""
echo "2. UFW Firewall Status:"
if command -v ufw &> /dev/null; then
    sudo ufw status verbose || true
fi

# 3. Fail2Ban Banned IPs Status
echo ""
echo "3. Fail2Ban Active Jails & Banned IP Counts:"
if command -v fail2ban-client &> /dev/null; then
    sudo fail2ban-client status sshd || true
fi

# 4. Recent Failed SSH Authentication Attempts
echo ""
echo "4. Last 5 Failed SSH Attempts (from auth logs):"
if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | tail -n 5 || echo "No recent failed password logs."
fi

echo "================================================="
echo "✅ Security Audit Inspection Completed."
echo "================================================="
