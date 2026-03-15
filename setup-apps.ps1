<#
.SYNOPSIS
    Automated PC setup script - installs apps from apps.json using winget, Chocolatey, and GitHub releases.

.DESCRIPTION
    - Reads a JSON config file listing apps by category
    - Detects which apps are already installed (skips them)
    - Installs only what is missing
    - Supports winget, Chocolatey, and GitHub releases (portable apps) as install sources
    - Auto-installs Chocolatey if needed
    - Dry-run mode, logging, and confirmation prompt

.USAGE
    .\setup-apps.ps1              # Normal run (will prompt before installing)
    .\setup-apps.ps1 -DryRun     # Show what would be installed, no changes
    .\setup-apps.ps1 -NoConfirm  # Skip confirmation prompt
    .\setup-apps.ps1 -ConfigPath "C:\myapps.json"
    .\setup-apps.ps1 -Categories "dev-tools","system-utilities"
#>

param(
    [switch]$DryRun,
    [switch]$NoConfirm,
    [string]$ConfigPath = ".\apps.json",
    [string[]]$Categories = @()
)

# -- Strict mode and error handling --------------------------------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Self-elevate to admin if not already --------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] This script requires admin privileges. Relaunching elevated...`n" -ForegroundColor Yellow
    $relaunchArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($DryRun)    { $relaunchArgs += " -DryRun" }
    if ($NoConfirm) { $relaunchArgs += " -NoConfirm" }
    if ($ConfigPath -ne ".\apps.json") { $relaunchArgs += " -ConfigPath `"$ConfigPath`"" }
    if ($Categories.Count -gt 0) { $relaunchArgs += " -Categories " + ($Categories -join ",") }
    Start-Process powershell.exe -Verb RunAs -ArgumentList $relaunchArgs
    exit
}

# -- Logging setup -------------------------------------------------------------
$LogFile = ".\setup-log.txt"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Write-Host $logLine -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logLine
}

# -- Banner --------------------------------------------------------------------
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "         PC Setup Script v1.0             " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  ** DRY RUN MODE -- no changes will be made **" -ForegroundColor Yellow
    Write-Host ""
}

Write-Log "Script started. Config: $ConfigPath"

# -- Load config ---------------------------------------------------------------
if (-not (Test-Path $ConfigPath)) {
    Write-Log "ERROR: Config file not found at $ConfigPath" "Red"
    exit 1
}

$config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
Write-Log "Config loaded successfully."

if ($config.settings.logFile) {
    $LogFile = $config.settings.logFile
}

# -- Ensure winget is available ------------------------------------------------
function Test-Winget {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Winget)) {
    Write-Log "ERROR: winget is not available. Please install App Installer from the Microsoft Store." "Red"
    exit 1
}
Write-Log "winget detected."

# -- Ensure Chocolatey is available (auto-install if needed) -------------------
function Test-Choco {
    try {
        $null = Get-Command choco -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

$needsChoco = $false
foreach ($cat in $config.categories.PSObject.Properties) {
    foreach ($app in $cat.Value.apps) {
        if ($app.manager -eq "choco") { $needsChoco = $true; break }
    }
    if ($needsChoco) { break }
}

if ($needsChoco -and -not (Test-Choco)) {
    Write-Log "Chocolatey not found. Installing..." "Yellow"
    if (-not $DryRun) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                     [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Log "Chocolatey installed successfully." "Green"
    } else {
        Write-Log "[DRY RUN] Would install Chocolatey." "Yellow"
    }
} elseif ($needsChoco) {
    Write-Log "Chocolatey detected."
}

# -- Detection helpers ---------------------------------------------------------
function Test-WingetInstalled {
    param([string]$PackageId)
    $result = winget list --id $PackageId --accept-source-agreements 2>$null
    return ($result | Select-String -Pattern $PackageId -Quiet)
}

function Test-ChocoInstalled {
    param([string]$PackageId)
    if (-not (Test-Choco)) { return $false }
    $result = choco list --exact $PackageId 2>$null
    return -not ($result | Select-String -Pattern "0 packages installed" -Quiet)
}

# -- GitHub portable app helpers -----------------------------------------------
$PortableAppsDir = "$env:LOCALAPPDATA\PortableApps"

function Test-GitHubInstalled {
    param([string]$RepoId)
    $appFolder = Join-Path $PortableAppsDir ($RepoId -replace '/', '_')
    return (Test-Path $appFolder)
}

function Install-GitHubApp {
    param([string]$RepoId, [string]$AppName)
    $appFolder = Join-Path $PortableAppsDir ($RepoId -replace '/', '_')

    $apiUrl = "https://api.github.com/repos/$RepoId/releases/latest"
    $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'User-Agent' = 'PC-Setup-Script' }

    $asset = $release.assets | Where-Object { $_.name -match '\.zip$' } | Select-Object -First 1
    if (-not $asset) {
        throw "No .zip asset found in latest release of $RepoId"
    }

    $zipPath = Join-Path $env:TEMP $asset.name
    Write-Log "  Downloading $($asset.name) ($([math]::Round($asset.size / 1MB, 1)) MB)..." "DarkCyan"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing

    New-Item -ItemType Directory -Path $appFolder -Force | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath $appFolder -Force
    Remove-Item $zipPath -Force

    $exe = Get-ChildItem -Path $appFolder -Filter "*.exe" -Recurse | Select-Object -First 1
    if ($exe) {
        $shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "$AppName.lnk"
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exe.FullName
        $shortcut.WorkingDirectory = $exe.DirectoryName
        $shortcut.Description = "$AppName (portable)"
        $shortcut.Save()
        Write-Log "  Shortcut created on desktop." "DarkCyan"
    }

    Write-Log "  Installed to $appFolder" "DarkCyan"
}

# -- Build install plan --------------------------------------------------------
Write-Log "Scanning installed apps..."
Write-Host ""

$toInstall = @()
$alreadyInstalled = @()

$selectedCategories = $config.categories.PSObject.Properties
if ($Categories.Count -gt 0) {
    $selectedCategories = $selectedCategories | Where-Object { $_.Name -in $Categories }
    Write-Log "Filtering to categories: $($Categories -join ', ')"
}

foreach ($cat in $selectedCategories) {
    $catName = $cat.Name
    $catDesc = $cat.Value.description
    Write-Host "  [$catName] $catDesc" -ForegroundColor Magenta

    foreach ($app in $cat.Value.apps) {
        $installed = $false

        if ($app.manager -eq "winget") {
            $installed = Test-WingetInstalled -PackageId $app.id
        } elseif ($app.manager -eq "choco") {
            $installed = Test-ChocoInstalled -PackageId $app.id
        } elseif ($app.manager -eq "github") {
            $installed = Test-GitHubInstalled -RepoId $app.id
        }

        if ($installed) {
            Write-Host "    [OK] $($app.name)" -ForegroundColor DarkGray
            $alreadyInstalled += $app
        } else {
            Write-Host "    [--] $($app.name)  -> will install ($($app.manager))" -ForegroundColor Yellow
            $toInstall += $app
        }
    }
    Write-Host ""
}

# -- Summary -------------------------------------------------------------------
Write-Host "  ----------------------------------------" -ForegroundColor Cyan
Write-Host "  Already installed : $($alreadyInstalled.Count)" -ForegroundColor Green
Write-Host "  To install        : $($toInstall.Count)" -ForegroundColor Yellow
Write-Host "  ----------------------------------------" -ForegroundColor Cyan
Write-Host ""

Write-Log "Scan complete. $($alreadyInstalled.Count) installed, $($toInstall.Count) to install."

if ($toInstall.Count -eq 0) {
    Write-Log "Nothing to install. You're all set!" "Green"
    exit 0
}

# -- Dry run stops here --------------------------------------------------------
if ($DryRun) {
    Write-Log "[DRY RUN] The following apps would be installed:"
    foreach ($app in $toInstall) {
        Write-Log "  - $($app.name) ($($app.id)) via $($app.manager)"
    }
    Write-Host "  Run without -DryRun to install." -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# -- Confirmation prompt -------------------------------------------------------
if (-not $NoConfirm) {
    Write-Host "  Apps to install:" -ForegroundColor White
    foreach ($app in $toInstall) {
        Write-Host "    - $($app.name) ($($app.manager))" -ForegroundColor White
    }
    Write-Host ""
    $confirm = Read-Host "  Proceed with installation? (y/N)"
    if ($confirm -notin @("y", "Y", "yes", "Yes")) {
        Write-Log "Installation cancelled by user." "Yellow"
        exit 0
    }
}

# -- Install -------------------------------------------------------------------
$succeeded = @()
$failed = @()
$total = $toInstall.Count
$current = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($app in $toInstall) {
    $current++
    $pct = [math]::Round(($current / $total) * 100)
    $progressBar = (">" * [math]::Floor($pct / 5)).PadRight(20, " ")

    Write-Host ""
    Write-Host "  [$current/$total] [$progressBar] $pct%" -ForegroundColor Cyan
    Write-Log "[$current/$total] $($app.name) ($($app.id)) via $($app.manager)" "Cyan"

    try {
        # -- Phase 1: Install ------------------------------------------------
        Write-Host "    -> $($app.name)..." -ForegroundColor DarkCyan

        if ($app.manager -eq "winget") {
            Write-Host "" # newline
            Write-Host "    -> Installing via winget..." -ForegroundColor DarkCyan
            # Run winget directly (not captured) so its native progress bar renders properly
            & winget install --id $app.id --exact --accept-package-agreements --accept-source-agreements --disable-interactivity

        } elseif ($app.manager -eq "choco") {
            Write-Host "" # newline
            Write-Host "    -> Installing via Chocolatey..." -ForegroundColor DarkCyan
            & choco install $app.id -y

        } elseif ($app.manager -eq "github") {
            Write-Host "" # newline
            Install-GitHubApp -RepoId $app.id -AppName $app.name
        }

        # -- Phase 2: Check result -----------------------------------------
        if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
            Write-Host "    [OK] $($app.name) installed successfully." -ForegroundColor Green
            Write-Log "  [OK] $($app.name) installed." "Green"
            $succeeded += $app
        } else {
            Write-Host "    [FAIL] $($app.name) -- exit code $LASTEXITCODE" -ForegroundColor Red
            Write-Log "  [FAIL] $($app.name) -- exit code $LASTEXITCODE" "Red"
            Write-Log "  Output: $output" "DarkGray"
            $failed += $app
        }
    } catch {
        Write-Host "    [FAIL] $($app.name) -- $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "  [FAIL] $($app.name) -- $($_.Exception.Message)" "Red"
        $failed += $app
    }

    # -- Elapsed time and ETA ----------------------------------------------
    $elapsed = $stopwatch.Elapsed
    if ($current -lt $total) {
        $avgPerApp = $elapsed.TotalSeconds / $current
        $remaining = [math]::Round($avgPerApp * ($total - $current))
        $mins = [math]::Floor($remaining / 60)
        $secs = $remaining % 60
        Write-Host "    Time elapsed: $($elapsed.ToString('mm\:ss')) | ETA: ${mins}m ${secs}s remaining" -ForegroundColor DarkGray
    }
}

# -- Final report --------------------------------------------------------------
$stopwatch.Stop()
$totalTime = $stopwatch.Elapsed.ToString('mm\:ss')

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "          Installation Report              " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "=== INSTALLATION REPORT ==="
Write-Log "Total time: $totalTime"
Write-Host "  Total time: $totalTime" -ForegroundColor White
Write-Host ""
Write-Log "Succeeded : $($succeeded.Count) / $total" "Green"
Write-Host "  Succeeded : $($succeeded.Count) / $total" -ForegroundColor Green
foreach ($app in $succeeded) { Write-Log "  + $($app.name)" "Green" }

if ($failed.Count -gt 0) {
    Write-Log "Failed    : $($failed.Count) / $total" "Red"
    Write-Host "  Failed    : $($failed.Count) / $total" -ForegroundColor Red
    foreach ($app in $failed) {
        Write-Log "  x $($app.name)" "Red"
        Write-Host "    x $($app.name)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "  Tip: Re-run the script to retry failed installs." -ForegroundColor Yellow
} else {
    Write-Log "All $total apps installed successfully!" "Green"
}

Write-Log "Log saved to $LogFile"
Write-Host ""
Write-Host "  Done! You may need to restart your terminal or PC for some apps." -ForegroundColor Cyan
Write-Host "  Run .\setup-desktop.ps1 next to configure your desktop islands." -ForegroundColor Cyan
Write-Host ""