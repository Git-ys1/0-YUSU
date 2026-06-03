# Project Brief

## One Sentence

YUSU Codex Knowledge Vault is the canonical shared Markdown knowledge base for yusu's cross-project Codex memories, project lessons, runbooks, and reusable debugging knowledge.

## Current Goal

Make future Codex sessions on Windows and Ubuntu find, search, update, and publish the same knowledge base before starting non-trivial project work.

## Core Constraints

- Windows host path is `F:\AcademicHub\0#YUSU`.
- GitHub private remote is `https://github.com/Git-ys1/0-YUSU`.
- GitHub normalized the requested name `0#YUSU` to `0-YUSU`; keep this distinction explicit.
- Ubuntu direct NTFS sharing is not assumed complete until Ubuntu writes a verification file that Windows can read.
- Codex canonical manual memory is this repo, not per-system `~/.codex/memories`.
- Obsidian is a human UI; Codex retrieval uses Markdown, `rg`, `search-kb`, AGENTS, and `yusu-kb`.

## Current Stage

Initial Windows host deployment is complete and pushed to GitHub. Ubuntu setup is ready but still needs to be run on the Ubuntu 20.04 system.

## Source Evidence

- Project path: `F:\AcademicHub\0#YUSU`
- Last verified: 2026-06-03
- Evidence files/logs:
  - `04_Runbooks/github-sync.md`
  - `04_Runbooks/completion-audit.md`
  - `04_Runbooks/system-decisions.md`
  - `tools/setup-codex-endpoint.ps1`
  - `tools/setup-codex-endpoint.sh`

