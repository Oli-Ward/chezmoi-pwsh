#Requires -Version 7
<#
.SYNOPSIS
    Mirror Claude Code and Codex skills from WSL into the Windows home directory.

.DESCRIPTION
    Skills are managed by the WSL chezmoi repo (github.com/Oli-Ward/chezmoi),
    which is the source of truth. This script copies the *realized* skills from
    the WSL home into the Windows home using rsync, dereferencing symlinks
    (e.g. ~/.claude/skills entries that point at ~/.agents/skills) so Windows
    gets real files rather than broken links.

    It mirrors with --delete, so skills removed in WSL also disappear on Windows.
    Codex's bundled ~/.codex/skills/.system directory is preserved (excluded).

.PARAMETER Update
    First run `chezmoi update` inside WSL (git pull + apply) so the skills
    reflect the latest pushed to GitHub before mirroring.

.EXAMPLE
    ./sync-skills-from-wsl.ps1
    Mirror the current WSL skills into Windows.

.EXAMPLE
    ./sync-skills-from-wsl.ps1 -Update
    Pull the latest from GitHub in WSL, apply, then mirror into Windows.
#>
[CmdletBinding()]
param(
    [switch]$Update
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'wsl.exe not found. This script requires WSL.'
}

if (-not (wsl.exe -- bash -lc 'command -v rsync')) {
    throw 'rsync not found in WSL. Install it with:  wsl sudo apt-get install -y rsync'
}

# Resolve the WSL home (source) and the Windows home as a /mnt path (destination).
$wslHome = wsl.exe -- bash -lc 'printf "%s" "$HOME"'
$drive   = $HOME.Substring(0, 1).ToLower()
$winHome = "/mnt/$drive" + ($HOME.Substring(2) -replace '\\', '/')

if ($Update) {
    Write-Host '==> Updating WSL chezmoi (git pull + apply)...' -ForegroundColor Cyan
    wsl.exe -- bash -lc 'chezmoi update'
}

function Sync-SkillTree {
    param(
        [Parameter(Mandatory)][string]$RelPath,   # e.g. .claude/skills
        [string]$ExtraArgs = ''
    )
    $src = "$wslHome/$RelPath/"
    $dst = "$winHome/$RelPath"
    Write-Host "==> Mirroring $RelPath" -ForegroundColor Cyan
    wsl.exe -- bash -lc "mkdir -p '$dst' && rsync -aL --delete $ExtraArgs '$src' '$dst/'"
    if ($LASTEXITCODE -ne 0) { throw "rsync failed for $RelPath (exit $LASTEXITCODE)" }
}

Sync-SkillTree -RelPath '.claude/skills'
Sync-SkillTree -RelPath '.codex/skills' -ExtraArgs '--exclude=.system'

Write-Host 'Done. Skills mirrored from WSL into the Windows home.' -ForegroundColor Green
