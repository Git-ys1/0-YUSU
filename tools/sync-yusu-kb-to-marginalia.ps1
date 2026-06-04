param(
    [switch]$Check,
    [switch]$Ingest,
    [switch]$NoClean
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$toolRoot = Join-Path $root ".tools"
$runtimeDir = Join-Path $root ".marginalia-yusu"
$libraryRoot = Join-Path $runtimeDir "data\library\yusu-kb"
$marginaliaExe = Join-Path $toolRoot "marginalia-venv\Scripts\marginalia.exe"

if (-not (Test-Path -LiteralPath $marginaliaExe)) {
    throw "Marginalia is not installed. Run tools\setup-marginalia-yusu.ps1 first."
}

if ((Test-Path -LiteralPath $libraryRoot) -and -not $NoClean) {
    Remove-Item -LiteralPath $libraryRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $libraryRoot, (Join-Path $toolRoot "tmp"), (Join-Path $runtimeDir "home") | Out-Null

$excludedRoots = @(
    ".git",
    ".obsidian",
    ".tools",
    ".marginalia-yusu",
    "vendor",
    "00_Inbox\shared-checks"
) | ForEach-Object { Join-Path $root $_ }

$files = Get-ChildItem -LiteralPath $root -Recurse -File -Include "*.md", "*.txt" | Where-Object {
    $full = $_.FullName
    -not ($excludedRoots | Where-Object { $full -like "$_*" })
}

$count = 0
foreach ($file in $files) {
    $rel = $file.FullName.Substring($root.Length).TrimStart("\", "/")
    $dest = Join-Path $libraryRoot $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $dest -Force
    $count++
}

Write-Output "Projected $count file(s) into $libraryRoot"

if (-not $Check -and -not $Ingest) {
    return
}

$env:TEMP = Join-Path $toolRoot "tmp"
$env:TMP = $env:TEMP
$env:PIP_CACHE_DIR = Join-Path $toolRoot "pip-cache"
$env:HOME = Join-Path $runtimeDir "home"
$env:USERPROFILE = $env:HOME
$env:MARGINALIA_HOME = ((Join-Path $runtimeDir "data") -replace "\\", "/")

if ($Ingest) {
    $env:WORKER_ENABLED = "true"
    $commands = "/check`n/ingest --all`n/quit`nq`n"
} else {
    $env:WORKER_ENABLED = "false"
    if (-not $env:LLM_DEFAULT_API_KEY) {
        $env:LLM_DEFAULT_API_KEY = "placeholder-for-readonly-check"
    }
    $commands = "/check`n/quit`nq`n"
}

Push-Location $runtimeDir
try {
    $commands | & $marginaliaExe
} finally {
    Pop-Location
}
