# -----------------------------------------------------------------------------
# PowerShell Helper: Connect to Azure Linux VM
# -----------------------------------------------------------------------------
[CmdletBinding()]
param (
    [string]$Username = "azureuser",
    [string]$PublicIp = "",
    [string]$KeyFile = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🚀 Azure Virtual Machine Connection Helper (PowerShell)" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$TerraformDir = Join-Path $PSScriptRoot "..\terraform"
Set-Location $TerraformDir

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "Terraform CLI is not installed or not in PATH."
    exit 1
}

if (-not $PublicIp) {
    try {
        $PublicIp = (terraform output -raw public_ip_address 2>$null).Trim()
    } catch {}
}

if (-not $KeyFile) {
    try {
        $KeyRel = (terraform output -raw ssh_private_key_file 2>$null).Trim()
        if ($KeyRel) {
            $KeyFile = Join-Path $TerraformDir $KeyRel
        }
    } catch {}
}

if (-not $PublicIp) {
    $PublicIp = Read-Host "Enter VM Public IP Address"
}

if (-not $KeyFile) {
    $KeyFile = Read-Host "Enter Path to Private Key (.pem)"
}

Write-Host "📡 Initiating SSH session to ${Username}@${PublicIp}..." -ForegroundColor Green
ssh -o StrictHostKeyChecking=accept-new -i "$KeyFile" "${Username}@${PublicIp}"
