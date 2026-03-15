# PC Setup

Automated Windows PC setup: one config file, two scripts, everything installed and organized.

## What's in the box

```
apps.json            # App list with categories and package managers
setup-apps.ps1       # Installs all apps (winget, choco, GitHub)
setup-desktop.ps1    # Generates Desktop Fences+ islands from categories
```

## Quick start

```powershell
# 1. Open PowerShell as Administrator
# 2. Navigate to this folder
cd ~\Desktop\pc-setup

# 3. Allow script execution (current session only)
Set-ExecutionPolicy Bypass -Scope Process -Force

# 4. Preview what will be installed
.\setup-apps.ps1 -DryRun

# 5. Install everything
.\setup-apps.ps1

# 6. Generate desktop islands
.\setup-desktop.ps1
```

## setup-apps.ps1

Reads `apps.json`, checks what's already installed, and only installs what's missing.

Supports three install sources:
- **winget** - Microsoft's built-in package manager
- **choco** - Chocolatey (auto-installed if needed)
- **github** - Portable apps downloaded from GitHub releases

**Flags:**
| Flag | Description |
|------|-------------|
| `-DryRun` | Preview only, no changes |
| `-NoConfirm` | Skip the confirmation prompt |
| `-ConfigPath "path"` | Use a different config file |
| `-Categories "dev-tools","gaming"` | Install only specific categories |

**Examples:**
```powershell
.\setup-apps.ps1 -DryRun                          # Preview
.\setup-apps.ps1 -Categories "dev-tools"           # Dev tools only
.\setup-apps.ps1 -NoConfirm                        # No prompt, just install
```

## setup-desktop.ps1

Reads the same `apps.json`, scans for installed app shortcuts, and generates a `fences.json` config for [Desktop Fences+](https://github.com/limbo666/DesktopFences). Each category becomes a colored island on your desktop.

Run this **after** `setup-apps.ps1`.

**Flags:**
| Flag | Description |
|------|-------------|
| `-DryRun` | Preview islands without writing config |
| `-ConfigPath "path"` | Use a different config file |

## apps.json

Single source of truth. Organized by category:

| Category | Apps |
|----------|------|
| Film & Music | VLC, Sony Music Center |
| Gaming | Steam, Discord |
| Dev Tools | PyCharm Pro, Cursor, pyenv-win, Claude Desktop, Claude Code, Git, GitHub CLI |
| Infra | GlazeWM, Desktop Fences+ |
| Mail & Passwords | iCloud, Bitwarden |
| System Utilities | 7-Zip, WinSCP, PowerToys, Everything, Tailscale, WireGuard, TreeSize, Greenshot, Windows Terminal |

### Adding an app

Find the package ID:
```powershell
winget search "app name"    # for winget
choco search appname        # for chocolatey
```

Add an entry to the right category in `apps.json`:
```json
{ "name": "My App", "id": "Publisher.AppName", "manager": "winget" }
```

### Switching package manager

If an app downloads slowly via winget, switch it to choco (or vice versa). Just change the `manager` and `id` fields:

```json
// Slow via winget:
{ "name": "VLC", "id": "VideoLAN.VLC", "manager": "winget" }

// Faster via choco:
{ "name": "VLC", "id": "vlc", "manager": "choco" }
```

## Notes

- **Re-runnable**: Both scripts skip already-installed apps. Safe to run multiple times.
- **Logs**: `setup-log.txt` and `setup-desktop-log.txt` are generated in the same folder.
- **iCloud**: The winget package is the legacy version (v7.x). For the modern version, install from the Microsoft Store manually.
- **Desktop Fences+**: Portable app, no installer. Config is stored in `fences.json` next to the executable. After first setup, back up this file for future installs.
- **pyenv-win**: Installed via Chocolatey. You may need to restart your terminal and verify PATH is set correctly after install.
