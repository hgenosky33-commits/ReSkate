[CmdletBinding()]
param(
    [ValidateSet('Status', 'Login', 'Repositories')]
    [string]$Action = 'Status'
)
$ErrorActionPreference = 'Stop'
$gh = Join-Path $PSScriptRoot '.local/github-cli/gh.exe'
if (-not (Test-Path -LiteralPath $gh)) {
    $command = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $command) { throw 'GitHub CLI is missing. Install it from https://cli.github.com/.' }
    $gh = $command.Source
}
$previousConfig = $env:GH_CONFIG_DIR
try {
    $env:GH_CONFIG_DIR = Join-Path $PSScriptRoot '.local/github-auth'
    switch ($Action) {
        'Status' { & $gh auth status --hostname github.com }
        'Login' { & $gh auth login --hostname github.com --git-protocol https --web --skip-ssh-key }
        'Repositories' { & $gh repo list --limit 100 --json nameWithOwner,isPrivate,url,viewerPermission }
    }
    if ($LASTEXITCODE -ne 0) { throw "GitHub $Action did not complete. Use .\github.ps1 Login to authorize this local tool." }
} finally { $env:GH_CONFIG_DIR = $previousConfig }
