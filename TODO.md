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
  - [ ] Final verify pass after env-shell split
- [~] **#3** Install WezTerm, verify, customize
  - [x] Install via winget (`wez.wezterm`)
  - [x] Launch confirmed
  - [ ] Author `dotfiles/wezterm/.wezterm.lua` (font=JetBrainsMono NF, multiplex keys, sane defaults)
  - [ ] Re-run `setup-env-shell.ps1` to deploy
  - [ ] Verify font rendering + multiplex keys
- [ ] **#2** Install komorebi + whkd + yasb, verify, customize
  - [ ] Install via winget (`LGUG2Z.komorebi`, `LGUG2Z.whkd`, `AmN.yasb`)
  - [ ] Author komorebi config + whkdrc
  - [ ] Author yasb config
  - [ ] Wire into `setup-env-shell.ps1` deploy map
  - [ ] Verify tiling + hotkeys + bar
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
