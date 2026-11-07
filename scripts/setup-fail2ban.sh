#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Configure Host Fail2Ban Intrusion Prevention
# ==============================================================================

echo "================================================="
echo "🛡 Configuring Fail2Ban Intrusion Prevention"
echo "================================================="

if [[ $EUID -ne 0 ]]; then
   echo "⚠️ This script must be run as root (use sudo)." 
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$SCRIPT_DIR/../monitoring/fail2ban/jail.local"

# 1. Install Fail2ban if missing
if ! command -v fail2ban-client &> /dev/null; then
    echo "📦 Installing fail2ban package..."
    apt-get update -y && apt-get install -y fail2ban
fi

# 2. Deploy Jail Configuration
echo "⚙️ Copying jail configuration..."
cp "$CONFIG_SOURCE" /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

# 3. Restart and Enable Service
echo "🔄 Restarting Fail2Ban daemon..."
systemctl restart fail2ban
systemctl enable fail2ban

# 4. Display Active Jail Status
echo "✅ Active Fail2Ban Status:"
fail2ban-client status sshd || true
