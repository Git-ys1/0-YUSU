param(
    [string]$HostAddress = "127.0.0.1",
    [int]$Port = 8787
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$venvDir = Join-Path $toolRoot "marginalia-venv"
$runtimeDir = Join-Path $root ".marginalia-yusu"
$pythonExe = Join-Path $toolRoot "marginalia-venv\Scripts\python.exe"
$server = Join-Path $root "07_PersonalSite\server.py"
$distIndex = Join-Path $root "07_PersonalSite\marginalia-dist\index.html"

if (-not (Test-Path -LiteralPath $pythonExe)) {
    throw "Marginalia runtime is missing. Run tools\setup-marginalia-yusu.ps1 first."
}
$pyvenvCfg = Join-Path $venvDir "pyvenv.cfg"
if ((Test-Path -LiteralPath $pyvenvCfg) -and ((Get-Content -LiteralPath $pyvenvCfg -Raw) -match "Simple Oscilloscope")) {
    throw "Marginalia venv is still based on the Simple Oscilloscope project venv. Rebuild it with tools\setup-marginalia-yusu.ps1."
}
if (-not (Test-Path -LiteralPath $distIndex)) {
    throw "Integrated UI is missing. Run tools\build-yusu-integrated-marginalia-ui.ps1 first."
}

New-Item -ItemType Directory -Force -Path (Join-Path $toolRoot "tmp"), (Join-Path $runtimeDir "home") | Out-Null

$env:TEMP = Join-Path $toolRoot "tmp"
$env:TMP = $env:TEMP
$env:PIP_CACHE_DIR = Join-Path $toolRoot "pip-cache"
$env:HOME = Join-Path $runtimeDir "home"
$env:USERPROFILE = $env:HOME
$env:npm_config_cache = Join-Path $toolRoot "npm-cache"
$env:NPM_CONFIG_CACHE = $env:npm_config_cache
$env:PLAYWRIGHT_BROWSERS_PATH = Join-Path $toolRoot "playwright-browsers"
$env:MARGINALIA_HOME = ((Join-Path $runtimeDir "data") -replace "\\", "/")
$env:MARGINALIA_DESKTOP = "1"
$env:YUSU_MARGINALIA_WORKER = "true"

& $pythonExe $server --host $HostAddress --port $Port
