param(
  [string]$SessionRoot = "C:\Users\yusu\.codex\sessions",
  [string]$SessionIndexPath = "C:\Users\yusu\.codex\session_index.jsonl",
  [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

$reportDate = Get-Date -Format "yyyy-MM-dd"
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = "F:\AcademicHub\0#YUSU\01_Projects\yusu-codex-knowledge-vault\session-log\$reportDate-session-inventory.md"
}

function Escape-MdCell {
  param([object]$Value)
  if ($null -eq $Value) { return "" }
  $text = [string]$Value
  $text = $text -replace "\|", "\|"
  $text = $text -replace "\r?\n", " "
  if ($text.Length -gt 80) {
    $text = $text.Substring(0, 77) + "..."
  }
  return $text
}

function Convert-BytesToMb {
  param([long]$Bytes)
  return [math]::Round($Bytes / 1MB, 2)
}

$sessionIndex = @{}
if (Test-Path -LiteralPath $SessionIndexPath) {
  foreach ($line in [System.IO.File]::ReadLines($SessionIndexPath)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try {
      $obj = $line | ConvertFrom-Json
      if ($obj.id) {
        $sessionIndex[$obj.id] = [pscustomobject]@{
          ThreadName = $obj.thread_name
          UpdatedAt = $obj.updated_at
        }
      }
    } catch {
      # Keep the inventory robust. The raw file remains the source of truth.
    }
  }
}

$patterns = [ordered]@{
  "yusu" = "(?i)yusu|0#YUSU|0-YUSU|YUSU_KB|superyusu|super-yusu"
  "kb_ingestion" = "\x{5165}\x{5e93}|\x{77e5}\x{8bc6}\x{5e93}|mature-project|Memory Routing Audit|session_evidence|project_summary"
  "marginalia" = "(?i)marginalia|semantic index|BGE|embedding shim"
  "carbonrag" = "(?i)CarbonRag|RAG-Pro|Milvus|crawler|super admin"
  "cleanscout" = "(?i)CleanScout|CSR|OpenRF1|\x{4e0b}\x{4f4d}\x{673a}|Vue3"
  "tooling" = "(?i)GitNexus|Mattermost|Docker|NoMachine|Orange Pi|HyperFrames"
}

$files = Get-ChildItem -LiteralPath $SessionRoot -Recurse -Filter "rollout-*.jsonl" |
  Sort-Object FullName

$hitByFile = @{}
foreach ($file in $files) {
  $hitByFile[$file.FullName] = @{}
  foreach ($key in $patterns.Keys) {
    $hitByFile[$file.FullName][$key] = 0
  }
}

foreach ($key in $patterns.Keys) {
  $pattern = $patterns[$key]
  $rgOutput = & rg --count-matches --no-heading --with-filename --glob "rollout-*.jsonl" -e $pattern $SessionRoot 2>$null
  foreach ($line in $rgOutput) {
    if ($line -match "^(.*):(\d+)$") {
      $path = $Matches[1]
      $count = [int]$Matches[2]
      if ($hitByFile.ContainsKey($path)) {
        $hitByFile[$path][$key] = $count
      }
    }
  }
}

$results = New-Object System.Collections.Generic.List[object]
$totalBytes = 0L
$ownThreadId = $env:CODEX_THREAD_ID

foreach ($file in $files) {
  $totalBytes += [long]$file.Length
  $jsonErrors = 0
  $firstMeta = $null
  $firstLine = $null
  try {
    $reader = [System.IO.File]::OpenText($file.FullName)
    try {
      $firstLine = $reader.ReadLine()
    } finally {
      $reader.Dispose()
    }
    if ($firstLine) {
      $firstMeta = $firstLine | ConvertFrom-Json
    }
  } catch {
    $jsonErrors++
  }

  $sessionId = $null
  $timestamp = $null
  $cwd = $null
  $source = $null
  $modelProvider = $null
  if ($firstLine) {
    if ($firstLine -match '"id"\s*:\s*"([^"]+)"') { $sessionId = $Matches[1] }
    if ($firstLine -match '"timestamp"\s*:\s*"([^"]+)"') { $timestamp = $Matches[1] }
    if ($firstLine -match '"cwd"\s*:\s*"((?:\\.|[^"])*)"') {
      $cwd = $Matches[1] -replace '\\\\', '\'
    }
    if ($firstLine -match '"source"\s*:\s*"([^"]+)"') { $source = $Matches[1] }
    if ($firstLine -match '"model_provider"\s*:\s*"([^"]+)"') { $modelProvider = $Matches[1] }
  }
  if ($firstMeta -and $firstMeta.payload) {
    if (-not $sessionId) { $sessionId = $firstMeta.payload.id }
    if (-not $timestamp) { $timestamp = $firstMeta.payload.timestamp }
    if (-not $cwd) { $cwd = $firstMeta.payload.cwd }
    if (-not $source) { $source = $firstMeta.payload.source }
    if (-not $modelProvider) { $modelProvider = $firstMeta.payload.model_provider }
  }
  if (-not $sessionId -and $file.Name -match "([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\.jsonl$") {
    $sessionId = $Matches[1]
  }

  $threadName = ""
  $indexUpdatedAt = ""
  if ($sessionId -and $sessionIndex.ContainsKey($sessionId)) {
    $threadName = $sessionIndex[$sessionId].ThreadName
    $indexUpdatedAt = $sessionIndex[$sessionId].UpdatedAt
  }

  $topicList = @()
  foreach ($key in $patterns.Keys) {
    $count = 0
    if ($hitByFile.ContainsKey($file.FullName)) {
      $count = $hitByFile[$file.FullName][$key]
    }
    if ($count -gt 0) {
      $topicList += "$key=$count"
    }
  }
  if ($topicList.Count -eq 0) { $topicList = @("none") }

  $results.Add([pscustomobject]@{
    SessionId = $sessionId
    Timestamp = $timestamp
    LastWriteTime = $file.LastWriteTime
    File = $file.FullName
    MB = Convert-BytesToMb $file.Length
    Cwd = $cwd
    ThreadName = $threadName
    IndexUpdatedAt = $indexUpdatedAt
    Source = $source
    ModelProvider = $modelProvider
    IsCurrentThread = ($sessionId -and $sessionId -eq $ownThreadId)
    JsonErrors = $jsonErrors
    TopicHits = ($topicList -join "; ")
  })
}

$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# $reportDate SuperYUSU session inventory")
$lines.Add("")
$lines.Add("Generated by tools/build-superyusu-session-inventory.ps1 to prove this superyusu ingestion pass traversed local Codex session files.")
$lines.Add("")
$lines.Add("## Coverage")
$lines.Add("")
$lines.Add("- Generated at: ``$now``")
$lines.Add("- Session root: ``$SessionRoot``")
$lines.Add("- Files scanned: $($results.Count)")
$lines.Add("- Total bytes: $totalBytes")
$lines.Add("- Total MB: $(Convert-BytesToMb $totalBytes)")
$lines.Add("- Traversal method: first-line session metadata for every rollout file plus ripgrep topic scans across all rollout JSONL files.")
$lines.Add("- Current ``CODEX_THREAD_ID``: ``$ownThreadId``")
$lines.Add("- Privacy rule: this inventory records metadata, counts, and topic-hit counts only; it does not copy raw private conversation text.")
$lines.Add("")
$lines.Add("## Important Sessions")
$lines.Add("")
$lines.Add("| Role | Session ID | Evidence |")
$lines.Add("|---|---|---|")
$current = $results | Where-Object { $_.IsCurrentThread } | Select-Object -First 1
if ($current) {
  $lines.Add("| current thread | ``$($current.SessionId)`` | ``$(Escape-MdCell $current.File)``; cwd=``$(Escape-MdCell $current.Cwd)``; MB=$($current.MB) |")
}
$vaultSessions = $results | Where-Object { $_.Cwd -like "*0#YUSU*" -or $_.TopicHits -match "yusu=" } | Sort-Object LastWriteTime -Descending | Select-Object -First 5
foreach ($session in $vaultSessions) {
  $lines.Add("| yusu-related | ``$($session.SessionId)`` | ``$(Escape-MdCell $session.File)``; cwd=``$(Escape-MdCell $session.Cwd)``; hits=$($session.TopicHits) |")
}
$lines.Add("")
$lines.Add("## Full Traversal Table")
$lines.Add("")
$lines.Add("| # | Session ID | MB | Last Write | Cwd | Thread | Topic Hits | Current |")
$lines.Add("|---:|---|---:|---|---|---|---|---|")
$i = 0
foreach ($session in $results | Sort-Object LastWriteTime) {
  $i++
  $lastWrite = $session.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
  $lines.Add("| $i | ``$($session.SessionId)`` | $($session.MB) | $lastWrite | $(Escape-MdCell $session.Cwd) | $(Escape-MdCell $session.ThreadName) | $(Escape-MdCell $session.TopicHits) | $($session.IsCurrentThread) |")
}
$lines.Add("")
$lines.Add("## Notes")
$lines.Add("")
$lines.Add("- Topic Hits is a routing aid, not a semantic summary. Project facts still require repository, Git history, and project-memory evidence.")
$lines.Add("- The largest current-thread file is kept as source evidence but should not be copied wholesale into the vault.")
$lines.Add("- Future project Codex instances should use find-own-codex-session.* and mature-project-retro-audit.* with their own session JSONL before declaring their project ingestion complete.")

[System.IO.File]::WriteAllLines($OutputPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote $OutputPath"
Write-Output "files=$($results.Count) total_mb=$(Convert-BytesToMb $totalBytes)"
