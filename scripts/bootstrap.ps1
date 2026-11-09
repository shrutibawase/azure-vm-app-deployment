# ==============================================================================
# Script: One-Click Production Infrastructure Bootstrap (PowerShell)
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🚀 Azure VM Production Infrastructure Bootstrap (PowerShell)" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$RootDir = Join-Path $PSScriptRoot ".."
$TerraformDir = Join-Path $RootDir "terraform"

# 1. Prerequisite Validation
Write-Host "1. Checking required CLI tools..." -ForegroundColor Yellow
foreach ($cmd in @("az", "terraform", "ssh", "scp")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "Required tool '$cmd' is not installed or not in PATH."
        exit 1
    }
}
Write-Host "✅ All prerequisite CLI tools are installed." -ForegroundColor Green

# 2. Azure Login Check
Write-Host "2. Checking Azure authentication..." -ForegroundColor Yellow
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✅ Authenticated to: $($account.name) ($($account.id))" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Azure login required. Opening browser..." -ForegroundColor Yellow
    az login | Out-Null
}

# 3. Provision Infrastructure via Terraform
Write-Host "3. Provisioning resources with Terraform..." -ForegroundColor Yellow
Set-Location $TerraformDir
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
if (Test-Path "tfplan") { Remove-Item "tfplan" }

$PublicIp = (terraform output -raw public_ip_address).Trim()
$SshKey = (terraform output -raw ssh_private_key_file).Trim()
$FullKeyPath = Join-Path $TerraformDir $SshKey

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🎉 Infrastructure Provisioning Complete!" -ForegroundColor Green
Write-Host "Public IP: $PublicIp" -ForegroundColor Green
Write-Host "SSH Key:   $FullKeyPath" -ForegroundColor Green
Write-Host "SSH Cmd:   ssh -i $FullKeyPath azureuser@$PublicIp" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Cyan
