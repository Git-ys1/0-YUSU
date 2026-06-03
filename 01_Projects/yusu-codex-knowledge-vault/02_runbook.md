# Runbook

## Environment

- OS: Windows host, Ubuntu 20.04 target
- Runtime: Git, GitHub CLI, PowerShell, Bash
- Toolchain: Codex AGENTS, Codex Skills, Obsidian Markdown vault

## Common Commands

```powershell
# Windows setup
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\setup-codex-endpoint.ps1

# Windows search
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\search-kb.ps1 -Query "keyword"

# Windows startup readiness
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\check-codex-startup-readiness.ps1

# Windows publish
git status --short
git add .
git commit -m "更新知识库"
git push
```

```bash
# Ubuntu clone and setup
mkdir -p "$HOME/AcademicHub"
git clone https://github.com/Git-ys1/0-YUSU.git "$HOME/AcademicHub/0-YUSU"
cd "$HOME/AcademicHub/0-YUSU"
bash tools/setup-codex-endpoint.sh

# Ubuntu update
cd "$YUSU_KB_ROOT"
git pull --rebase
bash tools/search-kb.sh "keyword"
```

## Verification

- `python C:\Users\yusu\.codex\skills\.system\skill-creator\scripts\quick_validate.py F:\AcademicHub\0#YUSU\.agents\skills\yusu-kb`
- `Test-Path "$env:YUSU_KB_ROOT\00_START_HERE_FOR_CODEX.md"`
- `Test-Path "$HOME\.agents\skills\yusu-kb\SKILL.md"`
- `Test-Path "$HOME\.codex\skills\yusu-kb\SKILL.md"`
- `git status --short --branch`
- `git ls-remote --heads origin main`

## Troubleshooting

- If PowerShell profile noise appears, rerun with `powershell.exe -NoProfile`.
- If a skill fails validation, check YAML frontmatter quoting, especially colons in `description`.
- If Ubuntu shell scripts fail after clone, check `.gitattributes` and ensure `.sh` files use LF.
- If GitHub remote name differs from local folder, remember `0#YUSU` was normalized to `0-YUSU`.

## Source Evidence

- Commands verified: endpoint setup, skill validation, search, GitHub push, remote inspection
- Last verified: 2026-06-03
