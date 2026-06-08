# Onboarding From Zero

## First 30 Minutes

1. Open `F:\AcademicHub\0#YUSU\00_START_HERE_FOR_CODEX.md`.
2. Read `04_Runbooks/system-decisions.md` to understand the canonical vault, sync route, and retrieval route.
3. Read `04_Runbooks/codex-retrieval-workflow.md` before searching, so you do not confuse Obsidian with Codex's retrieval path.
4. Read `04_Runbooks/codex-ingestion-guide.md` before writing any memory file.
5. If the task is a mature project ingestion, read `04_Runbooks/mature-project-ingestion.md` and `04_Runbooks/super-yusu-v0.2-ingestion.md`.
6. Use `rg` or `tools/search-kb.ps1` to find existing entries before adding new ones.
7. Check `git status --short --untracked-files=all` before editing. This vault often receives entries from multiple project Codex instances.

Do not start by opening Obsidian or by editing local `.codex\memories`. Obsidian is a human UI, and local Codex Memories are not the canonical manual store.

## First Day

1. Identify the project or topic.
2. Search existing project entries in `01_Projects/README.md` and `06_Maps/project-map.md`.
3. If the project already exists, update the existing directory instead of creating a duplicate slug.
4. If the project is mature, locate the engineer's own session JSONL:
   - `tools/find-own-codex-session.ps1 -ProjectPath "<project-path>"`
   - fall back to `tools/codex-session-inventory.ps1` only for metadata discovery.
5. Read the real project repo, Git history, existing docs, and commands before writing conclusions.
6. Write project facts to `01_Projects/<slug>/`.
7. Route reusable lessons to `03_CrossProject/`, `02_GlobalMemory/`, or `06_Maps/` only when evidence supports reuse.
8. Run the relevant audit script before declaring the ingestion complete.

When acting as vault administrator, do not pretend to be the original project engineer. Validate evidence and mark missing items as `pending` rather than backfilling from guesses.

## Minimal Working Loop

The smallest safe loop for this vault is:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\search-kb.ps1 -Query "project or keyword"
git -C F:\AcademicHub\0#YUSU status --short --untracked-files=all
rg -n -i "project-slug|repo-path|error keyword" F:\AcademicHub\0#YUSU
```

For mature project work, add:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\find-own-codex-session.ps1 -ProjectPath "<project-path>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\mature-project-retro-audit.ps1 -Slug "<slug>" -ProjectPath "<project-path>" -SessionFile "<own-rollout-jsonl>"
```

For broad cited research inside the vault, Marginalia is optional:

```powershell
F:\AcademicHub\0#YUSU\tools\sync-yusu-kb-to-marginalia.ps1 -Check
F:\AcademicHub\0#YUSU\tools\run-marginalia-yusu.ps1
```

Only use Marginalia when the task needs deep cross-document synthesis. For normal lookups, `rg` is faster and less fragile.

## Common Newcomer Traps

- Do not write secrets, private keys, tokens, cookies, SSH credentials, or raw private user data into this vault.
- Do not assume `0#YUSU` and `0-YUSU` are the same path. The former is the Windows folder; the latter is the GitHub repository name.
- Do not say Ubuntu sharing is proven until Ubuntu has written a check file and Windows has read it.
- Do not claim a newly installed skill passively triggered inside the same long thread that installed it.
- Do not treat Marginalia DB state as canonical. After Markdown merges, rerun sync/ingest/reindex before relying on semantic results.
- Do not copy large raw JSONL conversations into memory files. Record session IDs, paths, topic counts, commands, and distilled evidence.
- Do not let a mature project finish without `10_project_summary.md` and `Memory Routing Audit`.
- Do not promote a project-specific workaround into global memory unless it is clearly reusable outside the project.
- Do not delete old evidence for neatness. If a fact is superseded, mark it as deprecated or resolved.
- Do not run destructive Git commands in this vault unless the user explicitly asked and the target path is verified.

## If Rebuilding From Scratch

1. Create the plain Markdown vault first, before adding semantic search or UI tools.
2. Define the write hierarchy early: project facts, cross-project lessons, global candidates, active rules, and local generated memories.
3. Add `AGENTS.md` instructions and `yusu-kb` skill discovery before asking project Codex instances to use the vault.
4. Add search scripts and `rg` workflows before Obsidian or Marginalia.
5. Set up GitHub private remote as the cross-system sync baseline.
6. Only then add mature-project templates and the V0.2 routing audit.
7. Add Marginalia last, as a derived research layer with explicit sync/reindex commands.
8. Validate the workflow on one small project, then one mature project, then multiple project slices.

This order avoids the early failure mode where a beautiful memory repository exists but future Codex sessions do not know how to find, update, or audit it.
