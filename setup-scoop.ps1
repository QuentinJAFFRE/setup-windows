<#
.SYNOPSIS
    Installs Scoop-managed apps from apps.json AND deploys user dotfiles.
    Must run in a non-admin shell.

.DESCRIPTION
    Scoop refuses elevated installs by design. setup-apps.ps1 self-elevates
    for winget/choco and skips scoop apps; this script picks them up.

    Reads the same apps.json. Walks every category, installs any app whose
    manager is "scoop" and which is not yet installed. Adds required buckets
    (extras, nerd-fonts) on first run.

    After installs, deploys dotfiles from .\dotfiles\ to the user profile
    (PowerShell $PROFILE, starship config, yazi config). Pass -NoConfig to
    skip this step.

.USAGE
    .\setup-scoop.ps1
    .\setup-scoop.ps1 -DryRun
    .\setup-scoop.ps1 -NoConfig                 # skip dotfile deploy
    .\setup-scoop.ps1 -ConfigPath "C:\path\to\apps.json"
    .\setup-scoop.ps1 -Categories "dev-environment"
#>

param(
    [switch]$DryRun,
    [switch]$NoConfig,
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

# -- Dotfiles deploy -----------------------------------------------------------
# Mirrors .\dotfiles\* into user-profile locations. Idempotent: copies overwrite.

if ($NoConfig) {
    Write-Host "  -NoConfig set; skipping dotfile deploy." -ForegroundColor Yellow
    return
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$dotfilesDir = Join-Path $repoRoot "dotfiles"

if (-not (Test-Path $dotfilesDir)) {
    Write-Host "  No .\dotfiles\ directory found; skipping config deploy." -ForegroundColor Yellow
    return
}

# (sourceRelativeToDotfiles, destinationAbsolute)
$dotfileMap = @(
    @{ src = "powershell\Microsoft.PowerShell_profile.ps1"; dst = $PROFILE },
    @{ src = "starship\starship.toml";                       dst = "$env:USERPROFILE\.config\starship.toml" },
    @{ src = "yazi\yazi.toml";                               dst = "$env:APPDATA\yazi\config\yazi.toml" },
    @{ src = "yazi\keymap.toml";                             dst = "$env:APPDATA\yazi\config\keymap.toml" }
)

Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "          Deploying dotfiles               " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan

$deployed = 0
$skippedConfigs = 0

foreach ($entry in $dotfileMap) {
    $srcPath = Join-Path $dotfilesDir $entry.src
    $dstPath = $entry.dst

    if (-not (Test-Path $srcPath)) {
        Write-Host "    [SKIP] source missing: $($entry.src)" -ForegroundColor DarkGray
        $skippedConfigs++
        continue
    }

    $dstDir = Split-Path $dstPath -Parent

    if ($DryRun) {
        Write-Host "    [DRY RUN] would deploy $($entry.src) -> $dstPath" -ForegroundColor Yellow
        continue
    }

    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
    }
    Copy-Item -Path $srcPath -Destination $dstPath -Force
    Write-Host "    [OK] $($entry.src) -> $dstPath" -ForegroundColor Green
    $deployed++
}

Write-Host ""
if (-not $DryRun) {
    Write-Host "  Deployed $deployed file(s)." -ForegroundColor Green
    if ($skippedConfigs -gt 0) {
        Write-Host "  Skipped $skippedConfigs (source not present in dotfiles/)." -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Open a fresh PowerShell window for `$PROFILE changes to take effect." -ForegroundColor Cyan
    Write-Host ""
}
