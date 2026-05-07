# Sysinternals Suite

**Purpose.** Microsoft's collection of low-level Windows diagnostic tools. Maintained by Mark Russinovich. Install once, forget until something is wrong. Then they're indispensable.

Install via `winget install Microsoft.Sysinternals.Suite`. Binaries land in `%ProgramFiles%\Sysinternals\` (or via `\\live.sysinternals.com\tools` for always-latest).

This cheat sheet covers the **5 you'll actually use**. The suite has ~70 tools.

## 3 main use cases (across the suite)

### 1. Process Explorer (`procexp64.exe`)
Replaces Task Manager. Shows process tree (parent → child), DLLs/handles per process, real CPU breakdown, GPU usage per process, signing status. Right-click → "Set Priority" / "Suspend" / "Properties → Strings" to see what's loaded.

Killer features:
- **Search handles + DLLs.** `Ctrl+F`, type `foo.txt` → find which process has the file open. End of "file is locked by another process" mysteries.
- **Verify signatures.** Options → Verify Image Signatures → red rows for unsigned binaries (often = malware).
- **Replace Task Manager.** Options → Replace Task Manager. `Ctrl+Shift+Esc` opens procexp instead.

### 2. Process Monitor (`procmon.exe`)
Real-time logging of file system, registry, network, and process events. The "what is this app doing under the hood?" tool.

Killer features:
- **Filter early.** `Ctrl+L` → add filter `Process Name is foo.exe`. Without filtering, procmon collects thousands of events per second.
- **"Why isn't my config loading?"** Filter by your process, look for `NAME NOT FOUND` results — shows every path it tried before falling back. Solves 80% of config path mysteries.
- **Boot logging.** Options → Enable Boot Logging — captures what happens during Windows startup. Diagnoses slow boot.

### 3. Autoruns (`autoruns64.exe`)
Lists every program that runs at login/boot, across **every** registry hive, scheduled task, service, browser extension, codec, shell extension. Far more thorough than Task Manager's Startup tab.

Killer features:
- **Disable, don't delete.** Uncheck rows to disable; keeps the entry around so you can re-enable. Safer than registry editing.
- **VirusTotal integration.** Options → "Check VirusTotal.com" → every entry gets a VT score. Spots malware persistence.
- **Hide signed Microsoft entries.** Options → Hide Microsoft and Windows Entries → only third-party stuff visible. Cleanup pass after fresh install.

## Two more worth knowing

### 4. ZoomIt (`ZoomIt.exe`)
Screen zoom + draw + timer for presentations and demos. `Ctrl+1` zoom, `Ctrl+2` draw on screen, `Ctrl+3` countdown timer. Stays out of the way until invoked. Useful for screen-shares and pair sessions.

### 5. Handle (`handle.exe`)
CLI tool. `handle foo.txt` lists every process that has `foo.txt` open. Same answer as Process Explorer's search but scriptable. `handle -p foo.exe` lists everything `foo.exe` has open.

## Trickery

- **Always-latest binaries.** `\\live.sysinternals.com\tools\procexp64.exe` runs the newest version directly from Microsoft over SMB — no install needed. Bookmark it.
- **PsExec for remote.** `psexec \\machine cmd` — open a shell on a remote Windows box you have admin on. Tunnels through SMB; needs the target to have SMB+admin shares enabled.
- **TCPView.** Real-time list of TCP/UDP connections per process. Faster and clearer than `netstat`. Right-click → close connection / kill process.
- **Sysmon + ETW.** For serious monitoring: Sysmon ships rich event logs (process create, network connect, image load) into the Windows event log. Configure with a curated XML (SwiftOnSecurity's is the standard starting point).
- **`Strings procexp64.exe | rg foo`** — Strings (separate tool) dumps printable strings from a binary. Quick way to see what URLs / API endpoints / messages a binary contains.

## Gotchas

- Most tools require admin rights for full info (procexp shows kernel-mode info only when elevated; procmon needs admin to capture).
- Procmon's logs grow fast. Always set a filter before "go" or your disk fills.
- Autoruns can disable critical Windows components if you uncheck the wrong thing. **Hide Microsoft entries** before flipping switches.
- Don't run `psexec` against machines you don't admin. It's flagged by every EDR product as suspicious.
