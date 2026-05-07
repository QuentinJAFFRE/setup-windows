# Starship

**Purpose.** Cross-shell prompt. Single `starship.toml` config drives the prompt in PowerShell, bash, zsh, fish, cmd, nu — same look everywhere. Fast (Rust, async modules), shows context (git branch, language version, kubectl context, AWS profile, cmd duration).

Init: add `Invoke-Expression (&starship init powershell)` to `$PROFILE` (PowerShell). Config at `%USERPROFILE%\.config\starship.toml`.

## 3 main use cases

### 1. Git status at a glance
The default prompt shows: branch, ahead/behind counts, dirty marker, stash count, conflict marker. `+`/`*`/`?` summarize staged/modified/untracked. No more `git status` to check "is this clean?"

### 2. Language version awareness
Auto-detects project type and shows the version of the runtime: `🐍 v3.11.7` in a Python repo, `⬢ v20.10.0` in a Node repo, `🦀 1.75.0` in a Rust repo. Catches "wrong Python version active" before you run anything.

### 3. Cloud / cluster context
- `aws` module — current AWS profile (so you don't `terraform apply` against prod by accident)
- `kubernetes` module — current kubectl context + namespace
- `gcloud` module — current GCP project
- `azure` module — current subscription

## Trickery

- **`starship explain`** — print every active module and its config. Discoverability for "why is this thing in my prompt?"
- **`starship preset` library.** `starship preset nerd-font-symbols -o ~/.config/starship.toml` writes a curated config. Browse: `starship preset --list`. `gruvbox-rainbow`, `tokyo-night`, `pure-preset`, `bracketed-segments`.
- **Custom modules via shell command.** `[custom.docker]` → `command = "docker context show"`, `when = "true"`. Show anything you can compute in <50ms.
- **Conditional formatting.** `[character] success_symbol = "[➜](green)" error_symbol = "[➜](red)"` — colored indicator showing last command's exit status without taking a line.
- **Right prompt.** `right_format = "$time"` — time on the right edge, command on the left. (Works in zsh/fish; PowerShell support via `$PROMPT` variable hack.)
- **Async modules.** Modules with `slow` ops (kubectl, docker) run async — prompt renders immediately, slow info appears when ready. No more "prompt freeze in a bad git repo."
- **`format` rewrite.** Build a multi-line prompt: line 1 cwd + git, blank line, line 2 just `$character`. Easier on the eyes for long paths.
- **Disable expensive modules per-project.** `[gcloud] disabled = true` in `.config/starship.toml`, then re-enable per project with `STARSHIP_CONFIG=./project-starship.toml`.

## Gotchas

- Icons need a Nerd Font. Without one, you'll see boxes/tofu. Install JetBrainsMono Nerd Font or similar in your terminal.
- `starship init powershell` must be sourced *after* PSReadLine setup if you customize PSReadLine — order matters.
- Status modules that hit network (gcloud, aws via SSO) can stall on bad networks. Set `[aws] disabled = true` if you don't use AWS, or use `command_timeout = 1000` to bail fast.
- The default prompt is loud. Most users trim it: hostname only over SSH, no language module, simpler git format. Configure or use a preset.
