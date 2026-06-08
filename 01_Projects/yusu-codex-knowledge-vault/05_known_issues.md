# Known Issues and Pitfalls

## Issue: GitHub normalized requested repository name
**Status**: active
**Severity**: medium
**Last Seen**: 2026-06-03

### Symptom

User requested private repository name `0#YUSU`; GitHub created/returned `https://github.com/Git-ys1/0-YUSU`.

### Likely Cause

GitHub normalized unsupported or unsafe repository name characters.

### Verified Fix or Workaround

Keep local directory name `0#YUSU`; document remote as `Git-ys1/0-YUSU`.

### Codex Rule

When referencing the cloud remote, use `https://github.com/Git-ys1/0-YUSU`; when referencing the Windows host path, use `F:\AcademicHub\0#YUSU`.

### Evidence

- `gh repo create '0#YUSU' --private` returned `https://github.com/Git-ys1/0-YUSU`.

## Issue: Current long thread cannot prove fresh skill auto-trigger
**Status**: active
**Severity**: medium
**Last Seen**: 2026-06-03

### Symptom

The `yusu-kb` skill was created after this Codex thread started, so the current thread's initial skill list did not include it.

### Likely Cause

Skill metadata is loaded at thread/session startup.

### Verified Fix or Workaround

Validate the skill file and discovery links now, and expect new Codex sessions to see it after restart/new thread.

### Codex Rule

Do not claim passive skill triggering is proven in the same long thread that installed the skill. Prove what can be proven: valid skill, linked discovery paths, global AGENTS entry, and working search.

### Evidence

- `C:\Users\yusu\.codex\skills\yusu-kb\SKILL.md` exists.
- `C:\Users\yusu\.agents\skills\yusu-kb\SKILL.md` exists.
- `quick_validate.py` reports `Skill is valid!`.
- `tools/check-codex-startup-readiness.ps1` verifies global AGENTS, skill paths, and search before a fresh Codex session relies on them.

## Issue: Direct Ubuntu shared folder is not automatically available
**Status**: active
**Severity**: high
**Last Seen**: 2026-06-03

### Symptom

Windows path `F:\AcademicHub\0#YUSU` is not automatically visible from a separate Ubuntu 20.04 dual-boot system.

### Likely Cause

The systems do not share a live filesystem unless Ubuntu mounts the Windows NTFS partition, and Windows Fast Startup/hibernate state can block safe writes.

### Verified Fix or Workaround

Use GitHub private repo clone/pull/push as the reliable cross-system path. Direct NTFS mount remains optional and must be verified from Ubuntu.

### Codex Rule

Do not call `F:\AcademicHub\0#YUSU` a proven shared folder until Ubuntu writes `00_Inbox/shared-checks/ubuntu-*.md` and Windows reads it.

## Issue: Mature project entries can become project-local silos
**Status**: active
**Severity**: high
**Last Seen**: 2026-06-09

### Symptom

A mature project can have a long, polished `01_Projects/<slug>/` entry while reusable lessons never reach `03_CrossProject/`, `02_GlobalMemory/`, or `06_Maps/`.

### Likely Cause

The writer summarizes the project but does not perform the second-pass routing audit required by super-yusuV0.2.

### Verified Fix or Workaround

Every mature project must include `10_project_summary.md` with `Most Important Things` and `Memory Routing Audit`. Run `tools/mature-project-retro-audit.*` before declaring completion.

### Codex Rule

If a mature project only changes `01_Projects/<slug>/`, explain in `Memory Routing Audit` why every important lesson is project-only. Otherwise route reusable lessons.

### Evidence

- `04_Runbooks/mature-project-ingestion.md`
- `04_Runbooks/super-yusu-v0.2-ingestion.md`

## Issue: Session traversal can accidentally become raw transcript dumping
**Status**: active
**Severity**: high
**Last Seen**: 2026-06-09

### Symptom

Strict session review requests can tempt an agent to copy large raw JSONL conversation content into the vault.

### Likely Cause

The user needs evidence that sessions were traversed, but the system also needs privacy, compactness, and project-specific evidence boundaries.

### Verified Fix or Workaround

Use a metadata and topic-count inventory instead of raw transcript copying. Keep exact session IDs, paths, cwd, sizes, and topic hit counts, then use the project-specific session as primary evidence.

### Codex Rule

For vault administrator audits, record session metadata and traversal coverage. For project facts, use the owning engineer's project session, Git history, and repository evidence.

### Evidence

- `tools/build-superyusu-session-inventory.ps1`
- `01_Projects/yusu-codex-knowledge-vault/session-log/2026-06-09-session-inventory.md`
