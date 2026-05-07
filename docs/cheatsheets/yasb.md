# yasb

**Purpose.** Yet Another Status Bar — a configurable top/bottom bar for Windows that shows workspaces, focused window, clock, CPU/memory, weather, media, etc. Pairs with komorebi (subscribes to its events to highlight the active workspace). Configured in YAML/Python at `%USERPROFILE%\.config\yasb\config.yaml` and styled with CSS at `styles.css`.

## 3 main use cases

### 1. komorebi workspace indicator
The `komorebi_workspaces` widget shows `1 2 3 4 …` and highlights the active one. It updates instantly because it subscribes to the komorebi event socket. This is the single most useful widget for tiling.

### 2. System telemetry at a glance
Built-in widgets: `cpu`, `memory`, `disk`, `battery`, `wifi`, `bluetooth`, `volume`, `weather`, `date`, `clock`. Configure update intervals per widget; expensive ones (network calls) at 60s, cheap ones (CPU) at 1s.

### 3. Active window / focused process
The `active_window` widget shows the focused window's title. Combined with workspace indicator, you always know "where am I and what is focused" without alt-tabbing.

## Trickery

- **CSS theming is full CSS.** `styles.css` accepts gradients, hover states, transitions, custom fonts. Easiest way to make the bar feel native: pull system accent color via CSS variable.
- **Per-monitor bars.** Configure separate bar instances per monitor in `config.yaml` — different widget sets per screen (status on the laptop, media on the external).
- **Custom widgets via the `custom` widget.** Run any shell command on an interval and render its stdout. E.g. show current git branch in CWD, count of unread emails, current Spotify track from `nowplaying-cli`.
- **Click actions.** Most widgets accept `callbacks` — left-click on the clock to open Outlook, right-click on volume to open mixer.
- **Hide on fullscreen.** `bar.config.always_on_top: false` plus `auto_hide` lets the bar disappear when an app goes fullscreen — important for video and games.

## Gotchas

- Python-based: yasb runs a Python interpreter, so cold-start is ~1s slower than a Rust bar. Once running, it's fine.
- If komorebi is not running, the workspaces widget shows nothing rather than erroring. Start order matters: `komorebic start --whkd --bar` handles it for you.
