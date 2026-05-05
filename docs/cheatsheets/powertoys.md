# PowerToys (selective)

**Purpose.** Microsoft-published bag of Windows utilities. We use **only the modules that don't overlap** with komorebi/yasb. Disable everything else to keep memory + key conflicts down.

## What to enable

| Module | Why |
|---|---|
| **PowerToys Run** | Spotlight/Alfred-style launcher (`Alt+Space`). Apps, calculator, unit conversion, web search, kill process, shell commands. |
| **Keyboard Manager** | Remap keys + shortcuts globally. Caps→Esc is the canonical use. |
| **PowerRename** | Right-click → batch regex rename across selected files. |
| **Awake** | Keep the machine awake (no sleep, screen-on toggle) without touching power settings. |

## What to disable

- **FancyZones** — komorebi owns tiling.
- **Workspaces** — overlaps with komorebi workspaces; will fight it.
- **Always On Top** — komorebi has its own pinning.
- **Mouse utilities, Color Picker, Screen Ruler, Hosts editor, etc.** — not core to the minimalist stack. Re-enable case by case if you find you need them.

## 3 main use cases

### 1. PowerToys Run as launcher
`Alt+Space`, type:
- `firefox` — launches Firefox
- `=2^32` — calculator (prefix `=`)
- `?? komorebi tiling` — web search (prefix `??`)
- `> ipconfig` — runs the command in a shell (prefix `>`)
- `:: docker` — kills processes matching "docker" (prefix `::`)

### 2. Caps → Esc via Keyboard Manager
Settings → Keyboard Manager → Remap a Key → CapsLock → Esc. Hours saved per week if you use vim/yazi.

### 3. Bulk rename screenshots
Select 50 files → right-click → PowerRename. Use regex `^Screenshot (\d+)` → `screen-$1`. Preview before applying.

## Trickery

- **PowerToys Run plugins.** `Settings → PowerToys Run → Plugins`. Enable "Window Walker" (fuzzy switch between open windows — way faster than alt-tab when you have 30 windows). Disable plugins you don't use; each one runs on every keystroke.
- **PowerRename regex with capture groups.** `(.*)\.jpg` → `$1.jpeg` does what you'd expect. Tick "Use regular expressions" or it stays literal.
- **Awake from CLI.** `PowerToys.Awake.exe --time 7200` keeps the machine awake for 2h then exits. Useful to drop in a long-running script.
- **Keyboard Manager scope.** Remaps can be global or app-scoped (only inside `code.exe`). Use app-scoped to avoid breaking other apps that rely on the original key.
- **Hotkey conflict with komorebi/whkd.** PowerToys Run defaults to `Alt+Space`, which is also a fine komorebi binding. If you bind `Alt+Space` in whkd, change PowerToys Run to `Win+Space` or similar.

## Gotchas

- PowerToys runs as a tray app and starts modules on demand. Disabled modules cost ~0 RAM. Enabled-but-idle modules cost a small amount each — keep it lean.
- Updates push frequently; check what's new occasionally for new modules worth enabling.
