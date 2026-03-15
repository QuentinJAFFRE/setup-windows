<#
.SYNOPSIS
    Desktop organizer setup - generates Desktop Fences+ islands from apps.json categories.

.DESCRIPTION
    - Reads apps.json to know which categories and apps exist
    - Scans Start Menu and Desktop for matching shortcuts
    - Generates a fences.json config for Desktop Fences+
    - Each apps.json category becomes a colored island on your desktop
    - Run this AFTER setup-apps.ps1 has installed everything

.USAGE
    .\setup-desktop.ps1              # Generate desktop islands
    .\setup-desktop.ps1 -DryRun     # Preview without writing config
    .\setup-desktop.ps1 -ConfigPath "C:\myapps.json"
#>

param(
    [switch]$DryRun,
    [string]$ConfigPath = ".\apps.json"
)

# -- Strict mode ---------------------------------------------------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -- Logging -------------------------------------------------------------------
$LogFile = ".\setup-desktop-log.txt"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] $Message"
    Write-Host $logLine -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logLine
}

# -- Banner --------------------------------------------------------------------
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host "       Desktop Islands Setup v1.0         " -ForegroundColor Magenta
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host ""

if ($DryRun) {
    Write-Host "  ** DRY RUN MODE -- no files will be written **" -ForegroundColor Yellow
    Write-Host ""
}

# -- Load apps config ----------------------------------------------------------
if (-not (Test-Path $ConfigPath)) {
    Write-Log "ERROR: Config file not found at $ConfigPath" "Red"
    Write-Log "Run setup-apps.ps1 first to install your apps." "Red"
    exit 1
}

$config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
Write-Log "Config loaded: $ConfigPath"

# -- Locate Desktop Fences+ ---------------------------------------------------
$PortableAppsDir = "$env:LOCALAPPDATA\PortableApps"
$dfFolder = Join-Path $PortableAppsDir "limbo666_DesktopFences"
$dfExe = Get-ChildItem -Path $dfFolder -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $dfExe) {
    Write-Log "ERROR: Desktop Fences+ not found in $dfFolder" "Red"
    Write-Log "Run setup-apps.ps1 first -- it installs Desktop Fences+ automatically." "Red"
    exit 1
}

Write-Log "Desktop Fences+ found at: $($dfExe.FullName)"

# -- Shortcut resolver ---------------------------------------------------------
$shortcutSearchPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
    [Environment]::GetFolderPath("Desktop")
)

function Find-ShortcutPath {
    param([string]$AppName)
    $cleanName = ($AppName -replace '\s*\(.*\)\s*', '').Trim()
    $searchTerms = @($cleanName, ($cleanName.Split(' ')[0]))

    foreach ($term in $searchTerms) {
        $escaped = [regex]::Escape($term)
        foreach ($searchPath in $shortcutSearchPaths) {
            if (-not (Test-Path $searchPath)) { continue }
            $found = Get-ChildItem -Path $searchPath -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.BaseName -match $escaped } |
                Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }
    return $null
}

# -- Build fences from categories ----------------------------------------------
Write-Log "Scanning for app shortcuts..."
Write-Host ""

$fenceColors = @("Teal", "Blue", "Purple", "Green", "Red", "Orange", "Bismark", "Fuchsia")
$colorIndex = 0

$fences = @()
$xPos = 20
$yPos = 20
$fenceWidth = 250
$fenceHeight = 300
$xSpacing = 270
$maxPerRow = 5
$colCount = 0

$totalFound = 0
$totalMissing = 0

foreach ($cat in $config.categories.PSObject.Properties) {
    $catName = $cat.Value.description
    $apps = $cat.Value.apps

    Write-Host "  [$($cat.Name)] $catName" -ForegroundColor Magenta

    $items = @()
    foreach ($app in $apps) {
        if ($app.manager -eq "github") {
            Write-Host "    [~~] $($app.name)  (portable, skipped)" -ForegroundColor DarkGray
            continue
        }

        $lnkPath = Find-ShortcutPath -AppName $app.name
        if ($lnkPath) {
            Write-Host "    [OK] $($app.name)" -ForegroundColor Green
            $items += @{
                Name   = $app.name
                Target = $lnkPath
            }
            $totalFound++
        } else {
            Write-Host "    [??] $($app.name)  (shortcut not found)" -ForegroundColor Yellow
            $totalMissing++
        }
    }

    if ($items.Count -gt 0) {
        $fence = @{
            Title    = $catName
            X        = $xPos
            Y        = $yPos
            Width    = $fenceWidth
            Height   = [math]::Max(120, 60 + ($items.Count * 50))
            Color    = $fenceColors[$colorIndex % $fenceColors.Count]
            Visible  = $true
            RolledUp = $false
            Items    = $items
        }
        $fences += $fence
        $colorIndex++
        $xPos += $xSpacing
        $colCount++

        if ($colCount -ge $maxPerRow) {
            $colCount = 0
            $xPos = 20
            $yPos += ($fenceHeight + 20)
        }
    }

    Write-Host ""
}

# -- Summary -------------------------------------------------------------------
Write-Host "  ----------------------------------------" -ForegroundColor Magenta
Write-Host "  Islands to create   : $($fences.Count)" -ForegroundColor Cyan
Write-Host "  Shortcuts found     : $totalFound" -ForegroundColor Green
if ($totalMissing -gt 0) {
    Write-Host "  Shortcuts missing   : $totalMissing" -ForegroundColor Yellow
} else {
    Write-Host "  Shortcuts missing   : 0" -ForegroundColor Green
}
Write-Host "  ----------------------------------------" -ForegroundColor Magenta
Write-Host ""

if ($fences.Count -eq 0) {
    Write-Log "No shortcuts found. Nothing to generate." "Yellow"
    Write-Log "Make sure apps are installed first (run setup-apps.ps1)." "Yellow"
    exit 0
}

# -- Preview -------------------------------------------------------------------
Write-Host "  Island layout:" -ForegroundColor White
foreach ($fence in $fences) {
    $appNames = ($fence.Items | ForEach-Object { $_.Name }) -join ", "
    Write-Host "    [$($fence.Color)] $($fence.Title): $appNames" -ForegroundColor White
}
Write-Host ""

# -- Dry run stops here --------------------------------------------------------
if ($DryRun) {
    Write-Log "[DRY RUN] Would generate fences.json with $($fences.Count) islands."
    Write-Host "  Run without -DryRun to write the config." -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# -- Write fences.json ---------------------------------------------------------
$fencesJsonPath = Join-Path $dfExe.DirectoryName "fences.json"

if (Test-Path $fencesJsonPath) {
    $backupPath = "$fencesJsonPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $fencesJsonPath -Destination $backupPath
    Write-Log "Existing fences.json backed up to: $backupPath" "DarkCyan"
}

$fences | ConvertTo-Json -Depth 5 | Set-Content -Path $fencesJsonPath -Encoding UTF8
Write-Log "fences.json written to: $fencesJsonPath" "Green"

# -- Done ----------------------------------------------------------------------
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host "         Desktop Islands Ready!            " -ForegroundColor Magenta
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Launch Desktop Fences+ to see your islands." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Note: The generated config is best-effort." -ForegroundColor Yellow
Write-Host "  If islands need tweaking, adjust them visually" -ForegroundColor Yellow
Write-Host "  then backup fences.json for future installs." -ForegroundColor Yellow
Write-Host ""

Write-Log "Log saved to $LogFile"
Write-Log "Desktop setup complete."