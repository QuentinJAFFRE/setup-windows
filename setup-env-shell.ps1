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
      dotfiles\komorebi\komorebi.json                       -> ~\.config\komorebi\komorebi.json
      (applications.json fetched at runtime via `komorebic fetch-asc`)
      dotfiles\whkd\whkdrc                                  -> ~\.config\whkdrc
      dotfiles\yasb\config.yaml                             -> ~\.config\yasb\config.yaml
      dotfiles\yasb\styles.css                              -> ~\.config\yasb\styles.css

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
    @{ src = "yazi\init.lua";                                dst = "$env:APPDATA\yazi\config\init.lua";                     required = $true  },
    @{ src = "wezterm\.wezterm.lua";                         dst = "$env:USERPROFILE\.wezterm.lua";                         required = $false },
    @{ src = "komorebi\komorebi.json";                       dst = "$env:USERPROFILE\.config\komorebi\komorebi.json";       required = $false },
    @{ src = "whkd\whkdrc";                                  dst = "$env:USERPROFILE\.config\whkdrc";                       required = $false },
    @{ src = "yasb\config.yaml";                             dst = "$env:USERPROFILE\.config\yasb\config.yaml";             required = $false },
    @{ src = "yasb\styles.css";                              dst = "$env:USERPROFILE\.config\yasb\styles.css";              required = $false }
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

# ----------------------------------------------------------------------------
# Ensure tool dirs are on the User PATH (idempotent).
# Some installers (e.g. komorebi MSI) don't update PATH automatically.
# We modify User PATH (not Machine) so this script never needs admin.
# ----------------------------------------------------------------------------
$pathEntries = @(
    "C:\Program Files\komorebi\bin",
    "C:\Program Files\whkd\bin",
    "C:\Program Files\YASB"
)

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($null -eq $userPath) { $userPath = "" }
$current  = $userPath -split ";" | Where-Object { $_ -ne "" }
$added    = @()

foreach ($entry in $pathEntries) {
    if (-not (Test-Path $entry)) { continue }
    if ($current -notcontains $entry) {
        if ($DryRun) {
            Write-Host "    [DRY RUN] would add to User PATH: $entry" -ForegroundColor Yellow
        } else {
            $current += $entry
            $added   += $entry
        }
    }
}

if (-not $DryRun -and $added.Count -gt 0) {
    $newPath = ($current -join ";")
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    foreach ($a in $added) {
        Write-Host "    [PATH+] $a" -ForegroundColor Green
    }
}

# ----------------------------------------------------------------------------
# Register komorebi autostart (Startup folder shortcut managed by komorebic).
# Generates komorebi.lnk in shell:startup with --whkd --bar and our config.
# Idempotent: komorebic overwrites the shortcut each run.
# ----------------------------------------------------------------------------
$komorebicCmd = Get-Command komorebic.exe -ErrorAction SilentlyContinue
$komoConfigDir = "$env:USERPROFILE\.config\komorebi"
$komoConfig    = "$komoConfigDir\komorebi.json"

# Set KOMOREBI_CONFIG_HOME durably (User env var). The Startup-folder shortcut
# launched by Windows at logon does not load PowerShell profile, so this var
# must live in the User env or komorebic.exe won't find komorebi.json.
$existingHome = [Environment]::GetEnvironmentVariable("KOMOREBI_CONFIG_HOME", "User")
if ($existingHome -ne $komoConfigDir) {
    if ($DryRun) {
        Write-Host "    [DRY RUN] would set User env KOMOREBI_CONFIG_HOME=$komoConfigDir" -ForegroundColor Yellow
    } else {
        [Environment]::SetEnvironmentVariable("KOMOREBI_CONFIG_HOME", $komoConfigDir, "User")
        $env:KOMOREBI_CONFIG_HOME = $komoConfigDir
        Write-Host "    [ENV+] KOMOREBI_CONFIG_HOME=$komoConfigDir" -ForegroundColor Green
    }
} else {
    $env:KOMOREBI_CONFIG_HOME = $komoConfigDir
}

if ($komorebicCmd -and (Test-Path $komoConfig)) {
    # Fetch community application-specific-configuration ruleset.
    # Provides tiling rules for ~200 common apps (Electron, JetBrains, browsers, etc.)
    # so apps like Claude/Discord/Spotify get managed instead of floating.
    # Idempotent: overwrites $KOMOREBI_CONFIG_HOME\applications.json each run.
    if ($DryRun) {
        Write-Host "    [DRY RUN] would run: komorebic fetch-asc" -ForegroundColor Yellow
    } else {
        try {
            & komorebic.exe fetch-asc | Out-Null
            Write-Host "    [OK] applications.json fetched (community ruleset)" -ForegroundColor Green
        } catch {
            Write-Host "    [WARN] komorebic fetch-asc failed: $_" -ForegroundColor Yellow
        }
    }

    if ($DryRun) {
        Write-Host "    [DRY RUN] would run: komorebic enable-autostart --whkd --bar" -ForegroundColor Yellow
    } else {
        try {
            & komorebic.exe enable-autostart --whkd --bar | Out-Null
            Write-Host "    [OK] komorebi autostart registered (Startup folder shortcut)" -ForegroundColor Green
        } catch {
            Write-Host "    [WARN] komorebic enable-autostart failed: $_" -ForegroundColor Yellow
        }
    }
} elseif (-not $komorebicCmd) {
    Write-Host "    [SKIP] komorebic.exe not on PATH; autostart not registered" -ForegroundColor DarkGray
}

Write-Host ""
if (-not $DryRun) {
    Write-Host "  Deployed $deployed file(s)." -ForegroundColor Green
    if ($missing -gt 0) {
        Write-Host "  Skipped $missing (source not present in dotfiles/)." -ForegroundColor DarkGray
    }
    if ($added.Count -gt 0) {
        Write-Host "  Added $($added.Count) entry(ies) to User PATH." -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "  Open a fresh PowerShell window for `$PROFILE / PATH changes to take effect." -ForegroundColor Cyan
    Write-Host ""
}
