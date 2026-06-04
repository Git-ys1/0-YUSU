param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $true)]
    [string]$SessionFile,

    [string]$KbRoot = "",
    [int]$MinIssues = 5,
    [int]$MinDecisions = 3,
    [int]$MinHistoryLines = 35,
    [int]$MinOnboardingLines = 30,
    [int]$MinEvidenceLines = 20,
    [int]$MinSummaryLines = 25,
    [int]$MinImportantThings = 3,
    [int]$MinRoutingRows = 3,
    [switch]$AllowCwdMismatch
)

$ErrorActionPreference = "Stop"

if (-not $KbRoot) {
    $KbRoot = & (Join-Path $PSScriptRoot "resolve-kb-root.ps1")
}

$projectMemory = Join-Path $KbRoot "01_Projects\$Slug"
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Check {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail,
        [string]$Level = "FAIL"
    )

    $status = if ($Passed) { "PASS" } elseif ($Level -eq "WARN") { "WARN" } else { "FAIL" }
    "{0,-5} {1} - {2}" -f $status, $Name, $Detail
    if (-not $Passed) {
        if ($Level -eq "WARN") {
            $warnings.Add($Name) | Out-Null
        } else {
            $failures.Add($Name) | Out-Null
        }
    }
}

function Get-RawText {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return ""
    }
    return Get-Content -LiteralPath $Path -Raw
}

function Remove-FencedBlocks {
    param([string]$Text)
    $lines = $Text -split "`r?`n"
    $inside = $false
    $kept = foreach ($line in $lines) {
        if ($line -match '^\s*```') {
            $inside = -not $inside
            continue
        }
        if (-not $inside) {
            $line
        }
    }
    return ($kept -join "`n")
}

function Count-RegexLines {
    param([string]$Text, [string]$Pattern)
    $plain = Remove-FencedBlocks $Text
    return ([regex]::Matches($plain, $Pattern, "Multiline")).Count
}

function Count-SubstantiveLines {
    param([string]$Text)
    $plain = Remove-FencedBlocks $Text
    $count = 0
    foreach ($line in ($plain -split "`r?`n")) {
        $trim = $line.Trim()
        if (-not $trim) { continue }
        if ($trim -eq "...") { continue }
        if ($trim -match "^\|\s*-+") { continue }
        if ($trim -match "^[-*]\s*\.\.\.$") { continue }
        if ($trim -match "^[#|]+$") { continue }
        if ($trim -match "^[A-Za-z0-9 /_-]+:\s*$") { continue }
        if ($trim -match "^-\s*[A-Za-z0-9 /_-]+:\s*$") { continue }
        $count++
    }
    return $count
}

function Get-SessionMeta {
    param([string]$Path)
    $firstLine = Get-Content -LiteralPath $Path -TotalCount 1 -ErrorAction Stop
    if (-not $firstLine) {
        throw "Session file is empty: $Path"
    }
    $meta = $firstLine | ConvertFrom-Json -ErrorAction Stop
    return [PSCustomObject]@{
        SessionId = [string]$meta.payload.id
        Timestamp = [string]$meta.payload.timestamp
        Cwd = [string]$meta.payload.cwd
        Source = [string]$meta.payload.source
        Path = $Path
        FileName = [System.IO.Path]::GetFileName($Path)
        MB = [math]::Round((Get-Item -LiteralPath $Path).Length / 1MB, 2)
    }
}

Write-Output "Mature project retrospective audit"
Write-Output "KB root: $KbRoot"
Write-Output "Project memory: $projectMemory"
Write-Output "Project path: $ProjectPath"
Write-Output "Engineer session file: $SessionFile"
Write-Output ""

Add-Check "Project memory directory exists" (Test-Path -LiteralPath $projectMemory) $projectMemory
Add-Check "Project path exists" (Test-Path -LiteralPath $ProjectPath) $ProjectPath
Add-Check "Engineer session file exists" (Test-Path -LiteralPath $SessionFile) $SessionFile
Add-Check "Engineer session file is JSONL" ($SessionFile -match "\.jsonl$") $SessionFile

