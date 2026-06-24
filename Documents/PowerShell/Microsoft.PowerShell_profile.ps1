# ----------------------------
# Oh My Posh prompt
# ----------------------------

$ompTheme = "$HOME\.mytheme.omp.json"
$ompCache = "$env:TEMP\omp_init_pwsh7.ps1"

if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $ompTheme)) {
    if (-not (Test-Path $ompCache) -or ((Get-Item $ompCache).LastWriteTime -lt (Get-Date).AddDays(-1))) {
        oh-my-posh init pwsh --config $ompTheme | Set-Content $ompCache
    }

    . $ompCache
}

# ----------------------------
# PSReadLine
# ----------------------------

Import-Module PSReadLine -ErrorAction SilentlyContinue

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function Complete

# ----------------------------
# Zoxide
# ----------------------------

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ----------------------------
# Environment
# ----------------------------

$env:LC_ALL = 'C.UTF-8'
$env:ATLASSIAN_EMAIL = "oliver@cleverfirstaid.com"

if (Test-Path "$HOME\.secrets.ps1") {
    . "$HOME\.secrets.ps1"
}

# ----------------------------
# Aliases
# ----------------------------

Set-Alias ll Get-ChildItem
Set-Alias grep Select-String
Set-Alias touch New-Item

# ----------------------------
# Utility functions
# ----------------------------

function reload { . $PROFILE }
function .. { Set-Location .. }

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Source
}

# ----------------------------
# Git shortcuts
# ----------------------------

function gaa { git add . }
function ga { git add @args }
function gap { git add -p }
function gst { git status }
function gco { git checkout @args }
function gcb { git checkout -b @args }
function gpull { git pull }
function gpush { git push }
function gpf { git push --force-with-lease }
function gcom { gitmoji -c }
function gca { git add .; gitmoji -c }
function gl { git log --oneline --graph --decorate --all -n 20 }
function gd { git diff }
function gds { git diff --staged }
function gb { git branch }
function gba { git branch -a }

function gprune {
    git fetch --prune
    git branch -vv |
        Where-Object { $_ -match '\[origin/.*: gone\]' } |
        ForEach-Object { git branch -d $_.Trim().Split(' ')[0] }
}