# chezmoi-pwsh

Windows dotfiles managed with [chezmoi](https://www.chezmoi.io/) — PowerShell
profile, prompt, and Git config.

This is the **Windows** half of a two-repo setup. The **WSL** half lives in a
separate repo (`github.com/Oli-Ward/chezmoi`) and is the source of truth for
Claude Code / Codex skills (see [Skills](#skills) below).

## What's managed

| Source file | Deploys to | Notes |
|---|---|---|
| `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | `~/Documents/PowerShell/...` | PowerShell 7 profile |
| `dot_mytheme.omp.json` | `~/.mytheme.omp.json` | oh-my-posh theme |
| `dot_gitconfig` | `~/.gitconfig` | contains name/email (not secret) |
| `dot_gitignore_global` | `~/.gitignore_global` | global gitignore |
| `dot_secrets.ps1.example` | `~/.secrets.ps1.example` | placeholder; see [Secrets](#secrets) |
| `run_once_install-packages.ps1.tmpl` | _(runs, not deployed)_ | installs dependencies |

`chezmoi` uses this repo as its source directory via
`~/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "C:/Users/oliw/Git/chezmoi-pwsh"
```

## Fresh machine setup

```powershell
winget install twpayne.chezmoi
chezmoi init --apply git@github.com:Oli-Ward/chezmoi-pwsh.git
```

`chezmoi init --apply` clones this repo, deploys the dotfiles, and runs
`run_once_install-packages.ps1` once (see [Dependencies](#dependencies)).

> The package installer needs PowerShell 7 (`pwsh`) — install it first
> (`winget install Microsoft.PowerShell`) on a brand-new machine.

## Dependencies

`run_once_install-packages.ps1.tmpl` installs everything the profile relies on,
and is idempotent (skips anything already present):

- **winget**: oh-my-posh, zoxide, fzf
- **PowerShell modules**: posh-git, PSFzf, Terminal-Icons, DockerCompletion
- **npm**: gitmoji-cli (powers the `gcom` / `gca` functions)

It runs automatically on first `chezmoi apply`. To force a re-run after editing
the package list, bump the `package-list-version` comment inside it.

## Secrets

The profile dot-sources `~/.secrets.ps1` if present (guarded by `Test-Path`).
That file is **never** committed — it's listed in `.chezmoiignore`.
`dot_secrets.ps1.example` records the variable names with placeholder values.

To set up secrets on a machine: copy `~/.secrets.ps1.example` to
`~/.secrets.ps1` and fill in real values.

## Skills

Claude Code and Codex skills are **not** managed by this repo. They are managed
by the WSL chezmoi repo (`github.com/Oli-Ward/chezmoi`, the source of truth) and
mirrored into the Windows home by `sync-skills-from-wsl.ps1` (kept in this repo
but excluded from deployment via `.chezmoiignore`):

```powershell
./sync-skills-from-wsl.ps1          # mirror current WSL skills into Windows
./sync-skills-from-wsl.ps1 -Update  # pull latest from GitHub in WSL, apply, then mirror
```

It rsyncs `~/.claude/skills` and `~/.codex/skills` from WSL, dereferencing
symlinks (some `.claude` skills symlink to `~/.agents/skills`) so Windows gets
real files, and preserves Codex's bundled `~/.codex/skills/.system`. Requires
WSL with `rsync` (`wsl sudo apt-get install -y rsync`).

## Everyday commands

```powershell
chezmoi add ~/.gitconfig     # start managing a file / pull in local edits
chezmoi re-add               # refresh all managed files from their live copies
chezmoi diff                 # preview what apply would change
chezmoi apply                # write source state to the home directory
chezmoi cd                   # open a shell in the source directory
chezmoi update               # git pull + apply
```
