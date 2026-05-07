# komorebi

**Purpose.** A tiling window manager for Windows 11 inspired by i3/bspwm. Replaces manual mouse window management: every new window is automatically arranged in a deterministic layout, you switch and move windows by keyboard. Komorebi is the daemon that does the tiling — it does **not** ship its own keybinding system; pair it with [whkd](whkd.md) for hotkeys and [yasb](yasb.md) for a status bar.

Config lives in `%USERPROFILE%\.config\komorebi\komorebi.json` and `applications.json`. Start with `komorebic start --whkd --bar`.

## Config files

Two files in `$KOMOREBI_CONFIG_HOME` (= `%USERPROFILE%\.config\komorebi`):

### `komorebi.json` — your daemon config (checked into dotfiles)
Defines monitors, workspaces, layouts, padding, borders, animation, stackbar, and the path to `applications.json`. Source of truth in `dotfiles/komorebi/komorebi.json`; `setup-env-shell.ps1` deploys it. Key fields:

| Field | Purpose |
|-------|---------|
| `app_specific_configuration_path` | Path to `applications.json`. Use `$Env:KOMOREBI_CONFIG_HOME/applications.json`. |
| `window_hiding_behaviour` | `Cloak` (recommended) hides off-workspace windows via DWM cloaking — invisible to alt-tab. `Hide`/`Minimize` are alternatives. |
| `cross_monitor_move_behaviour` | `Insert` vs `Swap` when moving windows across monitors. |
| `default_workspace_padding` / `default_container_padding` | Outer / inner gaps in pixels. |
| `border` + `border_width` + `border_offset` + `border_colours` | Focused-window outline. `border_offset: -1` overlaps client edge by 1px so it sits flush. |
| `stackbar` | Tab strip rendered when windows are stacked (`OnStack` shows only when ≥2 stacked). |
| `animation` | `style` = `Linear`, `EaseOutQuad`, `EaseOutCubic`, etc. Disable on slow GPU. |
| `monitors[].workspaces[]` | Per-workspace `name` + `layout` (`BSP`, `Columns`, `Rows`, `VerticalStack`, `HorizontalStack`, `UltrawideVerticalStack`). |

Reload after edit: `komorebic reload-configuration`.

### `applications.json` — per-app rules (fetched, not hand-written)
Contains `manage_rules`, `float_rules`, `initial_workspace_rules`, `slow_application_compensation_time` entries for ~200 known apps. **Don't edit by hand.** `setup-env-shell.ps1` runs `komorebic fetch-asc` to download the latest community ruleset from [komorebi-application-specific-configuration](https://github.com/LGUG2Z/komorebi-application-specific-configuration). Re-fetch any time:

```powershell
komorebic fetch-asc
komorebic reload-configuration
```

Add **personal** overrides directly inside `komorebi.json` (e.g. `workspace_rules`, `float_rules`) — those survive `fetch-asc` overwrites.

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
