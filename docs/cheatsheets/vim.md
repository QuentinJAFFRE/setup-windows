# vim

**Purpose.** Modal text editor available in every terminal everywhere. Used here as: (a) `$EDITOR` for git commit messages, gh PR bodies, yazi bulk-rename, etc; (b) quick file edits without leaving the terminal.

This is a survival cheat sheet, not a vim tutorial. If you want to go deep, run `vimtutor` once.

## 3 main use cases

### 1. Edit a file, save, quit
```
vim file.txt
i               # insert mode
…type…
Esc             # back to normal mode
:w              # save
:q              # quit
:wq             # save+quit
:q!             # quit without saving
ZZ              # save+quit (alt to :wq)
```

### 2. Navigate without arrow keys
```
h j k l         # left/down/up/right
w / b           # word forward / back
0 / $           # line start / end
gg / G          # top / bottom of file
/foo Enter      # search forward
?foo Enter      # search back
n / N           # next / prev match
%               # jump to matching bracket
```

### 3. Edit operations
```
x               # delete char under cursor
dd              # delete line (cuts to register)
yy              # yank (copy) line
p / P           # paste after / before
u               # undo
Ctrl-r          # redo
.               # repeat last change
ciw             # change inner word (delete word, enter insert)
ci"             # change inside double quotes
dap             # delete a paragraph
```

## Trickery

- **The dot command (`.`).** Repeats the last change. Combine with `n` to do "find next, change, find next, change": `/foo` → `cgnbar` → `Esc` → `n.n.n.`. Atomic edit + reuse. The single most underrated vim feature.
- **Counts.** Most commands take a count prefix: `5dd` deletes 5 lines, `3w` jumps 3 words, `10G` jumps to line 10. Composable with motions: `d3w` deletes 3 words.
- **Marks.** `ma` sets mark `a`; `'a` jumps to its line, `` `a `` to exact position. `''` jumps back to where you were before the last big move. `'.` jumps to last edit.
- **Visual block (`Ctrl-v`).** Select a rectangle. `I` insert at start of every selected line, type, `Esc` — applies to all. The poor-man's multi-cursor.
- **`:%s/old/new/g`** — substitute every `old` with `new` in the file. Add `c` flag (`/gc`) for confirm-each-replace.
- **Registers.** `"ay` yanks into register `a`; `"ap` pastes from it. `"+y` yanks to system clipboard, `"+p` pastes from it. (Needs vim built with `+clipboard` — most distributions have it.)
- **Macros.** `qa` start recording into register `a`, do stuff, `q` stop. `@a` replay. `5@a` replay 5 times. Insanely productive for repetitive edits across lines.
- **`gd`** jump to local definition of the word under cursor; **`*`** find next occurrence of the word under cursor. Code reading without LSP.
- **`:!cmd`** run shell command from inside vim. `:r !date` inserts the date. `:%!jq .` pipes the buffer through jq and replaces it with the output.
- **Persistent undo.** Add `set undofile` to `~/.vimrc` — undo history survives across sessions.

## Survival when stuck

- Beeping, nothing works → you're in normal mode but pressed something wrong. `Esc` and try again.
- Stuck in `:` command line → `Esc` or `Ctrl-c`.
- Accidentally pressed `Ctrl-s` (terminal flow control freeze) → `Ctrl-q` to unfreeze.
- File says read-only → `:w !sudo tee %` (Linux), or quit with `:q!` and reopen with proper perms.
- Truly stuck → `:q!` to quit without saving, then start over.

## Gotchas

- On Windows: scoop installs vim as `vim` and `gvim`. Set `EDITOR=vim` in your shell profile (PowerShell: `$env:EDITOR = 'vim'` in `$PROFILE`).
- vim's default config is hostile (no syntax, weird tab settings). Minimal `~/.vimrc`:
  ```vim
  syntax on
  set number
  set tabstop=4 shiftwidth=4 expandtab
  set ignorecase smartcase
  set incsearch hlsearch
  set undofile
  ```
- If you find yourself liking it, **resist the urge to install 50 plugins.** Vanilla vim with the dot command and macros covers 90% of "I need an editor right now."