$required = @(
    "README.md",
    "00_project_brief.md",
    "01_architecture.md",
    "02_runbook.md",
    "03_decisions.md",
    "04_progress.md",
    "05_known_issues.md",
    "06_todo_next.md",
    "07_development_history.md",
    "08_onboarding_from_zero.md",
    "09_session_evidence.md",
    "10_project_summary.md"
)

foreach ($name in $required) {
    Add-Check "Required file $name" (Test-Path -LiteralPath (Join-Path $projectMemory $name)) $name
}

$history = Get-RawText (Join-Path $projectMemory "07_development_history.md")
$onboarding = Get-RawText (Join-Path $projectMemory "08_onboarding_from_zero.md")
$evidence = Get-RawText (Join-Path $projectMemory "09_session_evidence.md")
$summary = Get-RawText (Join-Path $projectMemory "10_project_summary.md")
$issues = Get-RawText (Join-Path $projectMemory "05_known_issues.md")
$decisions = Get-RawText (Join-Path $projectMemory "03_decisions.md")

$historyLines = Count-SubstantiveLines $history
$onboardingLines = Count-SubstantiveLines $onboarding
$evidenceLines = Count-SubstantiveLines $evidence
$summaryLines = Count-SubstantiveLines $summary
$issueCount = Count-RegexLines $issues "(?m)^##\s+Issue:"
$decisionCount = Count-RegexLines $decisions "(?m)^##\s+Decision:"
$importantThingCount = Count-RegexLines $summary "(?m)^\|\s*[0-9]+\s*\|\s*(?!\.\.\.\s*\|)"
$routingRowCount = Count-RegexLines $summary "(?m)^\|\s*(?!\.\.\.\s*\|)(?!Candidate Lesson\s*\|)[^|]+\s*\|\s*(project-only|cross-project pitfall|cross-project pattern|cross-project tooling|architecture decision|global learning|active global rule|feature request|map only|deferred)\s*\|"
$adrDir = Join-Path $projectMemory "adr"
$adrCount = 0
if (Test-Path -LiteralPath $adrDir) {
    $adrCount = @(Get-ChildItem -LiteralPath $adrDir -File -Filter "*.md" | Where-Object { $_.Name -ne "_template.md" }).Count
}
$totalDecisions = $decisionCount + $adrCount

Add-Check "Development history has enough substance" ($historyLines -ge $MinHistoryLines) "$historyLines substantive lines, required $MinHistoryLines"
Add-Check "From-zero onboarding has enough substance" ($onboardingLines -ge $MinOnboardingLines) "$onboardingLines substantive lines, required $MinOnboardingLines"
Add-Check "Session evidence has enough substance" ($evidenceLines -ge $MinEvidenceLines) "$evidenceLines substantive lines, required $MinEvidenceLines"
Add-Check "Project summary has enough substance" ($summaryLines -ge $MinSummaryLines) "$summaryLines substantive lines, required $MinSummaryLines"
Add-Check "Project summary important things count" ($importantThingCount -ge $MinImportantThings) "$importantThingCount ranked things, required $MinImportantThings"
Add-Check "Memory Routing Audit row count" ($routingRowCount -ge $MinRoutingRows) "$routingRowCount routed lessons, required $MinRoutingRows"
Add-Check "Known issues count" ($issueCount -ge $MinIssues) "$issueCount issues, required $MinIssues"
Add-Check "Decision/ADR count" ($totalDecisions -ge $MinDecisions) "$totalDecisions decisions/ADRs, required $MinDecisions"

$summaryRequiredSections = @(
    "One-Page Summary",
    "Most Important Things",
    "Final Shape",
    "Hard-Won Lessons",
    "Rules For Future Codex",
    "Memory Routing Audit",
    "Remaining Risks"
)
foreach ($section in $summaryRequiredSections) {
    Add-Check "Summary section: $section" ($summary -match "(?m)^##\s+$([regex]::Escape($section))\s*$") $section
}

