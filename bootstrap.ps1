# bootstrap.ps1 — Windows setup entry point
# Run as Administrator in PowerShell:  .\bootstrap.ps1
# Flags: -SkipRuntimes -SkipDevOps -NoGui
param(
  [switch]$SkipRuntimes,
  [switch]$SkipDevOps,
  [switch]$NoGui
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Log($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Have($cmd) { $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue) }

# ── Require Administrator ─────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Run this script as Administrator (right-click PowerShell > Run as Administrator)"
  exit 1
}

# ── Execution policy ──────────────────────────────────────────────────────────
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# ── Install Scoop (user-space package manager) ────────────────────────────────
if (-not (Have scoop)) {
  Log "Installing Scoop"
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

# ── Install winget if missing (usually pre-installed on Win 11) ───────────────
if (-not (Have winget)) {
  Log "winget not found — install App Installer from the Microsoft Store then re-run."
  exit 1
}

# ── Windows packages ──────────────────────────────────────────────────────────
& "$ScriptDir\scripts\windows\packages.ps1" -NoGui:$NoGui

# ── Runtimes ──────────────────────────────────────────────────────────────────
if (-not $SkipRuntimes) {
  Log "Installing language runtimes"
  & "$ScriptDir\scripts\windows\runtimes.ps1"
}

# ── DevOps tools ──────────────────────────────────────────────────────────────
if (-not $SkipDevOps) {
  Log "Installing DevOps / cloud tools"
  & "$ScriptDir\scripts\windows\devops.ps1"
}

Log "Bootstrap complete. Restart your terminal."
