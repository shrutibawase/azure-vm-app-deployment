# ==============================================================================
# Script: Database Disaster Recovery Restore (PowerShell)
# ==============================================================================
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$BackupFile,
    [string]$DbUser = "clouduser",
    [string]$DbName = "cloudappdb",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BackupFile)) {
    Write-Error "Backup file $BackupFile does not exist."
    exit 1
}

if (-not $Force) {
    $confirm = Read-Host "⚠️ WARNING: This will overwrite data in $DbName. Type 'YES' to proceed"
    if ($confirm -ne "YES") {
        Write-Host "Operation cancelled."
        exit 0
    }
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🚨 Database Disaster Recovery Restore (PowerShell)" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

Get-Content -Path $BackupFile | docker compose exec -T db psql -U $DbUser -d $DbName

Write-Host "✅ Database restore completed successfully!" -ForegroundColor Green
