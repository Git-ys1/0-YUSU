param(
    [string]$KbRoot = "F:\AcademicHub\0#YUSU"
)

$ErrorActionPreference = "Stop"

$startFile = Join-Path $KbRoot "00_START_HERE_FOR_CODEX.md"
if (-not (Test-Path -LiteralPath $startFile)) {
    throw "Cannot find YUSU KB root: $KbRoot"
}

[Environment]::SetEnvironmentVariable("YUSU_KB_ROOT", $KbRoot, "User")
$env:YUSU_KB_ROOT = $KbRoot

$skillTarget = Join-Path $KbRoot ".agents\skills\yusu-kb"
$skillLinks = @(
    (Join-Path $HOME ".agents\skills\yusu-kb"),
    (Join-Path $HOME ".codex\skills\yusu-kb")
)

foreach ($link in $skillLinks) {
    $parent = Split-Path -Parent $link
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    if (Test-Path -LiteralPath $link) {
        $item = Get-Item -LiteralPath $link -Force
        if (($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink") -and $item.Target -eq $skillTarget) {
            continue
        }
        if ($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink") {
            Remove-Item -LiteralPath $link -Force
        } else {
            throw "Existing non-link path would be overwritten: $link"
        }
    }

    New-Item -ItemType Junction -Path $link -Target $skillTarget | Out-Null
}

$codexDir = Join-Path $HOME ".codex"
$agentsPath = Join-Path $codexDir "AGENTS.md"
New-Item -ItemType Directory -Force -Path $codexDir | Out-Null
if (-not (Test-Path -LiteralPath $agentsPath)) {
    "# Global AGENTS`n" | Set-Content -LiteralPath $agentsPath -Encoding UTF8
}

$begin = "<!-- BEGIN YUSU_KB_SHARED -->"
$end = "<!-- END YUSU_KB_SHARED -->"
$blockTemplate = @'
{BEGIN}
## Shared YUSU Knowledge Vault

Use the shared Codex knowledge vault at `YUSU_KB_ROOT`, currently `{KB_ROOT}`.

Before non-trivial project work:
1. Read `{KB_ROOT}\00_START_HERE_FOR_CODEX.md`.
2. Read `{KB_ROOT}\04_Runbooks\system-decisions.md`.
3. Use the `yusu-kb` skill when available.
4. Search project and cross-project memory before editing.

After non-trivial project work:
1. Update reusable project memory in the shared vault.
2. Do not use local `.codex\memories` as the manual canonical store.
3. Never write secrets, credentials, private tokens, cookies, private keys, or raw private data.
{END}
'@

$block = $blockTemplate.Replace("{BEGIN}", $begin).Replace("{END}", $end).Replace("{KB_ROOT}", $KbRoot)

$content = Get-Content -LiteralPath $agentsPath -Raw
$pattern = [regex]::Escape($begin) + ".*?" + [regex]::Escape($end)
if ($content -match $pattern) {
    $content = [regex]::Replace($content, $pattern, $block, "Singleline")
} elseif ($content -match "(?s)\r?\n## Shared YUSU Knowledge Vault\r?\n.*\z") {
    $content = [regex]::Replace($content, "(?s)\r?\n## Shared YUSU Knowledge Vault\r?\n.*\z", "`n`n$block")
} else {
    $content = $content.TrimEnd() + "`n`n" + $block + "`n"
}

$duplicateBeginPattern = [regex]::Escape($begin) + "\s*" + [regex]::Escape($begin)
while ($content -match $duplicateBeginPattern) {
    $content = [regex]::Replace($content, $duplicateBeginPattern, $begin)
}
Set-Content -LiteralPath $agentsPath -Value $content -Encoding UTF8

[pscustomobject]@{
    YUSU_KB_ROOT = [Environment]::GetEnvironmentVariable("YUSU_KB_ROOT", "User")
    SkillAgents = Test-Path -LiteralPath (Join-Path $HOME ".agents\skills\yusu-kb\SKILL.md")
    SkillCodex = Test-Path -LiteralPath (Join-Path $HOME ".codex\skills\yusu-kb\SKILL.md")
    Agents = $agentsPath
} | Format-List
