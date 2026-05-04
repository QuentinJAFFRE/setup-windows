# Seelen UI Config

Committed Seelen UI configuration applied by `setup-seelen.ps1`.

## Layout

Files here mirror `%APPDATA%\com.seelen.seelen-ui\`. `setup-seelen.ps1` copies
the contents of this folder over that directory (after backing up the existing
one).

Expected files (Seelen creates them on first run — capture them after tuning):

- `settings.json` — main settings: enabled modules, hotkeys, performance flags
- `themes/` — custom themes
- `layouts/` — WM layout definitions (YAML)
- `placeholders/` — toolbar layouts (YAML, per-monitor)

If a subfolder is missing here, `setup-seelen.ps1` leaves the corresponding
target subfolder untouched.

## Workflow: capture → commit

1. Install Seelen UI (`.\setup-apps.ps1`).
2. Open Seelen, tune modules / hotkeys / theme through its GUI.
3. Close Seelen so it flushes config to disk.
4. Copy `%APPDATA%\com.seelen.seelen-ui\*` into this folder.
5. Review the diff, commit.

## Performance defaults to set

On 16 GB RAM, before capturing the config, disable:

- Media module
- Widgets layer (unless actively used)

And set:

- Animation framerate: 30 fps
- Performance mode: on

This brings the footprint from ~500–700 MB down to ~250–350 MB.
