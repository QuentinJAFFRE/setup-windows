# Files

**Purpose.** Modern, MIT-licensed replacement for Windows Explorer. Tabs, dual-pane, columns view, Git integration, Fluent design. Use this when you want a GUI; use [yazi](yazi.md) when you want speed.

## 3 main use cases

### 1. Tabbed file browsing
`Ctrl+T` new tab, `Ctrl+W` close tab, `Ctrl+Shift+T` reopen last closed tab. Drag tabs between Files windows. Replaces "open 5 explorer windows" with one window of tabs.

### 2. Dual-pane copy/move
Layout menu → "Dual Pane." Drag between panes, or `F5` copy / `F6` move with both panes visible. Faster than copy-paste-navigate.

### 3. Columns view (Miller columns)
Layout menu → "Columns." Each click on a folder opens a new column to its right, like macOS Finder columns view. Great for navigating deep trees while seeing the path you came from.

## Trickery

- **Quick Access pinning.** Pin frequently-used folders to the sidebar by drag or right-click → Pin to Sidebar. Replaces hunting through `C:\Users\…\Projects\…`.
- **Tags.** Right-click → tag a file/folder with a color. Filter by tag from the sidebar. Cross-folder organization without moving files.
- **Built-in archive support.** Browse inside `.zip`/`.7z` like a folder, no extract step. `Ctrl+E` to extract.
- **Git status in file listings.** Open a git repo, Files shows the status icon (modified, untracked) next to each file. No need to `git status` for a glance.
- **Hash files in-place.** Right-click → Properties → Hashes tab. MD5/SHA1/SHA256/SHA384/SHA512 computed without extra tools.
- **Preview pane.** `Ctrl+P` toggle. Shows image/PDF/text preview without opening — fast triage.
- **`Ctrl+Shift+N` new folder, `Ctrl+Shift+\`** open in terminal. The terminal opens to the current path with whichever shell you set in Settings → Terminals (point it at WezTerm).

## Gotchas

- Slower than native Explorer for large folders (10k+ items). Use yazi for those.
- Some shell extensions (Dropbox status, OneDrive) integrate less cleanly than in Explorer. Acceptable tradeoff.
- Updates via the Microsoft Store by default. Winget install gives you manual control.
