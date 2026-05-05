# whkd

**Purpose.** Windows Hotkey Daemon. Reads a single config file (`whkdrc`, sxhkd-style syntax) and runs shell commands on key chords. komorebi has no built-in hotkey system — whkd is what turns `Alt+1` into "switch to workspace 1." You can also use it for non-komorebi shortcuts (launchers, screenshot tools, anything CLI-callable).

Config: `%USERPROFILE%\.config\whkdrc`. Started automatically when you run `komorebic start --whkd`.

## 3 main use cases

### 1. Driving komorebi
Every komorebi action is a `komorebic` subcommand. whkd binds chords to those commands:
```
alt + 1 : komorebic focus-workspace 0
alt + shift + 1 : komorebic move-to-workspace 0
alt + h : komorebic focus left
alt + shift + h : komorebic move left
```

### 2. App launchers
```
alt + return : wt.exe                 # Windows Terminal
alt + b : start "" "msedge.exe"       # browser
alt + space : ; nothing — leave Alt+Space free for PowerToys Run
```

### 3. Quick custom workflows
```
ctrl + alt + s : powershell.exe -c "<screenshot script>"
alt + p : komorebic toggle-pause      # freeze tiling temporarily
```

## Trickery

- **`.shell` directive.** Put `.shell pwsh` (or `cmd`/`powershell`) at the top of `whkdrc` to pick the interpreter for command strings. Pwsh lets you use modern PowerShell semantics in bindings.
- **Chord prefixes.** `mod + r ; h` waits for `mod+r`, then `h`, before firing — i3-style "mode" chords. Use it to keep your single-key namespace clean.
- **Reload without restart.** Editing `whkdrc` while whkd runs? `komorebic reload-configuration` re-reads keybindings. No need to kill the daemon.
- **Debug who ate your key.** `whkd --debug` logs every chord it sees. If a hotkey isn't firing, this tells you whether whkd received it (often Windows or another app grabbed it first).
- **Reserve `Win` keys for Windows.** Windows reserves a lot of `Win+<letter>` chords. Bind komorebi to `Alt`-based chords to avoid conflicts. The `Alt+1..9` convention from i3 maps cleanly.
- **Conflict with PowerToys.** PowerToys Run defaults to `Alt+Space`. Either rebind PowerToys (preferred — it's configurable in PowerToys settings) or pick a different chord for komorebi's float toggle.

## Gotchas

- whkd grabs keys at the OS level. If another tool (AutoHotkey, PowerToys Keyboard Manager) already binds the same chord, behavior is undefined — pick one tool per chord.
- No syntax for "key release" or "long press." It's a chord-fires-command tool, nothing more.
