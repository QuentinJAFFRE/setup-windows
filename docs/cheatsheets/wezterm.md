# WezTerm

**Purpose.** GPU-accelerated terminal emulator with a **built-in multiplexer** (panes, tabs, persistent sessions) — no separate tmux needed. Cross-platform, single binary. Configured in Lua at `%USERPROFILE%\.wezterm.lua`.

## 3 main use cases

### 1. Multi-pane workflow without tmux
- `Ctrl+Shift+Alt+"` split horizontally · `Ctrl+Shift+Alt+%` split vertically
- `Ctrl+Shift+Arrow` move between panes
- `Ctrl+Shift+t` new tab · `Ctrl+Shift+w` close pane
- `Ctrl+Shift+z` zoom current pane (toggle full-tab)

### 2. Persistent SSH/dev sessions via the mux server
`wezterm-mux-server` runs detached. Reattach from any WezTerm window, even after a reboot, and your panes/tabs/working dirs are still there. `wezterm connect <name>` to attach to a remote mux server.

### 3. Drop-in replacement for cmd/PowerShell with sane defaults
Out of the box: true-color, ligatures, bold-as-bright off, scrollback in millions of lines, copy on selection, paste on right-click, hyperlinks clickable, image rendering (sixel + iTerm2 protocol), proper Unicode width handling.

## Trickery

- **`CTRL-SHIFT-Space` opens the command palette.** Like VSCode's. Fuzzy-search every action including ones not bound to keys.
- **Quick Select mode (`Ctrl+Shift+Space → quick_select`).** Highlights every URL/path/hash on screen with a 1-2 letter label. Type the label to copy to clipboard. Faster than mouse-selecting.
- **Copy mode (`Ctrl+Shift+x`).** Vim-like navigation in scrollback: `hjkl`, `w/b`, `/` to search, `v` to start selection, `y` to yank.
- **Workspaces.** Yes, the terminal has workspaces too. `Ctrl+Shift+Alt+w` switch workspace, each with its own set of tabs/panes. Confusingly named since komorebi also has workspaces — think of WezTerm workspaces as "project contexts."
- **Lua config = real programmability.** Conditional bindings ("on macOS, use Cmd; on Windows, use Ctrl"), dynamic colorschemes ("match system dark/light"), per-host SSH font size — all just Lua functions.
- **`wezterm imgcat foo.png`** renders an image inline in the terminal. Works with sixel-aware tools too (matplotlib, gnuplot).
- **`wezterm cli spawn`** opens a new tab/pane from outside (useful from scripts or whkd bindings).
- **Smart selection.** Double-click selects a word; triple-click selects a semantically smart unit (URL, path, IP). Configure regex in `wezterm.lua`.

## Gotchas

- Last stable release Feb 2024; **nightly builds ship daily** and are what most users run. Install via winget — winget tracks nightlies for `wez.wezterm`.
- Heavier startup than Windows Terminal (~150ms vs ~50ms) due to GPU init.
- The default font (JetBrains Mono) needs to be installed separately or it falls back; install a Nerd Font for icons in starship/eza.
