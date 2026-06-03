# Technical Decisions

## Decision: Use GitHub private repo as the cross-system sync layer
**Status**: accepted
**Date**: 2026-06-03

### Context

Direct Windows/Ubuntu sharing requires Ubuntu to mount the Windows NTFS partition and must be verified from Ubuntu. Until that is done, Ubuntu cannot be assumed to see or modify `F:\AcademicHub\0#YUSU`.

### Decision

Use GitHub private repository `https://github.com/Git-ys1/0-YUSU` as the cross-system synchronization layer. Keep Windows local path `F:\AcademicHub\0#YUSU` as the primary host.

### Consequences

- Ubuntu can clone/pull/push even if direct NTFS mount is not configured.
- Every endpoint must run `tools/setup-codex-endpoint.*`.
- Conflicts are handled through Git rather than ad hoc file copying.

### Evidence

- `gh repo view Git-ys1/0-YUSU` showed `visibility=PRIVATE`.
- `git ls-remote --heads origin main` showed the pushed `main` branch.

## Decision: Do not make Obsidian the Codex retrieval dependency
**Status**: accepted
**Date**: 2026-06-03

### Context

The vault should be useful in Obsidian, but Codex can already read Markdown files directly and use `rg`.

### Decision

Use Obsidian for human browsing and maps, while Codex uses `AGENTS.md`, `yusu-kb`, `tools/search-kb.*`, and `rg`.

### Consequences

- The system works without Obsidian installed.
- Obsidian plugins such as Smart Connections can be added later for human-side semantic search.
- MCP is deferred until the vault grows enough to require semantic or API-based retrieval.

## Decision: Canonical manual memory lives in this repository
**Status**: accepted
**Date**: 2026-06-03

### Context

Each OS has its own `~/.codex/memories`, so using that as the main cross-system store would fragment memory.

### Decision

Write reusable manual project/cross-project memory into this repo. Treat `~/.codex/memories` as local generated recall only.

### Consequences

- Project facts go to `01_Projects/<project-slug>/`.
- Cross-project lessons go to `03_CrossProject/`.
- Global candidates go to `02_GlobalMemory/LEARNINGS.md`.
- Stable rules go to `02_GlobalMemory/ACTIVE.md`.

