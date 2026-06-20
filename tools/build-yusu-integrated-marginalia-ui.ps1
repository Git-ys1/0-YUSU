param(
    [string]$BuildDir = "F:\AcademicHub\YUSU-Integrated-Marginalia-Build"
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$source = Join-Path $root "07_PersonalSite\marginalia-ui"
$dist = Join-Path $root "07_PersonalSite\marginalia-dist"
$toolRoot = Join-Path $root ".tools"
$runtimeDir = Join-Path $root ".marginalia-yusu"

if (-not (Test-Path -LiteralPath (Join-Path $source "package.json"))) {
    throw "Integrated Marginalia UI source not found: $source"
}

New-Item -ItemType Directory -Force -Path `
    $BuildDir, `
    $dist, `
    (Join-Path $toolRoot "npm-cache"), `
    (Join-Path $toolRoot "tmp"), `
    (Join-Path $runtimeDir "home") | Out-Null

$copyOutput = robocopy $source $BuildDir /MIR /XD node_modules dist /XF *.tsbuildinfo
if ($LASTEXITCODE -gt 7) {
    $copyOutput | Write-Output
    throw "Failed to copy UI source to build directory: $BuildDir"
}

$env:TEMP = Join-Path $toolRoot "tmp"
$env:TMP = $env:TEMP
$env:HOME = Join-Path $runtimeDir "home"
$env:USERPROFILE = $env:HOME
$env:npm_config_cache = Join-Path $toolRoot "npm-cache"
$env:NPM_CONFIG_CACHE = $env:npm_config_cache
$env:npm_config_update_notifier = "false"
$env:PLAYWRIGHT_BROWSERS_PATH = Join-Path $toolRoot "playwright-browsers"

Push-Location $BuildDir
try {
    & npm.cmd ci
    if ($LASTEXITCODE -ne 0) { throw "npm ci failed" }

    & npx.cmd --yes --package node@22 node node_modules\typescript\bin\tsc -b
    if ($LASTEXITCODE -ne 0) { throw "TypeScript build failed" }

    & npx.cmd --yes --package node@22 node node_modules\vite\bin\vite.js build
    if ($LASTEXITCODE -ne 0) { throw "Vite build failed" }
} finally {
    Pop-Location
}

$distOutput = robocopy (Join-Path $BuildDir "dist") $dist /MIR
if ($LASTEXITCODE -gt 7) {
    $distOutput | Write-Output
    throw "Failed to copy built UI to: $dist"
}

Write-Output "Integrated Marginalia UI built: $dist"
