# ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# Loaded by Windows PowerShell 5.1 on every interactive session.
# Source of truth: this repo, copied/symlinked to $PROFILE.

# -- Editor --------------------------------------------------------------------
$env:EDITOR = 'vim'

# -- Aliases (Unix-friendly) ---------------------------------------------------
# Remove built-in aliases that would shadow the new tools.
foreach ($a in 'ls','cat','rm','cp','mv','where') {
    if (Test-Path "Alias:\$a") { Remove-Item "Alias:\$a" -Force -ErrorAction SilentlyContinue }
}
Set-Alias -Name ls   -Value eza
Set-Alias -Name ll   -Value eza
Set-Alias -Name cat  -Value bat
Set-Alias -Name grep -Value rg
Set-Alias -Name find -Value fd
Set-Alias -Name vi   -Value vim

# `eza -l --git` as a function so we can pass extra args through.
function ll { eza -l --git --icons=auto @args }
function la { eza -la --git --icons=auto @args }
function lt { eza --tree --level=2 --icons=auto @args }

# -- zoxide (smarter cd) -------------------------------------------------------
# Replaces `cd` with `z` (and adds `zi` for interactive picker).
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# -- starship prompt -----------------------------------------------------------
$env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship.toml"
Invoke-Expression (&starship init powershell)
