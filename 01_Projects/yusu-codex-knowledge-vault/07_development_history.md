# Development History

## Timeline Summary

| Date | Phase | Evidence | Result |
|---|---|---|---|
| 2026-06-03 | Vault foundation | commit `4f62a6e` 初始化YUSU共享知识库 | Established `F:\AcademicHub\0#YUSU` as the canonical Markdown vault. |
| 2026-06-03 | GitHub sync | commits `676532d`, `4c08d1c` | Confirmed private remote `Git-ys1/0-YUSU` and added endpoint setup scripts. |
| 2026-06-03 | Self memory entry | commit `66b2300` | Created the first project memory entry for the vault itself. |
| 2026-06-03 | Old memory import | commit `4329e4d` | Imported legacy Codex memory into the new canonical structure. |
| 2026-06-04 | Mature ingestion protocol | commits `3f5693f`, `d44eb9b`, `50655d2` | Added mature project workflow, summary layer, and super-yusuV0.2 routing audit. |
| 2026-06-04 | Marginalia research layer | commits `1ed349b`, `20b3874` | Added optional Marginalia deep research route without replacing Markdown as canonical. |
| 2026-06-04 | First project validations | commits `7ced968`, `3acac62`, `9c3ec90` | Validated mature ingestion on Auto Play and Simple Oscilloscope and clarified administrator review duties. |
| 2026-06-05 | Local LLM/embedding research | commits `45fe0b3`, `2cb4659` | Added CarbonRAG BGE and Codex proxy shim runbooks for Marginalia. |
| 2026-06-08 | Larger project imports | commits `cc6e607`, `5683218`, `07b9a91` | Added CleanScout entries and recorded mature project verification. |
| 2026-06-09 | Session traversal evidence | commits `32eb7c1`, `6e15e77`, `f097c8e` | Added a SuperYUSU session inventory tool and report covering 38 local JSONL files. |

## Phase Notes

### Phase 1: Canonical vault instead of scattered memories

The first design problem was not a lack of notes. It was that project facts, user preferences, Codex Memories, and temporary chat findings were scattered across OS-local places. The decision in `04_Runbooks/system-decisions.md` made the vault itself the canonical manual memory store.

The key tradeoff was to keep the source of truth as plain Markdown and Git. That made Obsidian useful for humans while keeping Codex retrieval simple through `AGENTS.md`, the `yusu-kb` skill, `tools/search-kb.*`, and `rg`.

The remote name became a first pitfall. The requested repository name `0#YUSU` was normalized by GitHub to `0-YUSU`, so every future runbook has to distinguish local path from remote repository.

### Phase 2: Endpoint setup and discovery

The next phase made the vault discoverable by future Codex sessions. Windows setup linked the `yusu-kb` skill into both `.agents/skills` and `.codex/skills`, and global `AGENTS.md` began pointing non-trivial project work back to this vault.

This exposed a subtle limitation: a skill created during an already-running Codex thread cannot prove passive auto-triggering inside that same thread. The project therefore records the difference between validating skill files and proving fresh-session discovery.

### Phase 3: From lightweight notes to mature project ingestion

The project quickly outgrew lightweight project memory. Mature projects such as Simple Oscilloscope, Auto Play, CarbonRag, and CleanScout had long histories, large session files, and many architectural turns. The vault added `04_Runbooks/mature-project-ingestion.md` to force development history, failure history, onboarding, evidence, and final summary files.

The important decision was that mature ingestion is not "write current status." It must reconstruct why the project exists, what failed, what was abandoned, which mistakes are expensive, and which lessons should become cross-project memory.

### Phase 4: Super-yusuV0.2 routing audit

V0.2 added the rule that mature projects cannot stop at project-local summaries. The final summary must include a `Memory Routing Audit` and explicitly decide whether each lesson stays project-only, enters cross-project files, becomes a global learning, updates maps, or is deferred.

This turned the vault from a folder of notes into an ingestion protocol. It also created a clear administrator role: project Codex instances may write entries, but the vault administrator validates evidence, routing, sensitivity, indexes, and commits.

### Phase 5: Marginalia as derived research layer

Marginalia was added as a deep research layer, not as the canonical store. The canonical source remains Markdown and Git. Marginalia SQLite state and semantic indexes are derived and must be rebuilt after Markdown changes.

This phase created useful tooling lessons: local BGE-M3 needs an OpenAI-compatible embedding shim, Marginalia needs a non-streaming chat-completions route, and scripts must wait for ingest tasks rather than assuming file projection means database ingestion is done.

### Phase 6: Mature imports and project-scale validation

The vault validated itself by ingesting real projects. Auto Play and Simple Oscilloscope demonstrated that mature entries need failure history and verified commands. CleanScout showed the need to split one physical repo into separate project slices when frontend/backend and lower-firmware histories are different.

This phase also proved that maps matter. As project count grew, `06_Maps/project-map.md`, `tool-map.md`, and other maps became navigation infrastructure, not cosmetic extras.

### Phase 7: Session traversal audit

On 2026-06-09 the project added a privacy-preserving session inventory. It scanned 38 local `rollout-*.jsonl` files totaling about 2342 MB by metadata and topic counts, without copying raw private conversation text into the vault.

This was a pragmatic compromise between the user's request for strict traversal and the mature-ingestion rule that a project engineer should not dump other engineers' raw JSONL content. The inventory proves traversal coverage while `09_session_evidence.md` keeps the primary project session explicit.

## Lessons By Stage

- A canonical Markdown vault solves memory fragmentation only if every project Codex is forced to read it before work and update it after meaningful work.
- GitHub private sync is the safe cross-system baseline; direct Windows/Ubuntu NTFS sharing remains unproven until both systems write and read a check file.
- Skills are workflow entry points, not magical evidence. New skills require fresh discovery surfaces before claiming passive triggering.
- Mature project memory needs a development history and a final routing audit; otherwise it becomes a polished but isolated project diary.
- Marginalia is useful for broad cited investigation, but it is derived state. Markdown/Git remains the truth.
- Session inventory should record metadata, IDs, cwd, sizes, and topic counts, not raw private conversation text.
- Administrator Codex should verify and route project submissions rather than invent project facts from memory.
