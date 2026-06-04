param(
    [string]$Python = "",
    [switch]$SkipInstall,
    [switch]$SyncProjection
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$venvDir = Join-Path $toolRoot "marginalia-venv"
$runtimeDir = Join-Path $root ".marginalia-yusu"
$submoduleDir = Join-Path $root "vendor\marginalia"

function Set-RepoLocalEnv {
    New-Item -ItemType Directory -Force -Path $toolRoot, (Join-Path $toolRoot "tmp"), (Join-Path $toolRoot "pip-cache"), $runtimeDir | Out-Null
    $env:TEMP = Join-Path $toolRoot "tmp"
    $env:TMP = $env:TEMP
    $env:PIP_CACHE_DIR = Join-Path $toolRoot "pip-cache"
    $env:HOME = Join-Path $runtimeDir "home"
    $env:USERPROFILE = $env:HOME
    New-Item -ItemType Directory -Force -Path $env:HOME | Out-Null
}

function Test-Python311 {
    param([string]$Candidate)
    if (-not $Candidate -or -not (Test-Path -LiteralPath $Candidate)) {
        return $false
    }
    $code = "import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)"
    & $Candidate -c $code 2>$null
    return $LASTEXITCODE -eq 0
}

function Find-Python311 {
    if ($Python) {
        if (Test-Python311 $Python) { return (Resolve-Path -LiteralPath $Python).Path }
        throw "Provided Python is not Python 3.11+: $Python"
    }
    if ($env:YUSU_MARGINALIA_PYTHON -and (Test-Python311 $env:YUSU_MARGINALIA_PYTHON)) {
        return (Resolve-Path -LiteralPath $env:YUSU_MARGINALIA_PYTHON).Path
    }
    $known = @(
        "F:\Project\Simple Oscilloscope\.venv\python.exe"
    )
    foreach ($candidate in $known) {
        if (Test-Python311 $candidate) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    throw "No repo-safe Python 3.11+ found. Set -Python or YUSU_MARGINALIA_PYTHON to a non-C-drive interpreter."
}

function Set-EnvValue {
    param([string]$Path, [string]$Name, [string]$Value)
    $line = "$Name=$Value"
    if (-not (Test-Path -LiteralPath $Path)) {
        Set-Content -LiteralPath $Path -Value ($line + "`n") -Encoding UTF8
        return
    }
    $text = Get-Content -LiteralPath $Path -Raw
    if ($text -match "(?m)^$([regex]::Escape($Name))=") {
        $pattern = "(?m)^$([regex]::Escape($Name))=.*$"
        $text = [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $line })
    } else {
        if ($text -and -not $text.EndsWith("`n")) { $text += "`n" }
        $text += $line + "`n"
    }
    Set-Content -LiteralPath $Path -Value $text -Encoding UTF8
}

Set-RepoLocalEnv

if (-not (Test-Path -LiteralPath (Join-Path $submoduleDir "pyproject.toml"))) {
    git -C $root submodule update --init -- vendor/marginalia
}

$pythonExe = Find-Python311
Write-Output "Using Python: $pythonExe"

if (-not (Test-Path -LiteralPath (Join-Path $venvDir "Scripts\python.exe"))) {
    & $pythonExe -m venv $venvDir
}

$venvPython = Join-Path $venvDir "Scripts\python.exe"
& $venvPython --version

if (-not $SkipInstall) {
    & $venvPython -m pip install -e (Join-Path $root "vendor\marginalia")
}

$marginaliaExe = Join-Path $venvDir "Scripts\marginalia.exe"
& $marginaliaExe init $runtimeDir

$envPath = Join-Path $runtimeDir ".env"
$homeValue = ((Join-Path $runtimeDir "data") -replace "\\", "/")
Set-EnvValue -Path $envPath -Name "MARGINALIA_HOME" -Value $homeValue
Set-EnvValue -Path $envPath -Name "WORKER_ENABLED" -Value "false"
Set-EnvValue -Path $envPath -Name "STORAGE_BACKEND" -Value "mirror"

if ($SyncProjection) {
    & (Join-Path $PSScriptRoot "sync-yusu-kb-to-marginalia.ps1")
}

Write-Output "Marginalia runtime: $runtimeDir"
Write-Output "Marginalia venv: $venvDir"
Write-Output "Next: edit $envPath and set LLM_DEFAULT_API_KEY before /ingest --all."
