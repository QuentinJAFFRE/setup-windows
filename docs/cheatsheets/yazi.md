# yazi

**Purpose.** Blazing-fast TUI file manager (Rust, async). Vim keys, image previews in the terminal, tabs, integration with fzf/zoxide/ripgrep. Where you actually live for keyboard-driven file ops. Configured at `%APPDATA%\yazi\config\yazi.toml` (and `keymap.toml`, `theme.toml`).

Launch: `yazi` in any terminal.

## 3 main use cases

### 1. Vim-style navigation + preview
- `h/j/k/l` left/down/up/right (l = enter, h = parent)
- `gg` top, `G` bottom, `/` search, `n/N` next/prev match
- Right pane shows live preview: text (with bat highlighting), images (sixel/Kitty graphics), videos (first frame), archives (contents listing), PDFs.

### 2. Visual select + bulk operations
- `Space` toggle select, `v` enter visual mode (range select)
- `y` yank · `x` cut · `p` paste · `d` delete · `a` create file/dir
- Operations are async — copy a 10GB folder, keep navigating while it copies, status shown in tasks pane (`w` to view).

### 3. Bulk rename via `$EDITOR`
Select files (`Space`/`v`) → press `r` → yazi opens your `$EDITOR` (vim) with one filename per line. Edit, save, quit. Renames apply atomically. The killer feature for batch renames where regex is awkward.

## Trickery

- **Z key = zoxide jump.** `z <query> Enter` jumps to a frecency-ranked directory. Combined with `Z` (interactive zoxide+fzf), best directory navigation on any platform.
- **Tabs.** `t` new tab, `1`..`9` jump to tab N, `[`/`]` prev/next tab. Yazi tabs are independent CWDs — perfect for compare/move workflows.
- **Find via fd + fzf.** `f` opens fzf-filtered file picker; `F` for content (ripgrep). Both honor `.gitignore`. Faster than walking the tree.
- **Plugins.** `package.toml` lets you add community plugins: git status overlay, mount manager, archive previewer extensions, sudo wrapper. Install with `ya pack -a <plugin>`.
- **Shell command on selection.** `:` opens command line, `$0` is current, `$@` is selected. `: ffmpeg -i $0 out.mp4` runs ffmpeg on what's highlighted.
- **`Ctrl-N`** drag-and-drop selection out to other GUI apps (drops the actual file refs).
- **Open with…** `o` shows ranked openers from your config (e.g. images → `imv`, .md → `glow`, code → `wezterm + vim`). Configurable per file extension.
- **`q` quits, `Q` quits AND `cd`s the parent shell** to yazi's current dir (needs a small shell wrapper — see yazi docs "shell wrapper").

## Gotchas

- Image preview on Windows requires a terminal that supports sixel/Kitty graphics. WezTerm does — Windows Terminal does not. If previews don't work, that's why.
- The `q`-vs-`Q` shell-cwd trick needs a wrapper function in your shell profile. Without it, exiting yazi leaves you in the shell's original directory.
- File operations don't go through Recycle Bin by default. `delete = trash` in `yazi.toml` if you want safety net.
