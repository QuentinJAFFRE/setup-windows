<#
.SYNOPSIS
    Apply the committed Seelen UI configuration from seelen-config/ to %APPDATA%.

.DESCRIPTION
    - Verifies Seelen UI is installed (via winget)
    - Backs up the existing %APPDATA%\com.seelen.seelen-ui\ to a timestamped folder
    - Copies seelen-config/* over it
    - Restarts Seelen so it picks up the new config

.USAGE
    .\setup-seelen.ps1            # Apply config
    .\setup-seelen.ps1 -DryRun    # Show what would change, no writes
#>

param(
    [switch]$DryRun,
    [string]$ConfigDir = ".\seelen-config"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$LogFile = ".\setup-seelen-log.txt"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Write-Host $logLine -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logLine
}

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "         Seelen UI Config Apply           " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  ** DRY RUN MODE -- no changes will be made **" -ForegroundColor Yellow
    Write-Host ""
}

Write-Log "Script started. Config dir: $ConfigDir"

# -- Verify config dir exists --------------------------------------------------
if (-not (Test-Path $ConfigDir)) {
    Write-Log "ERROR: Config directory not found at $ConfigDir" "Red"
    exit 1
}

$configEntries = Get-ChildItem -Path $ConfigDir -Force | Where-Object { $_.Name -ne "README.md" }
if ($configEntries.Count -eq 0) {
    Write-Log "ERROR: $ConfigDir is empty. Capture a working Seelen config first (see seelen-config/README.md)." "Red"
    exit 1
}

# -- Verify Seelen is installed ------------------------------------------------
$seelenInstalled = $false
try {
    $result = winget list --id "Seelen.SeelenUI" --exact --accept-source-agreements 2>$null
    if ($result | Select-String -Pattern "Seelen.SeelenUI" -Quiet) {
        $seelenInstalled = $true
    }
} catch { }

if (-not $seelenInstalled) {
    Write-Log "ERROR: Seelen UI is not installed. Run .\setup-apps.ps1 first." "Red"
    exit 1
}
Write-Log "Seelen UI detected." "Green"

# -- Stop running Seelen processes ---------------------------------------------
$seelenProcs = Get-Process -Name "seelen-ui" -ErrorAction SilentlyContinue
if ($seelenProcs) {
    Write-Log "Stopping running Seelen UI ($($seelenProcs.Count) process(es))..." "Yellow"
    if (-not $DryRun) {
        $seelenProcs | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
}

# -- Back up existing config ---------------------------------------------------
$targetDir = Join-Path $env:APPDATA "com.seelen.seelen-ui"
if (Test-Path $targetDir) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "$targetDir.bak-$stamp"
    Write-Log "Backing up existing config: $targetDir -> $backupDir" "Yellow"
    if (-not $DryRun) {
        Copy-Item -Path $targetDir -Destination $backupDir -Recurse -Force
    }
} else {
    Write-Log "No existing config at $targetDir (first-time apply)." "DarkGray"
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
}

# -- Copy committed config over the target -------------------------------------
Write-Log "Applying config from $ConfigDir to $targetDir..."
foreach ($entry in $configEntries) {
    $dest = Join-Path $targetDir $entry.Name
    Write-Host "    -> $($entry.Name)" -ForegroundColor DarkCyan
    if (-not $DryRun) {
        if ($entry.PSIsContainer) {
            Copy-Item -Path $entry.FullName -Destination $dest -Recurse -Force
        } else {
            Copy-Item -Path $entry.FullName -Destination $dest -Force
        }
    }
}
Write-Log "Config applied." "Green"

# -- Relaunch Seelen -----------------------------------------------------------
if (-not $DryRun) {
    $seelenExe = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter "seelen-ui.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $seelenExe) {
        $seelenExe = Get-ChildItem -Path "$env:ProgramFiles\Seelen" -Filter "seelen-ui.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($seelenExe) {
        Write-Log "Relaunching Seelen UI: $($seelenExe.FullName)" "Green"
        Start-Process -FilePath $seelenExe.FullName
    } else {
        Write-Log "Seelen UI executable not found automatically. Launch it manually from the Start Menu." "Yellow"
    }
}

Write-Host ""
Write-Log "Done." "Green"
Write-Host ""
