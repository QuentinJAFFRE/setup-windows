# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Windows PC setup automation toolkit. A single `apps.json` configuration drives the PowerShell scripts:
1. `setup-apps.ps1` — installs all apps
2. `setup-desktop.ps1` — organizes the desktop using Desktop Fences+ (legacy; kept for the previous GlazeWM + Fences setup)
3. `setup-seelen.ps1` — applies the committed Seelen UI configuration from `seelen-config/` to `%APPDATA%\com.seelen.seelen-ui\`

## Running the Scripts

All scripts require an **admin PowerShell** session on Windows 10/11.

```powershell
# Install all apps
.\setup-apps.ps1

# Preview without installing
.\setup-apps.ps1 -DryRun

# Install specific categories only
.\setup-apps.ps1 -Categories "Dev Tools,Gaming"

# Skip confirmation prompt
.\setup-apps.ps1 -NoConfirm

# Use a different config file
.\setup-apps.ps1 -ConfigPath "path\to\custom-apps.json"

# Generate desktop fences configuration
.\setup-desktop.ps1

# Preview desktop config without writing
.\setup-desktop.ps1 -DryRun

# Apply committed Seelen UI config (after installing Seelen via setup-apps.ps1)
.\setup-seelen.ps1

# Preview Seelen config apply without writing
.\setup-seelen.ps1 -DryRun
```

## Updating the Seelen config

`seelen-config/` is the committed source of truth for Seelen UI. To update it:
1. Tune Seelen via its GUI on a working machine
2. Close Seelen (so it flushes config to disk)
3. Copy `%APPDATA%\com.seelen.seelen-ui\*` into `seelen-config/`
4. Review the diff and commit

## Architecture

**`apps.json`** is the single source of truth. It defines:
- `settings`: default log file path and default package manager (`winget` or `choco`)
- `categories`: named groups, each with a list of apps

Each app entry specifies:
```json
{
  "name": "App Name",
  "id": "Publisher.AppName",
  "source": "winget"   // winget | choco | github
}
```

**GitHub source apps** are treated as portable installs: the script downloads the latest `.zip` release to `%LOCALAPPDATA%\PortableApps`, extracts it, and creates a desktop shortcut.

**`setup-apps.ps1`** flow:
1. Auto-elevates to admin if needed
2. Loads `apps.json`
3. Detects already-installed apps (skips them)
4. Auto-installs Chocolatey if any `choco` apps are needed and choco isn't present
5. Installs missing apps, logs to `setup-log.txt`

**`setup-desktop.ps1`** flow:
1. Reads `apps.json` for category/app structure
2. Scans Start Menu and Desktop for matching shortcuts
3. Generates `fences.json` for Desktop Fences+ (backs up any existing config first)
4. Logs to `setup-desktop-log.txt`

## Adding Apps

To add an app, edit `apps.json` and add an entry to the appropriate category:

```json
{
  "name": "My App",
  "id": "Publisher.MyApp",
  "source": "winget"
}
```

Find winget IDs with `winget search <name>`, Chocolatey IDs with `choco search <name>`.
