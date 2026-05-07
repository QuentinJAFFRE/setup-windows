# zoxide

**Purpose.** Smarter `cd`. Tracks directories you visit, ranks them by frecency (frequency × recency), lets you jump with a substring. After a week of normal use, `cd` becomes obsolete.

Init: add `Invoke-Expression (& { (zoxide init powershell | Out-String) })` to `$PROFILE` (PowerShell) or `eval "$(zoxide init bash)"` to `.bashrc`.

## 3 main use cases

### 1. Jump to a known directory
```
z proj              # jumps to most-frecent dir matching "proj"
z setup win         # multiple terms — must all match the path
z ..                # go up one (still works)
z -                 # previous dir (cd - replacement)
```

### 2. Interactive pick when ambiguous
```
zi                  # opens fzf-style picker over all tracked dirs
zi proj             # picker filtered by "proj"
```

### 3. Inside other tools
```
yazi                # press z inside yazi → zoxide jump
fzf integration     # ctrl-t binding etc
```

## Trickery

- **Frecency, not just frequency.** A dir you visited 3 times today outranks one you visited 50 times last year. Self-tuning to your current project.
- **`z foo bar`** — multiple terms, all must match somewhere in the path. `z work api` jumps to `~/work/projects/our-api` regardless of intermediate dirs.
- **`zoxide query foo --list`** — see ranked candidates without jumping. `--score` shows the actual frecency scores.
- **`zoxide remove ~/old/path`** — drop a stale entry. Useful after deleting a project so it stops appearing in `zi`.
- **`zoxide import`.** Migrate from `autojump`, `z.lua`, or `fasd` — `zoxide import --from autojump`. Don't lose years of history.
- **Custom hook.** Default hook adds dirs you `cd` into. `_ZO_HOOK=prompt` adds them at every prompt (heavier but catches when scripts cd you somewhere). `_ZO_HOOK=none` to track manually with `zoxide add`.
- **Doesn't fight `cd`.** zoxide installs `z` and `zi` (or whatever `_ZO_CMD` is set to) — `cd` still works for explicit absolute paths.

## Gotchas

- Cold start: zoxide is empty until you start visiting dirs through `z` (or with the prompt hook). For the first day or two, fall back to `cd`.
- Shared shells: zoxide's database is per-user. Multiple shells running concurrently merge fine, but a shared SSH session for two people overlaps their histories.
- The frecency algorithm is in C99 and *fast*; no perf concerns on Windows even with thousands of entries.
