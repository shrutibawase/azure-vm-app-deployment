# ==============================================================================
# Script: PostgreSQL Database Backup Helper (PowerShell)
# ==============================================================================
[CmdletBinding()]
param (
    [string]$DbUser = "clouduser",
    [string]$DbName = "cloudappdb"
)

$ErrorActionPreference = "Stop"

$RootDir = Join-Path $PSScriptRoot ".."
Set-Location $RootDir

$BackupDir = Join-Path $RootDir "backups"
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = Join-Path $BackupDir "db_${DbName}_${Timestamp}.sql"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "💾 Starting Database Backup (PowerShell)" -ForegroundColor Cyan
Write-Host "Target DB: $DbName" -ForegroundColor Cyan
Write-Host "File: $BackupFile" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

docker compose exec -T db pg_dump -U $DbUser -d $DbName --clean --if-exists | Out-File -FilePath $BackupFile -Encoding utf8

$Checksum = (Get-FileHash -Path $BackupFile -Algorithm SHA256).Hash
Set-Content -Path "${BackupFile}.sha256" -Value $Checksum

Write-Host "✅ Database backup created with SHA256: $Checksum" -ForegroundColor Green
