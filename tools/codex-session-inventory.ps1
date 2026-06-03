param(
    [string]$SessionsRoot = "$HOME\.codex\sessions",
    [string]$ProjectPath = "",
    [string]$Keyword = "",
    [int]$Top = 50,
    [double]$MinMB = 0,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SessionsRoot)) {
    throw "Sessions root not found: $SessionsRoot"
}

$projectNeedle = ""
if ($ProjectPath) {
    $projectNeedle = ([System.IO.Path]::GetFullPath($ProjectPath)).ToLowerInvariant()
}

$keywordNeedle = $Keyword.ToLowerInvariant()

$items = foreach ($file in Get-ChildItem -LiteralPath $SessionsRoot -Recurse -File -Filter "*.jsonl") {
    $mb = [math]::Round($file.Length / 1MB, 2)
    if ($mb -lt $MinMB) {
        continue
    }

    $meta = $null
    $cwd = ""
    $sessionId = ""
    $source = ""
    $model = ""

    try {
        $firstLine = Get-Content -LiteralPath $file.FullName -TotalCount 1 -ErrorAction Stop
        if ($firstLine) {
            $meta = $firstLine | ConvertFrom-Json -ErrorAction Stop
            $cwd = [string]$meta.payload.cwd
            $sessionId = [string]$meta.payload.id
            $source = [string]$meta.payload.source
            $model = [string]$meta.payload.model_provider
        }
    } catch {
        $source = "unreadable-meta"
    }

    if ($projectNeedle) {
        $cwdNeedle = $cwd.ToLowerInvariant()
        if (-not $cwdNeedle) {
            continue
        }
        if (-not ($cwdNeedle.StartsWith($projectNeedle) -or $projectNeedle.StartsWith($cwdNeedle))) {
            continue
        }
    }

    if ($keywordNeedle) {
        $haystack = "$($file.FullName) $cwd $sessionId $source".ToLowerInvariant()
        if (-not $haystack.Contains($keywordNeedle)) {
            continue
        }
    }

    [PSCustomObject]@{
        MB = $mb
        LastWriteTime = $file.LastWriteTime
        Timestamp = if ($meta) { [string]$meta.payload.timestamp } else { "" }
        SessionId = $sessionId
        Cwd = $cwd
        Source = $source
        ModelProvider = $model
        Path = $file.FullName
    }
}

$result = $items | Sort-Object LastWriteTime -Descending | Select-Object -First $Top

if ($Json) {
    $result | ConvertTo-Json -Depth 4
} else {
    $result | Format-Table -AutoSize
}
