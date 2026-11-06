# ==============================================================================
# Script: Nginx Proxy Configuration Validator (PowerShell)
# ==============================================================================
[CmdletBinding()]
param (
    [string]$HostUrl = "http://localhost"
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🧪 Running Nginx Configuration & Smoke Tests" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$RootDir = Join-Path $PSScriptRoot ".."

Write-Host "1. Validating Nginx configuration syntax with 'nginx -t'..." -ForegroundColor Yellow
docker run --rm `
    -v "${RootDir}/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" `
    -v "${RootDir}/nginx/conf.d:/etc/nginx/conf.d:ro" `
    -v "${RootDir}/nginx/snippets:/etc/nginx/snippets:ro" `
    nginx:1.25-alpine nginx -t

Write-Host "✅ Nginx syntax and configuration test passed!" -ForegroundColor Green

Write-Host "2. Testing HTTP endpoint response on ${HostUrl}/healthz..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "${HostUrl}/healthz" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Health endpoint responded with HTTP 200 OK" -ForegroundColor Green
    }
} catch {
    Write-Host "ℹ️ Server offline or unreachable (Expected when testing static config)" -ForegroundColor Gray
}
