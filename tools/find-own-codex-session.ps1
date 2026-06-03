param(
    [string]$SessionsRoot = "$HOME\.codex\sessions",
    [string]$ThreadId = $env:CODEX_THREAD_ID,
    [string]$ProjectPath = "",
    [string]$Keyword = "",
    [int]$Top = 10,
    [int]$RecentScanLimit = 50,
    [switch]$SearchContent,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SessionsRoot)) {
    throw "Sessions root not found: $SessionsRoot"
}

function Read-SessionMeta {
    param([System.IO.FileInfo]$File)
    $cwd = ""
    $sessionId = ""
    $timestamp = ""
    $source = ""

    try {
        $firstLine = Get-Content -LiteralPath $File.FullName -TotalCount 1 -ErrorAction Stop
        if ($firstLine) {
            $meta = $firstLine | ConvertFrom-Json -ErrorAction Stop
            $sessionId = [string]$meta.payload.id
            $timestamp = [string]$meta.payload.timestamp
            $cwd = [string]$meta.payload.cwd
            $source = [string]$meta.payload.source
        }
    } catch {
        $source = "unreadable-meta"
    }

    [PSCustomObject]@{
        MB = [math]::Round($File.Length / 1MB, 2)
        LastWriteTime = $File.LastWriteTime
        Timestamp = $timestamp
        SessionId = $sessionId
        Cwd = $cwd
        Source = $source
        Path = $File.FullName
        Confidence = ""
        Reason = ""
    }
}

$allFiles = @(Get-ChildItem -LiteralPath $SessionsRoot -Recurse -File -Filter "*.jsonl")
$results = New-Object System.Collections.Generic.List[object]

if ($ThreadId) {
    foreach ($file in $allFiles | Where-Object { $_.Name -like "*$ThreadId*" }) {
        $item = Read-SessionMeta $file
        if ($item.SessionId -eq $ThreadId -or $file.Name -like "*$ThreadId*") {
            $item.Confidence = "exact"
            $item.Reason = "CODEX_THREAD_ID matched filename or session_meta.payload.id"
            $results.Add($item) | Out-Null
        }
    }
}

if ($results.Count -eq 0) {
    if ($SearchContent -and -not $Keyword) {
        throw "-SearchContent requires -Keyword."
    }

    $projectNeedle = ""
    if ($ProjectPath) {
        $projectNeedle = ([System.IO.Path]::GetFullPath($ProjectPath)).ToLowerInvariant()
    }
    $keywordNeedle = $Keyword.ToLowerInvariant()

    $files = @($allFiles | Sort-Object LastWriteTime -Descending | Select-Object -First $RecentScanLimit)
    foreach ($file in $files) {
        $item = Read-SessionMeta $file
        $passed = $true
        $reasons = New-Object System.Collections.Generic.List[string]

        if ($projectNeedle) {
            $cwdNeedle = $item.Cwd.ToLowerInvariant()
            if ($cwdNeedle -and ($cwdNeedle.StartsWith($projectNeedle) -or $projectNeedle.StartsWith($cwdNeedle))) {
                $reasons.Add("cwd matched project path") | Out-Null
            } else {
                $passed = $false
            }
        }

        if ($keywordNeedle) {
            $haystack = "$($item.Path) $($item.Cwd) $($item.SessionId) $($item.Source)".ToLowerInvariant()
            if ($haystack.Contains($keywordNeedle)) {
                $reasons.Add("metadata matched keyword") | Out-Null
            } elseif ($SearchContent -and (Select-String -LiteralPath $file.FullName -SimpleMatch -Pattern $Keyword -Quiet)) {
                $reasons.Add("content matched keyword") | Out-Null
            } else {
                $passed = $false
            }
        }

        if ($passed -and ($ProjectPath -or $Keyword)) {
            $item.Confidence = "candidate"
            $item.Reason = ($reasons -join "; ")
            $results.Add($item) | Out-Null
        }
    }
}

$result = @($results | Sort-Object LastWriteTime -Descending | Select-Object -First $Top)

if ($Json) {
    $result | ConvertTo-Json -Depth 4
} else {
    if ($ThreadId) {
        Write-Output "CODEX_THREAD_ID: $ThreadId"
    } else {
        Write-Output "CODEX_THREAD_ID not set; using fallback filters."
    }
    $result | Format-Table -AutoSize
}

if ($result.Count -eq 0) {
    exit 1
}
