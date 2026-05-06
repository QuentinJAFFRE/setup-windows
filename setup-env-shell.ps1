<#
.SYNOPSIS
    Deploys shell/env/PATH configuration (dotfiles) to the user profile.

.DESCRIPTION
    Single-purpose script: copies source-of-truth configs from .\dotfiles\
    into the locations each tool reads from.

      dotfiles\powershell\Microsoft.PowerShell_profile.ps1 -> $PROFILE
      dotfiles\starship\starship.toml                       -> ~\.config\starship.toml
      dotfiles\yazi\yazi.toml                               -> %APPDATA%\yazi\config\yazi.toml
      dotfiles\yazi\keymap.toml                             -> %APPDATA%\yazi\config\keymap.toml
      dotfiles\wezterm\.wezterm.lua                         -> ~\.wezterm.lua  (if present)

    Idempotent: copies overwrite. Run after setup-apps.ps1 + setup-scoop.ps1
    so the tools the configs target are already installed. Safe to re-run any
    time you tweak a dotfile.

.USAGE
    .\setup-env-shell.ps1
    .\setup-env-shell.ps1 -DryRun
    .\setup-env-shell.ps1 -DotfilesDir "C:\path\to\dotfiles"
#>

param(
    [switch]$DryRun,
    [string]$DotfilesDir = ".\dotfiles"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "        Shell / Env Setup                 " -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  ** DRY RUN MODE -- no changes will be made **" -ForegroundColor Yellow
    Write-Host ""
}

if (-not (Test-Path $DotfilesDir)) {
    Write-Host "  [!] Dotfiles directory not found: $DotfilesDir" -ForegroundColor Red
    exit 1
}

# (sourceRelativeToDotfiles, destinationAbsolute, requiredFlag)
# requiredFlag=$false means silently skip if source missing (e.g. wezterm before installed).
$dotfileMap = @(
    @{ src = "powershell\Microsoft.PowerShell_profile.ps1"; dst = $PROFILE;                                                required = $true  },
    @{ src = "starship\starship.toml";                       dst = "$env:USERPROFILE\.config\starship.toml";                required = $true  },
    @{ src = "yazi\yazi.toml";                               dst = "$env:APPDATA\yazi\config\yazi.toml";                    required = $true  },
    @{ src = "yazi\keymap.toml";                             dst = "$env:APPDATA\yazi\config\keymap.toml";                  required = $true  },
    @{ src = "wezterm\.wezterm.lua";                         dst = "$env:USERPROFILE\.wezterm.lua";                         required = $false }
)

$deployed = 0
$missing  = 0

foreach ($entry in $dotfileMap) {
    $srcPath = Join-Path $DotfilesDir $entry.src
    $dstPath = $entry.dst

    if (-not (Test-Path $srcPath)) {
        if ($entry.required) {
            Write-Host "    [SKIP] source missing: $($entry.src)" -ForegroundColor DarkGray
        }
        $missing++
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
    if ($missing -gt 0) {
        Write-Host "  Skipped $missing (source not present in dotfiles/)." -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Open a fresh PowerShell window for `$PROFILE changes to take effect." -ForegroundColor Cyan
    Write-Host ""
}
