param(
    [string]$Query = "yusu-codex-knowledge-vault GitHub private remote"
)

$ErrorActionPreference = "Stop"

$root = & (Join-Path $PSScriptRoot "resolve-kb-root.ps1")
$homeDir = [Environment]::GetFolderPath("UserProfile")
$agentsPath = Join-Path $homeDir ".codex\AGENTS.md"
$skillAgents = Join-Path $homeDir ".agents\skills\yusu-kb\SKILL.md"
$skillCodex = Join-Path $homeDir ".codex\skills\yusu-kb\SKILL.md"

$checks = [ordered]@{
    "KB root resolved" = [bool]$root
    "Start file exists" = Test-Path -LiteralPath (Join-Path $root "00_START_HERE_FOR_CODEX.md")
    "User YUSU_KB_ROOT" = ([Environment]::GetEnvironmentVariable("YUSU_KB_ROOT", "User") -eq $root)
    "Global AGENTS exists" = Test-Path -LiteralPath $agentsPath
    "Global AGENTS has YUSU block" = $false
    "Skill in .agents" = Test-Path -LiteralPath $skillAgents
    "Skill in .codex" = Test-Path -LiteralPath $skillCodex
    "Search script exists" = Test-Path -LiteralPath (Join-Path $root "tools\search-kb.ps1")
    "Search query matched" = $false
}

if ($checks["Global AGENTS exists"]) {
    $agents = Get-Content -LiteralPath $agentsPath -Raw
    $checks["Global AGENTS has YUSU block"] = $agents.Contains("BEGIN YUSU_KB_SHARED") -and $agents.Contains("yusu-kb")
}

$searchOutput = & (Join-Path $root "tools\search-kb.ps1") -Query $Query
$checks["Search query matched"] = -not (($searchOutput -join "`n") -match "No matches\.")

[pscustomobject]$checks | Format-List

Write-Output ""
Write-Output "Search sample:"
$searchOutput | Select-Object -First 40

if ($checks.Values -contains $false) {
    exit 1
}

