# gh (GitHub CLI)

**Purpose.** Official GitHub CLI. Issues, PRs, releases, gists, workflows, the API — all from the terminal. Replaces 80% of "open browser → github.com → click around."

Login once: `gh auth login`.

## 3 main use cases

### 1. PR workflow without leaving the terminal
```
gh pr create --fill                              # PR from current branch, autofill title/body
gh pr list                                       # open PRs in this repo
gh pr checkout 42                                # check out PR #42 locally
gh pr view 42 --web                              # open in browser
gh pr merge 42 --squash --delete-branch
```

### 2. Issues and triage
```
gh issue list --label bug --state open
gh issue create --title "X" --body "Y" --label bug
gh issue comment 17 --body "fixed in #42"
gh issue close 17
```

### 3. Repo + release ops
```
gh repo clone owner/name
gh repo create my-thing --public --source=. --push
gh release create v1.0.0 ./dist/*.zip --notes "first release"
gh workflow run deploy.yml -f env=prod
gh run list --workflow=ci.yml                    # recent runs
gh run watch                                     # tail latest run
```

## Trickery

- **`gh api`** — direct REST/GraphQL access with auth handled. `gh api repos/foo/bar/pulls --paginate --jq '.[].title'`. Use this for anything not covered by a built-in subcommand.
- **`--jq` flag.** Built-in jq filter on any JSON-returning command: `gh pr list --json number,title,author --jq '.[] | "\(.number) \(.author.login) \(.title)"'`.
- **`gh pr status`** shows: PRs you authored, PRs requesting your review, your latest CI status. One command, full picture.
- **Aliases.** `gh alias set prc 'pr create --fill --web'` — your own subcommands. List with `gh alias list`.
- **`gh copilot suggest`** / **`gh copilot explain`** — Copilot in the CLI (paid). Suggest a command from prose, or explain a complex shell line.
- **Gist as quick paste.** `gh gist create file.txt` returns a URL. `--public`, `--secret`, `-d "desc"`. Faster than uploading anywhere else.
- **Templates.** `gh issue create --template bug.md` uses your repo's `.github/ISSUE_TEMPLATE/bug.md`. Same for PRs.
- **`gh pr diff 42`** prints the diff in the terminal. Pipe through `bat -l diff` or `delta` for colors.
- **Multiple GitHub hosts.** `gh auth login --hostname github.example.com` for GHES. Switch with `gh auth switch`.

## Gotchas

- Default editor is `$EDITOR` or notepad on Windows. Set `EDITOR=vim` in your shell profile so `gh pr create` (no `--body`) drops you into vim.
- `gh pr create --fill` uses the latest commit message as title and body. Write good commit messages and PR creation becomes free.
- `gh repo clone` uses HTTPS by default unless `gh.protocol = ssh` is set. `gh config set git_protocol ssh` for SSH cloning.
