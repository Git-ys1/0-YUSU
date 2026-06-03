param(
    [string]$Actor = "windows"
)

$ErrorActionPreference = "Stop"

$root = & (Join-Path $PSScriptRoot "resolve-kb-root.ps1")
$checkDir = Join-Path $root "00_Inbox\shared-checks"
New-Item -ItemType Directory -Force -Path $checkDir | Out-Null

$timestamp = (Get-Date -Format "yyyy-MM-ddTHH-mm-ssK").Replace(":", "-")
$file = Join-Path $checkDir "$Actor-$timestamp.md"

@"
# Shared Access Check

- Actor: $Actor
- OS: Windows
- Time: $timestamp
- KB Root: $root
"@ | Set-Content -LiteralPath $file -Encoding UTF8

Write-Output "KB root: $root"
Write-Output "Wrote: $file"
Get-ChildItem -LiteralPath $checkDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 10 Name, LastWriteTime
