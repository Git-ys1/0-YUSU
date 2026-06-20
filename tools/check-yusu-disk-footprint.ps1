param(
    [switch]$IncludeAppDataCaches
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path

function Get-DirectorySize {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return 0L
    }
    $sum = 0L
    Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
        ForEach-Object { $sum += $_.Length }
    return $sum
}

function New-SizeRow {
    param([string]$Path, [string]$Label)
    $bytes = Get-DirectorySize -Path $Path
    [pscustomobject]@{
        Label = $Label
        Path = $Path
        GB = [math]::Round($bytes / 1GB, 3)
        MB = [math]::Round($bytes / 1MB, 1)
    }
}

Write-Output "== Drives =="
Get-PSDrive -PSProvider FileSystem |
    Select-Object Name,
        @{Name = "FreeGB"; Expression = { [math]::Round($_.Free / 1GB, 2) }},
        @{Name = "UsedGB"; Expression = { [math]::Round($_.Used / 1GB, 2) }} |
    Format-Table -AutoSize

Write-Output "== Codex Home Link =="
$codexHome = Join-Path $HOME ".codex"
if (Test-Path -LiteralPath $codexHome) {
    $item = Get-Item -LiteralPath $codexHome -Force
    $item | Select-Object FullName, Attributes, LinkType, Target | Format-List
} else {
    Write-Output "Missing: $codexHome"
}

Write-Output "== YUSU Repo Runtime Footprint =="
@(
    New-SizeRow -Label "repo .tools" -Path (Join-Path $root ".tools")
    New-SizeRow -Label "repo .marginalia-yusu" -Path (Join-Path $root ".marginalia-yusu")
    New-SizeRow -Label "integrated UI temp build" -Path "F:\AcademicHub\YUSU-Integrated-Marginalia-Build"
    New-SizeRow -Label "legacy Marginalia UI temp run" -Path "F:\AcademicHub\YUSU-Marginalia-Desktop-Run"
) | Sort-Object GB -Descending | Format-Table -AutoSize

if ($IncludeAppDataCaches) {
    Write-Output "== User AppData Caches =="
    @(
        New-SizeRow -Label "TEMP" -Path $env:TEMP
        New-SizeRow -Label "pip cache" -Path (Join-Path $env:LOCALAPPDATA "pip\Cache")
        New-SizeRow -Label "npm cache" -Path (Join-Path $env:LOCALAPPDATA "npm-cache")
        New-SizeRow -Label "home .cache" -Path (Join-Path $HOME ".cache")
        New-SizeRow -Label "Codex tmp" -Path (Join-Path $codexHome ".tmp")
    ) | Sort-Object GB -Descending | Format-Table -AutoSize
}
