---
name: yusu-kb
description: "Use for any yusu project memory work: search the shared knowledge vault, ingest project experience, decide where Codex memories should be written, update cross-project lessons, or prevent repeated mistakes across Windows/Ubuntu projects."
---

# YUSU KB Skill

This skill makes Codex use yusu's shared knowledge vault before and after non-trivial project work.

## Locate the vault

1. Prefer `YUSU_KB_ROOT`.
2. If unset, try:
   - Windows: `F:\AcademicHub\0#YUSU`
   - WSL: `/mnt/f/AcademicHub/0#YUSU`
   - Ubuntu: `~/YUSU-KB`
3. If inside the vault, use the current repository root.

## Before non-trivial project work

1. Read `00_START_HERE_FOR_CODEX.md`.
2. Read `04_Runbooks/system-decisions.md`.
3. Read `04_Runbooks/codex-retrieval-workflow.md`.
4. Search for the current project name, repository path, framework, toolchain, hardware, and likely error keywords.
5. Prefer this order:
   - `01_Projects/<project-slug>/05_known_issues.md`
   - `01_Projects/<project-slug>/02_runbook.md`
   - `01_Projects/<project-slug>/03_decisions.md`
   - `03_CrossProject/pitfalls.md`
   - `03_CrossProject/tooling.md`
   - `02_GlobalMemory/ACTIVE.md`

## Search commands

Windows:

```powershell
F:\AcademicHub\0#YUSU\tools\search-kb.ps1 -Query "keyword"
```

Ubuntu/Linux:

```bash
bash "$YUSU_KB_ROOT/tools/search-kb.sh" "keyword"
```

Fallback:

```bash
rg -n -i "keyword" "$YUSU_KB_ROOT"
```

## Where to write memory

- Project facts: `01_Projects/<project-slug>/`
- Cross-project lessons: `03_CrossProject/`
- Shared global rule candidates: `02_GlobalMemory/LEARNINGS.md`
- Stable global rules: `02_GlobalMemory/ACTIVE.md`
- Debugging/tool failures: `02_GlobalMemory/ERRORS.md` or `03_CrossProject/tooling.md`
- Missing recurring capabilities: `02_GlobalMemory/FEATURE_REQUESTS.md`

Do not use `~/.codex/memories` as the manual canonical store. Codex Memories are generated local recall state only.

## After non-trivial work

1. Update the relevant project memory.
2. Add cross-project lessons only when reusable.
3. Update `06_Maps/` when a new project, tool, pitfall, or topic is added.
4. Never store secrets, tokens, cookies, private keys, or raw private data.
