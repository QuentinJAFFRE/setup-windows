# fzf

**Purpose.** General-purpose interactive fuzzy finder. Reads lines from stdin, lets you type to fuzzy-filter, prints what you select. Composes with everything: file lists, command history, git branches, processes, kubectl resources.

## 3 main use cases

### 1. File picker
```
fd --type f | fzf | xargs code
vim $(fzf)
```

### 2. Shell history search (Ctrl-R replacement)
```
# In PowerShell with PSFzf:
Ctrl-R              # fuzzy reverse history
# In bash/zsh with fzf keybindings:
Ctrl-R              # same — replaces default Ctrl-R
Ctrl-T              # fuzzy file picker into command line
Alt-C               # fuzzy cd into selected directory
```

### 3. Git workflow
```
git checkout $(git branch | fzf)
git log --oneline | fzf | awk '{print $1}' | xargs git show
gh pr list | fzf | awk '{print $1}' | xargs gh pr checkout
```

## Trickery

- **Preview window.** `fzf --preview 'bat --color=always {}'` — file picker with live syntax-highlighted preview. Bind `?` to toggle: `--bind '?:toggle-preview'`.
- **Multi-select.** `fzf -m` — `Tab` to mark multiple, `Enter` to return all. `xargs` them downstream.
- **Exact match.** Prefix query with `'` for exact, `^` for prefix, `$` for suffix, `!` for negation. `'foo !bar.test` = files containing "foo" but not "bar.test".
- **`--height` mode.** `fzf --height 40% --reverse` opens fzf as a 40% bottom panel rather than fullscreen. Less jarring inside an existing terminal.
- **Custom keybindings inside fzf.** `--bind 'ctrl-y:execute-silent(echo {} | clip)+abort'` — Ctrl-Y copies the selected line to clipboard.
- **Two-step search (ripgrep → fzf).** Live-search file *contents*: `rg --line-number --no-heading "" | fzf --delimiter : --preview 'bat --color=always {1} --line-range {2}:'`. Type a pattern, see matching lines, see file preview centered on the match. Bind to a key (Ctrl-G is conventional).
- **Tmux/WezTerm popup.** `fzf-tmux -p` opens fzf in a popup pane that closes on selection. WezTerm has similar via the multiplexer.
- **`FZF_DEFAULT_COMMAND` env var.** Set to `fd --type f --hidden --no-ignore` and bare `fzf` (no stdin) uses it. Default is the system `find`, which is slow.

## Gotchas

- Without keybindings configured, fzf is just a `cmd | fzf` filter — its real power is the shell integration. PSFzf for PowerShell, fzf's own `key-bindings.bash`/`zsh` for Unix shells. Source them in your profile.
- The default fuzzy algorithm matches characters in order, not as a substring. "ssh" matches `Set-StackHash` because s, s, h all appear in order. Use `'` prefix for substring matching.
