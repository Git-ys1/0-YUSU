# Architecture

## System Overview

The vault is a Git-backed Obsidian-compatible Markdown repository. Windows is the primary host, GitHub private remote is the cross-system synchronization layer, and Ubuntu consumes the same knowledge base by clone/pull/push or by direct NTFS mount if that path is later verified.

## Main Modules

| Module | Responsibility | Notes |
|---|---|---|
| `01_Projects/` | Project-specific long-term memory | One slug per project |
| `02_GlobalMemory/` | Shared profile, active rules, learnings, errors, feature requests | Canonical manual memory layer |
| `03_CrossProject/` | Reusable pitfalls, patterns, tooling notes | For lessons spanning projects |
| `04_Runbooks/` | Operating procedures | GitHub sync, Ubuntu setup, ingestion, retrieval |
| `05_Templates/` | Project memory templates | Used by `new-project-memory` scripts |
| `06_Maps/` | Obsidian/Codex navigation maps | Keeps large vault navigable |
| `.agents/skills/yusu-kb/` | Canonical source of the yusu-kb skill | Linked into `.agents/skills` and `.codex/skills` |
| `tools/` | Deterministic setup, search, and verification scripts | Windows and Bash variants |

## Data Flow

1. A Codex session starts and reads global `AGENTS.md`.
2. Global AGENTS points it to `YUSU_KB_ROOT`.
3. The `yusu-kb` skill and `tools/search-kb.*` search project/cross-project memory.
4. Non-trivial work updates project memory or cross-project memory.
5. Changes are committed and pushed to `Git-ys1/0-YUSU`.
6. Other systems pull or clone the same repository and run endpoint setup scripts.

## Boundaries

- Do not treat Obsidian plugins as required for Codex retrieval.
- Do not use local generated Codex Memories as the canonical cross-system store.
- Do not assume Ubuntu direct access until Ubuntu-side verification succeeds.
- Do not commit `00_Inbox/shared-checks/` verification scratch files.

## Source Evidence

- Files: `04_Runbooks/system-decisions.md`, `04_Runbooks/codex-retrieval-workflow.md`, `04_Runbooks/github-sync.md`
- Commands:
  - `gh repo view Git-ys1/0-YUSU --json nameWithOwner,visibility,url,isPrivate,defaultBranchRef,pushedAt`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\search-kb.ps1 -Query "GitHub private remote yusu-kb Codex Memories canonical"`
- Last verified: 2026-06-03
