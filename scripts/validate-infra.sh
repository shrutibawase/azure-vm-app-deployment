#!/usr/bin/env bash
set -euo pipefail

echo "==========================================="
echo "🔍 Validating Terraform Infrastructure Code"
echo "==========================================="

cd "$(dirname "$0")/../terraform"

echo "1. Checking code formatting..."
terraform fmt -check -diff

echo "2. Initializing provider plugins..."
terraform init -backend=false

echo "3. Validating Terraform syntax & schema..."
terraform validate

echo "✅ All infrastructure validation checks passed successfully!"
