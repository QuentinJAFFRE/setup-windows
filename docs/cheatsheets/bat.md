# bat

**Purpose.** `cat` clone with **syntax highlighting**, **line numbers**, **Git diff markers**, automatic paging. The default tool for "show me this file in a readable way."

## 3 main use cases

### 1. View a file
```
bat config.yaml                  # highlighted + line numbers + paged
bat --plain README.md            # no decorations (cat-like)
bat -A weird.txt                 # show non-printable chars (tabs, CR)
```

### 2. Pipe through it
```
curl -s https://api.github.com/repos/me/repo | bat -l json
echo '{"x":1}' | bat -l json
git show HEAD:src/main.rs | bat -l rust
```

### 3. As a previewer for fzf / yazi
```
fzf --preview 'bat --color=always --style=numbers {}'
```
yazi uses bat by default for text previews.

## Trickery

- **`--style=…`.** Compose decorations: `numbers,changes,header,grid`. `--style=plain` is just text. Set `BAT_STYLE` env var as your default.
- **Themes.** `bat --list-themes` shows all bundled themes. Set `BAT_THEME=ansi` to inherit terminal colors instead of bat's palette.
- **Diff awareness.** Inside a git repo, bat shows `+` / `~` / `-` markers in the gutter for uncommitted changes. Combine with `git diff | bat -l diff` for paged colored diffs.
- **Custom syntaxes.** Drop a Sublime `.sublime-syntax` file in `bat --config-dir`/syntaxes, run `bat cache --build`. Now `bat my.weirdfile` highlights it.
- **`bat --pager 'less -R'`** — explicit pager. Default is `less` with the right flags for color preservation. Set `BAT_PAGER` to override.
- **Use as `MANPAGER`.** `export MANPAGER="sh -c 'col -bx | bat -l man -p'"` (or PowerShell equivalent) — colored man pages.
- **`-L` (`--line-range`).** `bat -r 50:80 src/main.rs` shows lines 50–80. `-r 50:` from line 50 to end. `-r :80` start to line 80.
- **`bat -d`** highlights only changed lines (vs git HEAD). Fast "what did I change here?" view.

## Gotchas

- On Windows, the binary is sometimes `bat.exe` and sometimes `batcat` depending on installer (rare on Windows; this is a Debian thing). Scoop's is `bat`.
- Auto-paging surprises scripts: when piped to another command, bat detects no TTY and prints raw. When you *want* to disable paging in a TTY, use `--paging=never` or pipe to `cat`.
- `bat` will not be `cat` — symlinking it as `cat` breaks scripts that expect plain output. Don't.
