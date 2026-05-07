<#
.SYNOPSIS
    Installs Scoop-managed apps from apps.json. Must run in a non-admin shell.

.DESCRIPTION
    Scoop refuses elevated installs by design. setup-apps.ps1 self-elevates
    for winget/choco and skips scoop apps; this script picks them up.

    Reads the same apps.json. Walks every category, installs any app whose
    manager is "scoop" and which is not yet installed. Adds required buckets
    (extras, nerd-fonts) on first run.

    Shell/env/PATH configuration lives in setup-env-shell.ps1 — run it after
    this script.

.USAGE
    .\setup-scoop.ps1
    .\setup-scoop.ps1 -DryRun
    .\setup-scoop.ps1 -ConfigPath "C:\path\to\apps.json"
    .\setup-scoop.ps1 -Categories "dev-environment"
#>

param(
    [switch]$DryRun,
    [string]$ConfigPath = ".\apps.json",
    [string[]]$Categories = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Refuse elevated -----------------------------------------------------------
if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "  [!] setup-scoop.ps1 must run in a NON-admin PowerShell." -ForegroundColor Red
    Write-Host "      Scoop refuses elevated installs by design." -ForegroundColor Red
    Write-Host "      Close this window, open a regular PowerShell, and run again." -ForegroundColor Red
    Write-Host ""
    exit 1
}

# -- Banner --------------------------------------------------------------------
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "        Scoop Setup (non-admin)           " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  ** DRY RUN MODE -- no changes will be made **" -ForegroundColor Yellow
    Write-Host ""
}

# -- Verify scoop is available -------------------------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  [!] Scoop is not installed. Install it first:" -ForegroundColor Red
    Write-Host "      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
    Write-Host "      irm get.scoop.sh | iex" -ForegroundColor Yellow
    exit 1
}
Write-Host "  Scoop detected." -ForegroundColor Green

# -- Load config ---------------------------------------------------------------
if (-not (Test-Path $ConfigPath)) {
    Write-Host "  [!] Config file not found at $ConfigPath" -ForegroundColor Red
    exit 1
}
$config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

# -- Ensure required buckets ---------------------------------------------------
$existingBuckets = (scoop bucket list 2>$null | ForEach-Object { ($_ -split '\s+')[0] }) -as [string[]]
$requiredBuckets = @("extras", "nerd-fonts")

foreach ($bucket in $requiredBuckets) {
    if ($existingBuckets -notcontains $bucket) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would add bucket: $bucket" -ForegroundColor Yellow
        } else {
            Write-Host "  Adding bucket: $bucket..." -ForegroundColor DarkCyan
            scoop bucket add $bucket
        }
    } else {
        Write-Host "  Bucket already present: $bucket" -ForegroundColor DarkGray
    }
}
Write-Host ""

# -- Collect scoop apps --------------------------------------------------------
$selectedCategories = $config.categories.PSObject.Properties
if ($Categories.Count -gt 0) {
    $selectedCategories = $selectedCategories | Where-Object { $_.Name -in $Categories }
}

$scoopApps = @()
foreach ($cat in $selectedCategories) {
    foreach ($app in $cat.Value.apps) {
        if ($app.manager -eq "scoop") {
            $scoopApps += $app
        }
    }
}

if ($scoopApps.Count -eq 0) {
    Write-Host "  No scoop apps found in config." -ForegroundColor Yellow
    exit 0
}

# -- Detect already-installed --------------------------------------------------
$installedList = scoop list 2>$null | Out-String
$toInstall = @()
$alreadyInstalled = @()

foreach ($app in $scoopApps) {
    if ($installedList -match "(?m)^$([regex]::Escape($app.id))\s") {
        Write-Host "    [OK] $($app.name)" -ForegroundColor DarkGray
        $alreadyInstalled += $app
    } else {
        Write-Host "    [--] $($app.name)  -> will install" -ForegroundColor Yellow
        $toInstall += $app
    }
}

Write-Host ""
Write-Host "  Already installed : $($alreadyInstalled.Count)" -ForegroundColor Green
Write-Host "  To install        : $($toInstall.Count)" -ForegroundColor Yellow
Write-Host ""

if ($toInstall.Count -eq 0) {
    Write-Host "  Nothing to install." -ForegroundColor Green
    exit 0
}

if ($DryRun) {
    Write-Host "  [DRY RUN] The following would be installed:" -ForegroundColor Yellow
    foreach ($app in $toInstall) {
        Write-Host "    - $($app.name) ($($app.id))"
    }
    exit 0
}

# -- Install -------------------------------------------------------------------
$succeeded = @()
$failed = @()

foreach ($app in $toInstall) {
    Write-Host ""
    Write-Host "  -> Installing $($app.name) ($($app.id))..." -ForegroundColor Cyan
    try {
        scoop install $app.id
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "  [OK] $($app.name)" -ForegroundColor Green
            $succeeded += $app
        } else {
            Write-Host "  [FAIL] $($app.name) -- exit $LASTEXITCODE" -ForegroundColor Red
            $failed += $app
        }
    } catch {
        Write-Host "  [FAIL] $($app.name) -- $($_.Exception.Message)" -ForegroundColor Red
        $failed += $app
    }
}

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "          Scoop Install Report             " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "  Succeeded : $($succeeded.Count) / $($toInstall.Count)" -ForegroundColor Green
foreach ($a in $succeeded) { Write-Host "    + $($a.name)" -ForegroundColor Green }
if ($failed.Count -gt 0) {
    Write-Host "  Failed    : $($failed.Count) / $($toInstall.Count)" -ForegroundColor Red
    foreach ($a in $failed) { Write-Host "    x $($a.name)" -ForegroundColor Red }
}
Write-Host ""
Write-Host "  Next: run .\setup-env-shell.ps1 to deploy shell/env config." -ForegroundColor Cyan
Write-Host ""
