$ErrorActionPreference = "Stop"

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "🔍 Validating Terraform Infrastructure Code" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$TerraformDir = Join-Path $PSScriptRoot "..\terraform"
Set-Location $TerraformDir

Write-Host "1. Checking code formatting..." -ForegroundColor Yellow
terraform fmt -check -diff

Write-Host "2. Initializing provider plugins..." -ForegroundColor Yellow
terraform init -backend=false

Write-Host "3. Validating Terraform syntax & schema..." -ForegroundColor Yellow
terraform validate

Write-Host "✅ All infrastructure validation checks passed successfully!" -ForegroundColor Green
