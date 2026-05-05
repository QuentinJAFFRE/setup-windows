# ripgrep (`rg`)

**Purpose.** Recursively search file contents. Faster than `grep -r` / `ack` / `ag`, respects `.gitignore` by default, sane Unicode handling. The single most-used CLI tool for most developers.

## 3 main use cases

### 1. Find a string across the project
```
rg "TODO"                        # all TODOs
rg -i "fixme"                    # case-insensitive
rg "fn \w+\(" src/               # regex, only under src/
```

### 2. Find with context lines
```
rg -B 3 -A 3 "panic!"            # 3 lines before/after
rg -C 5 "deprecated"             # 5 lines on each side
```

### 3. Filter by file type
```
rg "useState" -t js              # only JS files
rg -t py -t md "TODO"            # python + markdown
rg --type-list                   # see all known types
```

## Trickery

- **`rg --files`** lists every file ripgrep would search — drop-in replacement for `find . -type f` that respects `.gitignore`. Pipe to fzf for instant fuzzy-find.
- **`rg --files-with-matches`** (`-l`) returns only filenames that contain matches. Great input for batch operations: `rg -l TODO | xargs vim`.
- **Replace, in place.** `rg "foo" -l | xargs sed -i 's/foo/bar/g'` (Linux) or use `rg foo --replace bar` to preview replacements without writing.
- **Hidden + ignored.** `rg --hidden` includes dotfiles; `rg --no-ignore` includes `.gitignore`d files; `rg -uuu` is "unrestricted" (hidden + ignored + binary).
- **Multiline regex.** `rg --multiline 'struct \{[^}]*field'` — match across newlines. Default ripgrep is line-oriented for speed; opt in only when needed.
- **Glob filters.** `rg foo -g '!*.test.js'` excludes test files; `rg foo -g 'src/**/*.ts'` includes only TS under src.
- **JSON output.** `rg foo --json` for machine consumption (yazi, editors, scripts). Each match is a JSON line with byte offsets.
- **`.ripgreprc`** in `%USERPROFILE%` for default flags. E.g. always show line numbers, always smart-case. Set `RIPGREP_CONFIG_PATH` env var to point to it.

## Gotchas

- `rg foo bar` is **two separate args** (pattern + path), not "match `foo bar`." Quote multi-word patterns: `rg "foo bar"`.
- Regex syntax is Rust's `regex` crate — no lookarounds by default. Use `--pcre2` for `(?=…)` / `(?<…)`.
- On Windows, `rg "C:\path"` needs single quotes or escaping; backslashes in the *pattern* are regex escapes.
