# fd

**Purpose.** Find files and directories. A fast, friendly `find` replacement: smart defaults (regex, case-insensitive when lowercase, respects `.gitignore`, parallel walk).

## 3 main use cases

### 1. Find by name
```
fd config                # any path containing "config"
fd "\.json$"             # regex: ends with .json
fd -e py                 # by extension
```

### 2. Find + execute
```
fd -e log -x rm {}                       # delete all .log files
fd -e py -x black {}                     # format every python file
fd -e mp4 -x ffmpeg -i {} -c copy {.}.mkv   # transcode (preserve name)
```

### 3. Use as a fast file lister for fzf / yazi
```
fd --type f | fzf
fd --hidden --no-ignore | fzf            # include dotfiles + ignored
```

## Trickery

- **`{}` `{.}` `{/}` `{//}` placeholders in `-x`.** `{}` full path, `{.}` without extension, `{/}` basename, `{//}` parent dir. Lets you build sed-like batch ops without scripting.
- **`-X` (capital) vs `-x`.** Capital batches all matches into one command call (`fd -X rm` runs `rm a b c`); lowercase invokes once per match (`fd -x rm` runs `rm a; rm b; rm c`). Capital is faster for many small files.
- **Type filters.** `--type f` files, `--type d` dirs, `--type l` symlinks, `--type x` executable, `--type e` empty. Combine: `fd --type d --type e` finds empty dirs.
- **`fd --changed-within 1h`** time-based filtering: `1h`, `2d`, `1w`, `2024-01-01`. Replaces awkward `find -mtime` math.
- **Exclusion.** `fd -E node_modules -E .git` skips those dirs entirely. Faster than walking and filtering.
- **`fd --search-path`** can take multiple paths. `fd foo src tests docs` searches only those.
- **Color matters.** `fd --color always | bat` keeps colors when piping to a pager.

## Gotchas

- Default ignores `.gitignore` and hidden files. Forget `--hidden --no-ignore` and you'll miss things in dotfile-heavy directories.
- `fd foo` is regex-by-default but anchored to the filename, not the path. Use `-p` (`--full-path`) to match against the full path.
- `find` users muscle-memory-typing `find . -name "*.log"`: `fd` is just `fd -e log`. Resist the urge to alias `fd` to `find` — they're different enough to confuse.
