# komorebi

**Purpose.** A tiling window manager for Windows 11 inspired by i3/bspwm. Replaces manual mouse window management: every new window is automatically arranged in a deterministic layout, you switch and move windows by keyboard. Komorebi is the daemon that does the tiling — it does **not** ship its own keybinding system; pair it with [whkd](whkd.md) for hotkeys and [yasb](yasb.md) for a status bar.

Config lives in `%USERPROFILE%\.config\komorebi\komorebi.json` and `applications.json`. Start with `komorebic start --whkd --bar`.

## 3 main use cases

### 1. Workspace-per-task focus
Press `Alt+1`..`Alt+9` to jump between workspaces. Workspace 1 = browser, 2 = editor, 3 = terminal, 4 = chat, etc. Apps you launch land on a workspace by rule (see `applications.json`), so you never have to re-arrange windows after a reboot.

### 2. Keyboard-only window movement
- `Alt+h/j/k/l` focus left/down/up/right window
- `Alt+Shift+h/j/k/l` swap windows in those directions
- `Alt+Shift+1`..`9` move focused window to that workspace
- `Alt+f` toggle floating for the current window (useful for dialogs)

### 3. Layout switching on the fly
Same workspace, different layouts: `bsp` (default binary tree), `columns`, `rows`, `vertical-stack`, `horizontal-stack`, `ultrawide-vertical-stack`. Switch via `komorebic change-layout <name>` or bind hotkeys. One window full-screen? `Alt+m` to toggle monocle.

## Trickery

- **Initial-only vs sticky rules.** `initial_workspace_rules` fires once when the app spawns (like i3 `assign`). `workspace_rules` is enforced continuously — the app keeps getting yanked back to its workspace if it tries to leave. Use sticky for things like Discord that you never want elsewhere; initial for editors you might temporarily move.
- **`komorebic enforce-workspace-rules`** re-applies all rules to currently-open windows — handy after editing `applications.json` without restarting.
- **`slow_application_compensation_time`** gives Electron / JetBrains apps a delay before the rule matches their final window title. Without it, splash screens get rule-matched and the real window doesn't.
- **Match by title, not process.** JetBrains and Electron apps share `idea64.exe` / `electron.exe` for many products. Use `title` regex (`"PyCharm.*"`) to disambiguate.
- **Community ruleset.** [komorebi-application-specific-configuration](https://github.com/LGUG2Z/komorebi-application-specific-configuration) has pre-tuned rules for ~200 apps. Subscribe to it via `app_specific_configuration_path` and you skip 90% of the rule-writing.
- **`komorebic stack-window`** stacks multiple windows in one tile — tab through them with `Alt+]`/`Alt+[`. Useful when 3 terminals belong on workspace 3 but you only want one visible.
- **Per-monitor workspaces.** Workspaces are scoped per monitor by default. Multi-monitor: workspace 1 on monitor A is independent of workspace 1 on monitor B. Switch monitor focus with `Alt+,` / `Alt+.`.
- **Lock the layout.** `Alt+Shift+space` toggles "tiling paused" — komorebi stops moving things. Useful when a screen-share tool refuses to behave.

## Gotchas

- Komorebi is free for personal use. **Commercial use requires a paid GitHub Sponsors tier** ($5/mo at komorebi-pro). This setup is personal so it's fine.
- Windows 11 only (Windows 10 mostly works but isn't supported).
- Some apps (UWP/Store apps, elevated-admin windows) won't tile cleanly. Add them to the `manage_rules: false` exclusion list rather than fighting it.
