# Project Summary

## One-Page Summary

YUSU Codex Knowledge Vault is the canonical shared Markdown memory system for yusu's Codex work across projects, Windows, and Ubuntu. Its main achievement is not the folder layout itself; it is the operational rule that project facts, cross-project lessons, global rule candidates, and stable active rules have separate write paths and evidence requirements.

The project began as a solution to fragmented memory. It became a protocol for mature project ingestion: read the real repo, inspect Git history, identify the engineer's own session JSONL, write development history and failure history, summarize the most important lessons, then route reusable conclusions into cross-project or global layers.

The current mature shape has four layers:

- Markdown and Git are canonical.
- `AGENTS.md`, `yusu-kb`, search scripts, and `rg` are Codex's normal retrieval route.
- Obsidian is a human browsing UI, not a Codex dependency.
- Marginalia is an optional derived semantic research layer, not the source of truth.

## Most Important Things

| # | Thing | Why It Matters | Evidence |
|---:|---|---|---|
| 1 | The vault is the canonical manual memory store, not local `.codex\memories`. | Without this rule, Windows and Ubuntu fragment project facts and future Codex sessions repeat old mistakes. | `04_Runbooks/system-decisions.md`; commits `4f62a6e`, `4329e4d`. |
| 2 | Mature project ingestion needs history, failure archaeology, onboarding, evidence, and final routing. | Current-state summaries are not enough for long-running projects with many pivots and expensive failures. | `04_Runbooks/mature-project-ingestion.md`; commits `3f5693f`, `d44eb9b`. |
| 3 | Super-yusuV0.2 forces memory routing instead of project-local hoarding. | Reusable lessons must actually reach `03_CrossProject`, `02_GlobalMemory`, or `06_Maps`. | `04_Runbooks/super-yusu-v0.2-ingestion.md`; commit `50655d2`. |
| 4 | Marginalia is useful but derived. | Semantic search can help broad investigations, but Markdown/Git must remain the canonical truth to avoid stale indexes. | `04_Runbooks/super-yusu-v0.3-marginalia.md`; `03_CrossProject/tooling.md`; commits `1ed349b`, `45fe0b3`, `2cb4659`. |
| 5 | Session traversal must preserve privacy and evidence boundaries. | Large JSONL files are evidence, not content to paste into the vault. Metadata and topic counts are safer than raw transcript copies. | `session-log/2026-06-09-session-inventory.md`; commits `32eb7c1`, `6e15e77`, `f097c8e`. |
| 6 | The administrator role is separate from the project engineer role. | The vault administrator validates evidence, routes memory, and commits; the project Codex owns facts from its own repo/session. | `04_Runbooks/codex-ingestion-guide.md`; commits `3acac62`, `9c3ec90`. |

## Final Shape

The final baseline is a Git-backed Obsidian-compatible Markdown vault at `F:\AcademicHub\0#YUSU`, synchronized through private GitHub repo `Git-ys1/0-YUSU`.

Codex retrieval follows this order:

1. Global `AGENTS.md` points Codex back to the vault.
2. `yusu-kb` skill provides workflow rules and search locations.
3. `tools/search-kb.ps1` / `tools/search-kb.sh` and `rg` find text evidence.
4. Project entries in `01_Projects/` preserve facts.
5. `03_CrossProject/`, `02_GlobalMemory/`, and `06_Maps/` preserve reusable lessons.
6. Marginalia can be synced and reindexed for deep semantic research when needed.

The vault's own project entry is now treated as a mature project, not a light setup note.

## Hard-Won Lessons

- If a future Codex does not read `00_START_HERE_FOR_CODEX.md` and `system-decisions.md`, it will likely write memory to the wrong layer.
- If a mature project skips `09_session_evidence.md`, later readers cannot tell whether facts came from code, Git, session evidence, or guesses.
- If `10_project_summary.md` lacks `Memory Routing Audit`, the project may be documented but the system does not learn from it.
- If Marginalia is not resynced after Markdown changes, its DB and semantic index can lag behind the canonical vault.
- If raw session text is copied wholesale, the vault becomes noisy and risky; use metadata, IDs, file paths, and distilled lessons.
- If Ubuntu is assumed to share `F:` without a write-read check, cross-system memory can silently diverge.

## Rules For Future Codex

1. Before non-trivial work, read the vault entry points and search existing memory.
2. Do not hand-write canonical memories into local `.codex\memories`.
3. For mature project ingestion, find the engineer's own JSONL and run `mature-project-retro-audit`.
4. For administrator ingestion, validate evidence and mark gaps as `pending` instead of inventing missing project facts.
5. After adding or modifying project memory, update project README and relevant maps.
6. After Markdown merges, resync/reindex Marginalia before trusting semantic results.
7. Never store secrets, private keys, tokens, cookies, SSH passwords, or raw private conversation dumps.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| Canonical manual memory belongs in the vault, not local `.codex\memories`. | active global rule | `C:\Users\yusu\.codex\memories\ACTIVE.md`; `04_Runbooks/system-decisions.md` | kept | Already global instruction and system decision; this summary links it back to project evidence. |
| New skill installation cannot prove passive triggering in the same long thread. | cross-project tooling | `03_CrossProject/tooling.md` | kept | Existing active tooling note "Freshly installed Codex skills need a fresh discovery surface". |
| Marginalia is derived and must be synced/reindexed after Markdown changes. | cross-project tooling | `03_CrossProject/tooling.md`; `06_Maps/tool-map.md` | kept | Existing Marginalia tooling notes and tool map entries. |
| Mature project ingestion requires history, evidence, final summary, and routing audit. | global learning | `04_Runbooks/mature-project-ingestion.md`; `04_Runbooks/super-yusu-v0.2-ingestion.md` | kept | Protocol already promoted to runbooks; current project follows it. |
| Session traversal should record metadata and topic counts, not raw private text. | cross-project pattern | `tools/build-superyusu-session-inventory.ps1`; `session-log/2026-06-09-session-inventory.md` | written | New inventory tool and report implement the pattern for this vault. |
| GitHub may normalize repository names with special characters. | cross-project tooling | `03_CrossProject/tooling.md` | kept | Existing note "GitHub repository names may be normalized". |
| Ubuntu direct shared folder is not proven until both OSes write-read. | cross-project tooling | `03_CrossProject/tooling.md`; `05_known_issues.md` | kept | Existing dual-boot shared-folder note and project issue. |

## Remaining Risks

- Ubuntu 20.04 endpoint still needs a real clone/setup/write-read verification.
- Direct NTFS shared-folder behavior remains unproven.
- Marginalia is useful but operationally heavier than `rg`; future Codex should not default to it for small lookups.
- Existing project entries imported before the mature protocol may still need later V0.2 routing audits.
- The session inventory proves traversal, not semantic understanding of every raw chat. Project facts still require repository and session-specific evidence.
