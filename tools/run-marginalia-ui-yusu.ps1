param(
    [string]$ApiBase = "http://127.0.0.1:8000",
    [string]$HostAddress = "127.0.0.1",
    [int]$Port = 5173,
    [string]$RunDir = "F:\AcademicHub\YUSU-Marginalia-Desktop-Run"
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$sourceDesktop = Join-Path $root "vendor\marginalia\desktop"
$toolRoot = Join-Path $root ".tools"

if (-not (Test-Path -LiteralPath $sourceDesktop)) {
    throw "Marginalia desktop source not found: $sourceDesktop"
}

New-Item -ItemType Directory -Force -Path $RunDir, (Join-Path $toolRoot "npm-cache") | Out-Null

$robocopyOutput = robocopy $sourceDesktop $RunDir /E /XD node_modules dist dist-ssr .git src-tauri\target src-tauri\gen /XF .env.local *.tsbuildinfo
if ($LASTEXITCODE -gt 7) {
    $robocopyOutput | Write-Output
    throw "Failed to copy Marginalia desktop source to $RunDir"
}

$env:npm_config_cache = Join-Path $toolRoot "npm-cache"

if (-not (Test-Path -LiteralPath (Join-Path $RunDir "node_modules"))) {
    Push-Location $RunDir
    try {
        & npm.cmd ci
    } finally {
        Pop-Location
    }
}

$viteCache = Join-Path $RunDir "node_modules\.vite"
if (Test-Path -LiteralPath $viteCache) {
    $resolved = (Resolve-Path -LiteralPath $viteCache).Path
    $allowed = (Resolve-Path -LiteralPath $RunDir).Path
    if (-not $resolved.StartsWith($allowed, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove unexpected Vite cache path: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}

$env:VITE_API_TARGET = $ApiBase

Push-Location $RunDir
try {
    & npx.cmd --yes --package node@22 node node_modules/vite/bin/vite.js --host $HostAddress --port $Port
} finally {
    Pop-Location
}
