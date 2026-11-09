#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Script: Safe Infrastructure Teardown & Azure Resource Deprovisioning
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."
TERRAFORM_DIR="$ROOT_DIR/terraform"

echo "================================================="
echo "⚠️  DANGER: Azure Infrastructure Teardown"
echo "================================================="

CONFIRM="${1:-}"
if [[ "$CONFIRM" != "--force" && "$CONFIRM" != "-f" ]]; then
    read -rp "Are you SURE you want to destroy all Azure VM & Network resources? (type 'DESTROY' to confirm): " INPUT
    if [ "$INPUT" != "DESTROY" ]; then
        echo "Teardown aborted."
        exit 0
    fi
fi

echo "🗑 Starting Terraform teardown process..."
cd "$TERRAFORM_DIR"
terraform destroy -auto-approve

echo "🧹 Cleaning up local private keys and transient files..."
rm -f id_rsa_*.pem
rm -f tfplan
rm -f .terraform.tfstate.lock.info

echo "================================================="
echo "✅ All Azure resources and local keys cleaned up!"
echo "================================================="
