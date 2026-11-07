# ==============================================================================
# Script: Remote Deployment Trigger via PowerShell & SSH
# ==============================================================================
[CmdletBinding()]
param (
    [string]$VmHost = "",
    [string]$VmUser = "azureuser",
    [string]$KeyFile = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🚀 Remote Azure VM Deployment Helper (PowerShell)" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$RootDir = Join-Path $PSScriptRoot ".."
$TerraformDir = Join-Path $RootDir "terraform"

if (-not $VmHost -and (Test-Path $TerraformDir)) {
    try {
        Set-Location $TerraformDir
        $VmHost = (terraform output -raw public_ip_address 2>$null).Trim()
        $KeyRel = (terraform output -raw ssh_private_key_file 2>$null).Trim()
        if ($KeyRel) { $KeyFile = Join-Path $TerraformDir $KeyRel }
    } catch {}
    Set-Location $RootDir
}

if (-not $VmHost) { $VmHost = Read-Host "Enter Azure VM Public IP" }
if (-not $KeyFile) { $KeyFile = Read-Host "Enter Path to Private Key (.pem)" }

Write-Host "📦 Syncing deployment configuration to ${VmUser}@${VmHost}..." -ForegroundColor Yellow
scp -o StrictHostKeyChecking=accept-new -i "$KeyFile" -r `
    "$RootDir/docker-compose.prod.yml" `
    "$RootDir/nginx" `
    "$RootDir/scripts" `
    "${VmUser}@${VmHost}:~/azure-vm-app-deployment/"

Write-Host "🚀 Executing zero-downtime deployment script on VM..." -ForegroundColor Green
ssh -o StrictHostKeyChecking=accept-new -i "$KeyFile" "${VmUser}@${VmHost}" `
    "cd ~/azure-vm-app-deployment && chmod +x scripts/*.sh && ./scripts/deploy.sh"

Write-Host "✅ Remote deployment execution finished!" -ForegroundColor Green
