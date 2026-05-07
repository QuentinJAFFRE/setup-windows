# TODO — Minimalist Dev Stack (branch `feat/minimalist-dev-stack`)

Iterative install plan. One tool at a time: install → verify → customize → next.

## Run order

1. `.\setup-apps.ps1`         — winget/choco/github (admin)
2. `.\setup-scoop.ps1`        — scoop apps (non-admin)
3. `.\setup-env-shell.ps1`    — deploy dotfiles to user profile
4. `.\setup-desktop.ps1`      — desktop fences (optional)

## Tasks

- [x] **#1** Draft cheat sheets for stack tools (`docs/cheatsheets/`)
- [x] **#9** Wire up `apps.json` + scoop source in `setup-apps.ps1`
- [x] **#10** Extract dotfile deploy into `setup-env-shell.ps1`
- [~] **#6** Install Scoop + CLI tools, verify, customize
  - [x] Scoop installed
  - [x] CLI tools installed (ripgrep, fd, fzf, bat, eza, jq, vim, zoxide, starship, yazi, file, JetBrainsMono-NF)
  - [x] Dotfiles deployed (PowerShell profile, starship, yazi)
  - [x] yazi MIME fix (`file` package)
  - [x] Final verify pass after env-shell split
- [x] **#3** Install WezTerm, verify, customize
  - [x] Install via winget (`wez.wezterm`)
  - [x] Launch confirmed
  - [x] Author `dotfiles/wezterm/.wezterm.lua` (PowerShell default, JetBrainsMono NF, Tokyo Night, acrylic, multiplex keys)
  - [x] Deploy via `setup-env-shell.ps1`
  - [x] Verify font rendering + multiplex keys
  - [x] Fix starship Python stub warn (added `Python.Python.3.12` to apps.json, `python_binary = ["py"]` in starship.toml)
- [~] **#2** Install komorebi + whkd + yasb, verify, customize
  - [x] Install via winget (`LGUG2Z.komorebi`, `LGUG2Z.whkd`, `AmN.yasb`)
  - [x] Author komorebi config + whkdrc
  - [x] Author yasb config
  - [x] Wire into `setup-env-shell.ps1` deploy map
  - [x] PATH wired (komorebi/whkd/yasb bin dirs in User PATH)
  - [x] Stack launched (`komorebic start --whkd --bar`)
  - [x] whkd shell switched to `cmd` (workspace switching was slow under `pwsh`)
  - [x] yasb bar styling reverted to minimal (custom CSS dropped per feedback)
  - [x] PowerToys FancyZones killed (was conflicting with komorebi keybinds + tiling)
  - [x] whkdrc fixed for whkd 0.2+ key names (`oem_minus`/`oem_plus`/`oem_4`/`oem_6`/`oem_comma`/`oem_period`)
  - [x] Autostart at logon: `komorebic enable-autostart --whkd --bar` wired into `setup-env-shell.ps1`; `KOMOREBI_CONFIG_HOME` set as User env var
  - [x] applications.json migrated to v0.1.41 schema (rules moved into komorebi.json top-level)
  - [ ] Disable FancyZones permanently in PowerToys Settings (auto-restarts otherwise)
  - [ ] Verify after reboot: 9 workspaces in yasb, alt+1..9 focus, alt+shift+N move
  - [ ] Tune `applications.json` workspace assignments after real usage
  - [ ] Known issue: local `komorebi.exe` restart fails w/ os error 1920 (stale AF_UNIX `komorebi.sock` reparse point in `%LOCALAPPDATA%\komorebi`); reboot clears it
- [ ] **#4** Install Files + yazi, verify, customize
  - [x] yazi installed + customized
  - [ ] Files (winget `Files-Community.Files`) install + verify
- [ ] **#5** Install PowerToys (selective), verify, customize
  - [ ] Install via winget
  - [ ] **Disable FancyZones + Workspaces** (komorebi owns tiling)
  - [ ] Enable: PowerToys Run, Keyboard Manager, Color Picker, Awake (per cheat sheet)
- [ ] **#7** Install WSL2 + Ubuntu, verify
- [ ] **#8** Install Sysinternals Suite, verify

## Open decisions

- WezTerm `.wezterm.lua` location: `~/.wezterm.lua` chosen (vs `~/.config/wezterm/wezterm.lua`) — simpler.
- Starship: still no Nerd Font glyphs in prompt; revisit after WezTerm font verified.

## Done log

- 2026-05-05 — Scoop + dev-environment category committed
- 2026-05-05 — Dotfiles infrastructure + auto-deploy committed
- 2026-05-06 — `file` utility added for yazi MIME (`fix:` commit)
- 2026-05-06 — Dotfile deploy extracted into `setup-env-shell.ps1`
- 2026-05-06 — komorebi + whkd + yasb stack launched; whkd shell→`cmd`, yasb Tokyo Night `styles.css`
- 2026-05-06 — yasb restyled to AmN WinUI11 theme + komorebi workspace widget; FancyZones killed (conflict)
