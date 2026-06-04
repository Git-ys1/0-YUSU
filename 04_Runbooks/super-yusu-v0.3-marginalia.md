# Super YUSU V0.3 Marginalia Integration

**Version**: super-yusuV0.3
**Status**: active
**Date**: 2026-06-04

V0.3 把 `shenmintao/marginalia` 接入本知识库，作为可选的深度研究和带引用调查层。它不替代 `rg`、`tools/search-kb.*` 或 `yusu-kb` skill；日常快速检索仍先走 Markdown + `rg`，跨大量文档的综合调查再使用 Marginalia。

## Current Integration State

- Upstream: `https://github.com/shenmintao/marginalia`
- Local source: `vendor/marginalia` Git submodule
- Pinned commit: `70f28bc381aafd86f047f9fe422c594c86d4330e`
- Upstream describe: `v0.2.1-4-g70f28bc`
- License: AGPL-3.0-or-later
- Runtime home: `.marginalia-yusu/`
- Python venv: `.tools/marginalia-venv/`
- Mirrored vault path inside Marginalia: `.marginalia-yusu/data/library/yusu-kb/`

All deployment artifacts are repo-local. Do not install Marginalia runtime, cache, venv, or history under `C:\Users\...`.

## What Marginalia Adds

Use Marginalia when the task needs:

- Cross-document investigation across many project memories.
- Source-grounded reports with citations.
- Reading original Markdown/PDF/DOCX/spreadsheet/log slices after recall.
- Persistent investigation journal beyond a single Codex turn.
- More careful evidence collection than keyword search.

Do not use it for every small lookup. It is slower and requires LLM API configuration for ingest and agent answers.

## Deployment Rule Learned In V0.3

Before installing a new runtime, search this knowledge vault for existing project toolchains. In this integration, PATH only exposed Python 3.7 and `uv` was absent, but `01_Projects/simple-oscilloscope/02_runbook.md` already recorded a Python 3.11 venv. The working interpreter was:

```text
F:\Project\Simple Oscilloscope\.venv\python.exe
```

Use known repo-local or project-local interpreters before downloading new ones.

## Windows Setup

From `F:\AcademicHub\0#YUSU`:

```powershell
.\tools\setup-marginalia-yusu.ps1 -SyncProjection
```

The setup script:

1. Initializes `vendor/marginalia` if the submodule is missing.
2. Finds Python 3.11+ from `YUSU_MARGINALIA_PYTHON` or the known Simple Oscilloscope venv.
3. Creates `.tools/marginalia-venv/`.
4. Installs `vendor/marginalia` editable into that venv.
5. Initializes `.marginalia-yusu/`.
6. Keeps `TEMP`, `TMP`, `PIP_CACHE_DIR`, `HOME`, and `USERPROFILE` inside this repo during setup/run.

Run the CLI:

```powershell
.\tools\run-marginalia-yusu.ps1
```

Sync this Markdown vault into Marginalia mirror storage:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1
```

Read-only check without a real API key:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Check
```

Actual ingest requires a real key in `.marginalia-yusu/.env`:

```ini
LLM_DEFAULT_PROVIDER=openai
LLM_DEFAULT_API_KEY=...
LLM_DEFAULT_MODEL=gpt-4o-mini
```

Then:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
```

## Ubuntu/Linux Setup

After cloning this private repo with submodules:

```bash
git submodule update --init --recursive
YUSU_MARGINALIA_PYTHON=/path/to/python3.11 bash tools/setup-marginalia-yusu.sh --sync-projection
bash tools/run-marginalia-yusu.sh
```

If `python3.11` is already on PATH:

```bash
bash tools/setup-marginalia-yusu.sh --sync-projection
```

Read-only check:

```bash
bash tools/sync-yusu-kb-to-marginalia.sh --check
```

Actual ingest:

```bash
bash tools/sync-yusu-kb-to-marginalia.sh --ingest
```

## Verification From Initial Windows Deployment

Verified on 2026-06-04:

- `vendor/marginalia` cloned as a submodule at `70f28bc381aafd86f047f9fe422c594c86d4330e`.
- Repo-local venv created at `.tools/marginalia-venv/` using Python `3.11.15` from `F:\Project\Simple Oscilloscope\.venv\python.exe`.
- `pip install -e .\vendor\marginalia` succeeded inside `.tools/marginalia-venv/`.
- `marginalia --help` succeeded.
- `.marginalia-yusu/.env` was initialized with `MARGINALIA_HOME=F:/AcademicHub/0#YUSU/.marginalia-yusu/data`.
- 99 Markdown/TXT files were projected into `.marginalia-yusu/data/library/yusu-kb/`.
- `/check` started Marginalia embedded mode and detected the mirrored files as new.

`/ingest --all` is intentionally not complete until the user configures a real LLM API key. A placeholder key is acceptable only for read-only `/check`; it must not be written to `.env`.

## Safety Rules

- Never commit `.tools/`, `.marginalia-yusu/`, runtime DBs, cache, history, or `.env`.
- Never write API keys, tokens, cookies, private keys, or raw private data into the vault.
- Keep Marginalia as an optional research layer. New Codex sessions should still start with `00_START_HERE_FOR_CODEX.md`, `yusu-kb`, and `rg`.
- If Marginalia is used to support a knowledge-base conclusion, cite the source Markdown files it read, not merely "Marginalia said so".
