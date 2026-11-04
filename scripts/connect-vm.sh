#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Helper Script: Connect to Azure Linux VM
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

echo "================================================="
echo "🚀 Azure Virtual Machine Connection Helper"
echo "================================================="

cd "$TERRAFORM_DIR"

if ! command -v terraform &> /dev/null; then
    echo "❌ Error: terraform CLI is required but not installed."
    exit 1
fi

echo "🔍 Fetching connection details from Terraform state..."

PUBLIC_IP=$(terraform output -raw public_ip_address 2>/dev/null || true)
KEY_FILE=$(terraform output -raw ssh_private_key_file 2>/dev/null || true)

if [[ -z "$PUBLIC_IP" || -z "$KEY_FILE" ]]; then
    echo "⚠️ Warning: Could not find active outputs from Terraform state."
    echo "Usage: ./connect-vm.sh [username] [ip_address] [path_to_pem]"
    USER="${1:-azureuser}"
    IP="${2:-}"
    KEY="${3:-}"
    if [[ -z "$IP" ]]; then
        read -rp "Enter VM Public IP Address: " IP
    fi
    if [[ -z "$KEY" ]]; then
        read -rp "Enter Path to Private Key (.pem): " KEY
    fi
else
    USER="azureuser"
    IP="$PUBLIC_IP"
    KEY="$TERRAFORM_DIR/$KEY_FILE"
fi

if [[ -f "$KEY" ]]; then
    chmod 600 "$KEY"
    echo "🔑 Permissions for key $KEY set to 0600."
fi

echo "📡 Connecting to ${USER}@${IP}..."
ssh -o StrictHostKeyChecking=accept-new -i "$KEY" "${USER}@${IP}"