$onboardingRequiredSections = @(
    "First 30 Minutes",
    "First Day",
    "Minimal Working Loop",
    "Common Newcomer Traps",
    "If Rebuilding From Scratch"
)
foreach ($section in $onboardingRequiredSections) {
    Add-Check "Onboarding section: $section" ($onboarding -match "(?m)^##\s+$([regex]::Escape($section))\s*$") $section
}

$historyRequiredSections = @(
    "Timeline Summary",
    "Phase Notes",
    "Lessons By Stage"
)
foreach ($section in $historyRequiredSections) {
    Add-Check "History section: $section" ($history -match "(?m)^##\s+$([regex]::Escape($section))\s*$") $section
}

$gitCommitCount = ""
try {
    $gitRoot = git -C $ProjectPath rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $gitRoot) {
        $gitCommitCount = git -C $ProjectPath rev-list --count HEAD
        Add-Check "Git history readable" $true "$gitCommitCount commits at $gitRoot"
    } else {
        Add-Check "Git history readable" $false "not a git repository" "WARN"
    }
} catch {
    Add-Check "Git history readable" $false $_.Exception.Message "WARN"
}

$sessionMeta = $null
if (Test-Path -LiteralPath $SessionFile) {
    try {
        $sessionMeta = Get-SessionMeta -Path $SessionFile
        Add-Check "Engineer session metadata readable" $true "$($sessionMeta.SessionId) cwd=$($sessionMeta.Cwd) size=$($sessionMeta.MB)MB"
    } catch {
        Add-Check "Engineer session metadata readable" $false $_.Exception.Message
    }
}

if ($sessionMeta) {
    $projectNeedle = ([System.IO.Path]::GetFullPath($ProjectPath)).ToLowerInvariant()
    $cwdNeedle = $sessionMeta.Cwd.ToLowerInvariant()
    $cwdMatches = $cwdNeedle -and ($cwdNeedle.StartsWith($projectNeedle) -or $projectNeedle.StartsWith($cwdNeedle))
    $cwdLevel = if ($AllowCwdMismatch) { "WARN" } else { "FAIL" }
    Add-Check "Engineer session cwd matches project path" $cwdMatches "session cwd=$($sessionMeta.Cwd)" $cwdLevel

    $evidenceMentionsSession = (($sessionMeta.SessionId -and $evidence.Contains($sessionMeta.SessionId)) -or $evidence.Contains($sessionMeta.FileName))
    Add-Check "Session evidence references this engineer JSONL" $evidenceMentionsSession "09_session_evidence.md must cite $($sessionMeta.SessionId) or $($sessionMeta.FileName)"
}

Write-Output ""
Write-Output "Engineer session:"
if ($sessionMeta) {
    $sessionMeta | Select-Object MB, Timestamp, SessionId, Cwd, Path | Format-List
} else {
    Write-Output "(unreadable)"
}

Write-Output ""
Write-Output "Retrospective prompts still required when the gate fails:"
Write-Output "- What did the project believe at the beginning that later turned out wrong?"
Write-Output "- Which failures were expensive enough that a new Codex must not repeat them?"
Write-Output "- Which current design choices are consequences of earlier failed attempts?"
Write-Output "- What exact commands and files prove the current runbook?"
Write-Output "- If rebuilding from zero, what order avoids the historical traps?"
Write-Output "- What are the 3-7 most important things this project taught us?"
Write-Output "- Which of those lessons must be promoted outside 01_Projects, and where?"

Write-Output ""
if ($failures.Count -gt 0) {
    Write-Output "FAILED mature retrospective gate: $($failures.Count) blocking checks failed."
    exit 1
}

Write-Output "PASSED mature retrospective gate. Warnings: $($warnings.Count)."
