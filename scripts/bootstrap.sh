#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: One-Click Production Infrastructure Bootstrap for Azure
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
TERRAFORM_DIR="$ROOT_DIR/terraform"

echo "================================================="
echo "🚀 Azure VM Production Infrastructure Bootstrap"
echo "Timestamp: $(date -u)"
echo "================================================="

# 1. Prerequisite Validation
echo "1. Checking required CLI tools..."
for tool in az terraform ssh scp; do
    if ! command -v "$tool" &> /dev/null; then
        echo "❌ Error: '$tool' is required but not installed."
        exit 1
    fi
done
echo "✅ All prerequisite CLI tools are installed."

# 2. Azure Authentication Check
echo "2. Verifying Azure CLI authentication..."
if ! az account show &> /dev/null; then
    echo "⚠️ Not logged into Azure. Initiating login..."
    az login --output table
fi
ACCOUNT_NAME=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "✅ Authenticated to Azure Subscription: $ACCOUNT_NAME ($SUBSCRIPTION_ID)"

# 3. Terraform Execution
echo "3. Initializing and provisioning infrastructure via Terraform..."
cd "$TERRAFORM_DIR"
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
rm -f tfplan

# 4. Extract Infrastructure Outputs
PUBLIC_IP=$(terraform output -raw public_ip_address)
SSH_KEY_FILE=$(terraform output -raw ssh_private_key_file)
SSH_KEY_PATH="$TERRAFORM_DIR/$SSH_KEY_FILE"
chmod 600 "$SSH_KEY_PATH"

echo "================================================="
echo "🎉 Azure Infrastructure Provisioned Successfully!"
echo "Public IP: $PUBLIC_IP"
echo "SSH Key:   $SSH_KEY_PATH"
echo "SSH Cmd:   ssh -i $SSH_KEY_PATH azureuser@$PUBLIC_IP"
echo "================================================="
