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
4. Read `04_Runbooks/super-yusu-v0.2-ingestion.md`.
5. Search for the current project name, repository path, framework, toolchain, hardware, and likely error keywords.
6. Prefer this order:
   - `01_Projects/<project-slug>/05_known_issues.md`
   - `01_Projects/<project-slug>/02_runbook.md`
   - `01_Projects/<project-slug>/03_decisions.md`
   - `03_CrossProject/pitfalls.md`
   - `03_CrossProject/tooling.md`
   - `02_GlobalMemory/ACTIVE.md`
7. If the project is mature or long-running, read `04_Runbooks/mature-project-ingestion.md`; each engineer should first run `tools/find-own-codex-session.*`, use only their own `rollout-*.jsonl` as the session source, and run `tools/mature-project-retro-audit.*` with that `SessionFile` before calling the ingestion complete.

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
3. Run the super-yusuV0.2 `Memory Routing Audit`; if lessons are reusable, actually update `03_CrossProject/`, `02_GlobalMemory/`, or `06_Maps/`; otherwise mark them as `project-only`, `deferred`, or `rejected` with evidence.
4. Update `06_Maps/` when a new project, tool, pitfall, or topic is added.
5. Never store secrets, tokens, cookies, private keys, or raw private data.
6. For mature projects, do not finish until `10_project_summary.md` captures the most important 3-7 project lessons, includes `Memory Routing Audit`, and the read-only retrospective audit gate passes against the current engineer's own JSONL, or the remaining failures are recorded in `06_todo_next.md`.
