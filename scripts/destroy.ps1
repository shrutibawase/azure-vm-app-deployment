# ==============================================================================
# Script: Safe Infrastructure Teardown (PowerShell)
# ==============================================================================
[CmdletBinding()]
param (
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Red
Write-Host "⚠️  DANGER: Azure Infrastructure Teardown (PowerShell)" -ForegroundColor Red
Write-Host "=================================================" -ForegroundColor Red

if (-not $Force) {
    $confirm = Read-Host "Are you SURE you want to destroy all Azure VM & Network resources? (type 'DESTROY')"
    if ($confirm -ne "DESTROY") {
        Write-Host "Teardown aborted."
        exit 0
    }
}

$RootDir = Join-Path $PSScriptRoot ".."
$TerraformDir = Join-Path $RootDir "terraform"
Set-Location $TerraformDir

Write-Host "🗑 Deprovisioning Azure resources with Terraform..." -ForegroundColor Yellow
terraform destroy -auto-approve

Write-Host "🧹 Removing generated local keys..." -ForegroundColor Yellow
Get-ChildItem -Path $TerraformDir -Filter "id_rsa_*.pem" | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "✅ All Azure infrastructure destroyed successfully." -ForegroundColor Green
