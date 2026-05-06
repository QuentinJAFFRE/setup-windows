# dotfiles/

Source-of-truth configs for the minimalist dev stack. Deployed by
`setup-env-shell.ps1`. Layout:

| Source                                        | Target                                                                             |
|-----------------------------------------------|------------------------------------------------------------------------------------|
| `powershell/Microsoft.PowerShell_profile.ps1` | `$PROFILE` (i.e. `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`) |
| `starship/starship.toml`                      | `~\.config\starship.toml`                                                          |
| `yazi/yazi.toml`                              | `%APPDATA%\yazi\config\yazi.toml`                                                  |
| `yazi/keymap.toml`                            | `%APPDATA%\yazi\config\keymap.toml`                                                |
| `wezterm/.wezterm.lua` (if present)           | `~\.wezterm.lua`                                                                   |

After `setup-env-shell.ps1` runs, **open a fresh PowerShell window** so the
profile loads.

## Run

```powershell
.\setup-env-shell.ps1            # deploy
.\setup-env-shell.ps1 -DryRun    # preview only
```

Or symlink instead of copy (changes track the repo, needs admin for symlinks):

```powershell
New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Resolve-Path .\dotfiles\powershell\Microsoft.PowerShell_profile.ps1) -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\starship.toml" -Target (Resolve-Path .\dotfiles\starship\starship.toml) -Force
# … same pattern for yazi files
```
