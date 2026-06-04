param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$MarginaliaArgs
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$runtimeDir = Join-Path $root ".marginalia-yusu"
$marginaliaExe = Join-Path $toolRoot "marginalia-venv\Scripts\marginalia.exe"

if (-not (Test-Path -LiteralPath $marginaliaExe)) {
    throw "Marginalia is not installed. Run tools\setup-marginalia-yusu.ps1 first."
}

New-Item -ItemType Directory -Force -Path (Join-Path $toolRoot "tmp"), (Join-Path $runtimeDir "home") | Out-Null

$env:TEMP = Join-Path $toolRoot "tmp"
$env:TMP = $env:TEMP
$env:PIP_CACHE_DIR = Join-Path $toolRoot "pip-cache"
$env:HOME = Join-Path $runtimeDir "home"
$env:USERPROFILE = $env:HOME
$env:MARGINALIA_HOME = ((Join-Path $runtimeDir "data") -replace "\\", "/")

if (-not $env:WORKER_ENABLED) {
    $env:WORKER_ENABLED = "false"
}

Push-Location $runtimeDir
try {
    & $marginaliaExe @MarginaliaArgs
} finally {
    Pop-Location
}
