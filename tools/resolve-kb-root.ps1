$ErrorActionPreference = "Stop"

$candidates = @()

if ($env:YUSU_KB_ROOT) {
    $candidates += $env:YUSU_KB_ROOT
}

if ($PSScriptRoot) {
    $candidates += (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..") -ErrorAction SilentlyContinue).Path
}

$candidates += @(
    "F:\AcademicHub\0#YUSU",
    "C:\Users\yusu\YUSU-KB"
)

foreach ($candidate in $candidates | Where-Object { $_ } | Select-Object -Unique) {
    $startFile = Join-Path $candidate "00_START_HERE_FOR_CODEX.md"
    if (Test-Path -LiteralPath $startFile) {
        Write-Output (Resolve-Path -LiteralPath $candidate).Path
        exit 0
    }
}

Write-Error "YUSU knowledge vault was not found. Set YUSU_KB_ROOT or mount F:\AcademicHub\0#YUSU."
exit 1

