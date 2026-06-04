param(
    [string]$HostAddress = "127.0.0.1",
    [int]$Port = 8000,
    [switch]$AllowPlaceholderKey
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$runtimeDir = Join-Path $root ".marginalia-yusu"
$pythonExe = Join-Path $toolRoot "marginalia-venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $pythonExe)) {
    throw "Marginalia is not installed. Run tools\setup-marginalia-yusu.ps1 first."
}

New-Item -ItemType Directory -Force -Path (Join-Path $toolRoot "tmp"), (Join-Path $runtimeDir "home") | Out-Null

$env:TEMP = Join-Path $toolRoot "tmp"
$env:TMP = $env:TEMP
$env:PIP_CACHE_DIR = Join-Path $toolRoot "pip-cache"
$env:HOME = Join-Path $runtimeDir "home"
$env:USERPROFILE = $env:HOME
$env:MARGINALIA_HOME = ((Join-Path $runtimeDir "data") -replace "\\", "/")
$env:WORKER_ENABLED = "false"

if ($AllowPlaceholderKey -and -not $env:LLM_DEFAULT_API_KEY) {
    $env:LLM_DEFAULT_API_KEY = "placeholder-for-ui-only"
}

Push-Location $runtimeDir
try {
    & $pythonExe -m uvicorn marginalia.main:app --host $HostAddress --port $Port
} finally {
    Pop-Location
}
