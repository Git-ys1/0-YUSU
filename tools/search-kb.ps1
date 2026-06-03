param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Query,

    [int]$Context = 2,

    [switch]$Exact
)

$ErrorActionPreference = "Stop"

$root = & (Join-Path $PSScriptRoot "resolve-kb-root.ps1")
if (-not $root) {
    throw "Cannot resolve YUSU knowledge vault root."
}

$paths = @(
    "01_Projects",
    "03_CrossProject",
    "02_GlobalMemory",
    "04_Runbooks",
    "06_Maps",
    "00_Inbox"
) | ForEach-Object { Join-Path $root $_ }

$existing = $paths | Where-Object { Test-Path -LiteralPath $_ }

Write-Output "KB root: $root"
Write-Output "Query: $Query"
Write-Output ""

$pattern = $Query
if (-not $Exact) {
    $terms = $Query -split "\s+" | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { [regex]::Escape($_.Trim()) }
    if ($terms.Count -gt 0) {
        $pattern = $terms -join "|"
    }
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    & rg -n -i -C $Context --glob "*.md" -- $pattern @existing
    if ($LASTEXITCODE -eq 1) {
        Write-Output "No matches."
        exit 0
    }
    exit $LASTEXITCODE
}

Get-ChildItem -LiteralPath $existing -Recurse -File -Filter "*.md" |
    Select-String -Pattern $pattern -CaseSensitive:$false -Context $Context
