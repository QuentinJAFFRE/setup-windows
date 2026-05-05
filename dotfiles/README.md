# dotfiles/

Source-of-truth configs for the minimalist dev stack. Deployed automatically by
`setup-scoop.ps1` (pass `-NoConfig` to skip). Layout:

| Source                                        | Target                                                          |
|-----------------------------------------------|-----------------------------------------------------------------|
| `powershell/Microsoft.PowerShell_profile.ps1` | `$PROFILE` (i.e. `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`) |
| `starship/starship.toml`                      | `~\.config\starship.toml`                                       |
| `yazi/yazi.toml`                              | `%APPDATA%\yazi\config\yazi.toml`                               |
| `yazi/keymap.toml`                            | `%APPDATA%\yazi\config\keymap.toml`                             |

After `setup-scoop.ps1` runs, **open a fresh PowerShell window** so the profile
loads.

## Manual deploy (if you don't want to re-run setup-scoop)

```powershell
.\setup-scoop.ps1 -DryRun     # preview only
```

Or symlink instead of copy (changes track the repo, needs admin for symlinks):

```powershell
New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Resolve-Path .\dotfiles\powershell\Microsoft.PowerShell_profile.ps1) -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\starship.toml" -Target (Resolve-Path .\dotfiles\starship\starship.toml) -Force
# … same pattern for yazi files
```
