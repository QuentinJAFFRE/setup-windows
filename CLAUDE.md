# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Windows PC setup automation toolkit. A single `apps.json` configuration drives three PowerShell scripts:
1. `setup-apps.ps1` — installs winget/choco/github apps (admin)
2. `setup-scoop.ps1` — installs scoop apps (non-admin; scoop refuses elevation)
3. `setup-desktop.ps1` — organizes the desktop using Desktop Fences+

A minimalist developer stack (komorebi tiling WM, WezTerm, yazi, Nerd Fonts, CLI tools) lives in the `dev-environment` category. Per-tool cheat sheets are in `docs/cheatsheets/`.

## Running the Scripts

```powershell
# 1. Install winget/choco/github apps (auto-elevates to admin)
.\setup-apps.ps1

# 2. Install scoop apps (must be a NON-admin shell)
.\setup-scoop.ps1

# Preview without installing
.\setup-apps.ps1 -DryRun
.\setup-scoop.ps1 -DryRun

# Install specific categories only
.\setup-apps.ps1 -Categories "dev-environment","dev-tools"

# Skip confirmation prompt (setup-apps.ps1 only)
.\setup-apps.ps1 -NoConfirm

# Use a different config file
.\setup-apps.ps1 -ConfigPath "path\to\custom-apps.json"

# Generate desktop fences configuration
.\setup-desktop.ps1
.\setup-desktop.ps1 -DryRun
```

Scoop must be pre-installed by the user — see [docs/cheatsheets/scoop.md](docs/cheatsheets/scoop.md). `setup-apps.ps1` will fail fast with install instructions if scoop apps are configured but scoop isn't on PATH.

## Architecture

**`apps.json`** is the single source of truth. It defines:
- `settings`: default log file path and default package manager
- `categories`: named groups, each with a list of apps

Each app entry specifies:
```json
{
  "name": "App Name",
  "id": "Publisher.AppName",
  "manager": "winget"   // winget | choco | scoop | github | manual
}
```

- **winget / choco / scoop**: package-manager IDs — `winget search <name>`, `choco search <name>`, `scoop search <name>`
- **github**: portable install. The script downloads the latest `.zip` release to `%LOCALAPPDATA%\PortableApps`, extracts it, creates a desktop shortcut. `id` is the `owner/repo` slug.
- **manual**: app cannot be automated (e.g. login required). The script lists it but does not install.

**`setup-apps.ps1`** flow:
1. Auto-elevates to admin if needed
2. Loads `apps.json`
3. Detects already-installed apps (skips them)
4. Auto-installs Chocolatey if any `choco` apps are needed and choco isn't present
5. Errors out if any `scoop` apps are configured and scoop is missing (see Scoop note above)
6. Installs missing winget/choco/github apps, **skips scoop apps** (admin can't run scoop)
7. Logs to `setup-log.txt`

**`setup-scoop.ps1`** flow:
1. Refuses to run if elevated
2. Verifies scoop is installed
3. Adds `extras` and `nerd-fonts` buckets if missing
4. Installs every `scoop`-managed app from `apps.json` that isn't already installed

**`setup-desktop.ps1`** flow:
1. Reads `apps.json` for category/app structure
2. Scans Start Menu and Desktop for matching shortcuts
3. Generates `fences.json` for Desktop Fences+ (backs up any existing config first)
4. Logs to `setup-desktop-log.txt`

## Adding Apps

Add an entry to the appropriate category in `apps.json`. Find IDs with the manager's search command. For scoop apps that come from non-default buckets (e.g. `extras`, `nerd-fonts`), `setup-scoop.ps1` registers those buckets automatically.

## PowerToys note

PowerToys is installed via `system-utilities`. For the minimalist dev stack, **disable FancyZones and Workspaces** after install — komorebi owns tiling. See [docs/cheatsheets/powertoys.md](docs/cheatsheets/powertoys.md) for the full enable/disable list.
