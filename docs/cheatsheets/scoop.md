# Scoop

**Purpose.** Per-user, no-admin package manager for Windows. Best for **CLI tooling** (winget remains best for GUI apps). Installs to `%USERPROFILE%\scoop\`, adds shims to `PATH`, no UAC, no registry pollution. Co-exists with winget and Chocolatey.

Install: `iwr -useb get.scoop.sh | iex` (in a non-admin PowerShell).

## 3 main use cases

### 1. Install + update Unix-style CLI tools
```
scoop install ripgrep fd fzf bat eza jq gh vim zoxide starship yazi
scoop update          # update scoop itself
scoop update *        # update every installed app
```

### 2. Add buckets for niche software
```
scoop bucket add extras       # GUI-ish or non-default packages
scoop bucket add nerd-fonts   # programming fonts
scoop bucket add versions     # pinned older versions (python27, node-lts-16)
scoop install JetBrainsMono-NF
```

### 3. Clean uninstall
```
scoop uninstall <app>         # also removes shims and PATH entries
scoop cleanup *               # remove old versions still on disk
```

Compare to winget, which can leave registry entries and start-menu junk on uninstall.

## Trickery

- **Shims, not symlinks.** Scoop creates a small `.exe` shim per binary that forwards to the real one. Means: `scoop reset <app> 1.2.3` switches versions instantly without re-downloading.
- **`scoop reset`** is the version manager. `scoop install python@3.10.13` then `scoop reset python@3.10.13` — switch among installed versions per shell.
- **Buckets as private package repos.** Make a Git repo with a `bucket/<app>.json` manifest, run `scoop bucket add mybucket https://github.com/me/mybucket`, and `scoop install mybucket/myapp` works. Cheapest team-internal app distribution method on Windows.
- **`scoop cache show`** lists downloaded installers; `scoop cache rm <app>` clears cache. Saves disk if you've installed lots of versions.
- **`scoop status`** lists outdated apps without updating. `scoop update -k` updates only metadata, not apps — useful pre-flight.
- **No admin = safer for shared machines.** Each user has their own scoop. No conflict with corporate IT policies that block UAC prompts.
- **`scoop hold <app>`** pins a version so `scoop update *` skips it. Useful for tools where a new version broke your workflow.

## Gotchas

- Scoop's PATH ordering: scoop's shim dir goes early in PATH. If you have a `bat` from another source, the scoop one wins. `where bat` to confirm which one runs.
- Some apps (large ones, GUI apps) are mirrored in the `extras` bucket but are still better installed via winget for proper Start Menu / file association integration.
- The official scoop repo accepts community PRs; manifest quality is high but not Microsoft-curated like winget.
