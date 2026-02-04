Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Windows E2E smoke test for barked.ps1.
# Runs only read-only/dry-run paths (Audit + Clean -DryRun).

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$scriptPath = Join-Path $repoRoot "scripts\barked.ps1"

$auditDir = Join-Path $env:RUNNER_TEMP "barked-audits"
New-Item -ItemType Directory -Path $auditDir -Force | Out-Null

$env:BARKED_NO_UPDATE_CHECK = "1"

Write-Host "--- barked.ps1 -Version"
& $scriptPath -Version | Out-Null

Write-Host ""
Write-Host "--- barked.ps1 -Audit (write to audit dir)"
& $scriptPath -Audit -AuditDir $auditDir -NoUpdateCheck | Out-Null

$date = Get-Date -Format "yyyy-MM-dd"
$auditFile = Join-Path $auditDir "audit-$date.md"
if (-not (Test-Path -LiteralPath $auditFile)) {
  throw "Expected audit report at $auditFile"
}

Write-Host ""
Write-Host "--- barked.ps1 -Clean -DryRun (non-interactive selection)"
& $scriptPath -Clean -DryRun -CleanSelect "user-caches,dev-cruft" -NoUpdateCheck | Out-Null

Write-Host "OK"

