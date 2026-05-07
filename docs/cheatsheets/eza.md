# eza

**Purpose.** Modern `ls` replacement (successor to `exa`). Color, icons (with a Nerd Font), Git integration, tree view, sane defaults. Written in Rust.

## 3 main use cases

### 1. Drop-in `ls`
```
eza                              # basic listing, colored
eza -l                           # long format
eza -la --git                    # long, hidden, with git status column
```

### 2. Tree view
```
eza --tree                       # full tree
eza --tree --level=2             # 2 levels deep
eza --tree --git-ignore          # respect .gitignore
```

### 3. Sort + filter
```
eza -l --sort=modified           # most recent last
eza -l --sort=size --reverse     # largest first
eza -lD                          # only directories
eza -lf                          # only files
```

## Trickery

- **`--icons`.** Emoji-style file-type icons (needs Nerd Font in the terminal). `--icons=auto` only when output is a TTY.
- **Git column.** `--git` adds a 2-char column showing index/working-tree status per file. Faster than `git status` for a glance.
- **`--header`.** Long-format gets a header row (Permissions, Size, Modified, etc.). Helps when scanning large listings.
- **Custom time format.** `--time-style=long-iso` or `--time-style=full-iso` for unambiguous timestamps. Default is human ("3 hours ago").
- **`--total-size`.** On directories, computes recursive size (slow on large trees, but invaluable). `eza -l --total-size`.
- **Hyperlinks.** `--hyperlink` makes filenames OSC-8 hyperlinks; in WezTerm, Ctrl-click opens them in your default app.
- **Aliases worth setting.** `ls=eza`, `ll=eza -l --git`, `la=eza -la --git`, `lt=eza --tree --level=2`.

## Gotchas

- Without a Nerd Font, `--icons` shows tofu (replacement boxes). Install JetBrainsMono Nerd Font (or similar) in your terminal first.
- `eza` is **not 100% compatible with `ls`**. Scripts that parse `ls -l` output should keep using `ls`. eza is for humans.
- `--git` slows things down in repos with thousands of files (it shells out to git per dir). Toggle off if it lags.
