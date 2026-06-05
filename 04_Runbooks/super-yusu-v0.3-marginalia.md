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

## Is This A New Project?

对本知识库来说，Marginalia 是一个新的可选研究层：代码已作为 submodule 部署，UI/API 已验证，但 `.marginalia-yusu/data` 里的数据库仍要等真实 LLM key 完成 ingest 后才会成为可用索引。也就是说：

- 上游 Marginalia 不是从零新写的项目；本库只是接入它。
- yusu vault 的 Marginalia library 目前是新库，需要 `sync -> ingest -> optional semantic index`。
- Obsidian 仍只是人类 UI；Codex 不依赖 Obsidian 检索。

## Configuration Matrix

| Capability | Required? | Variables | Current yusu decision |
|---|---:|---|---|
| Chat / agent answer | yes for real use | `LLM_DEFAULT_PROVIDER`, `LLM_DEFAULT_API_KEY`, `LLM_DEFAULT_MODEL`; or `LLM_CHAT_*` | Required before asking Marginalia to answer. Placeholder key is UI-only. |
| Reflection / journal | yes for full agent flow | `LLM_REFLECT_*` or default inheritance | Can inherit default provider/key/model. |
| Ingest metadata extraction | yes for actual `/ingest --all` | `LLM_INGEST_*` or default inheritance | Can inherit default provider/key/model. Without it, files may be projected but not meaningfully ingested. |
| Vision / scanned PDF | optional | `LLM_VISION_*` | Configure only when OCR/image/PDF vision matters. |
| Audio transcription | optional | `LLM_AUDIO_*` | Not needed for this Markdown vault. |
| Semantic recall | optional | `SEMANTIC_RECALL_ENABLED`, `EMBEDDING_PROVIDER`, `EMBEDDING_BASE_URL`, `EMBEDDING_API_KEY`, `EMBEDDING_MODEL`, `EMBEDDING_DIMENSIONS` | Use CarbonRAG local BGE-M3 shim when possible; otherwise leave disabled. |
| Rerank | optional | `RERANK_ENABLED`, `RERANK_API_KEY`, `RERANK_BASE_URL`, `RERANK_MODEL` | Leave disabled unless a real rerank HTTP API is configured. CarbonRAG has local reranker weights, but Marginalia does not directly load them yet. |

Important: Marginalia's embedding path currently supports only `dashscope` and `openai-compatible`. It does not directly support `RAG_EMBEDDING_PROVIDER=bge_m3`. To reuse CarbonRAG's local BGE-M3, run the local OpenAI-compatible shim below.

## Codex Proxy LLM Route

Current yusu decision: use the CLI proxy route, not `https://new.sharedchat.cc/codex`, because the latter is not safe for parallel use in this workflow.

Marginalia expects non-streaming `chat.completions`. The recommended CLI proxy can answer through streaming, while non-streaming responses may contain an empty `message.content`. Therefore this vault uses a local shim:

```powershell
.\tools\run-codex-proxy-llm-shim.ps1
```

It serves:

```text
http://127.0.0.1:8010/v1/chat/completions
```

Local Marginalia `.env` should point to the shim, not directly to the upstream proxy:

```ini
LLM_DEFAULT_PROVIDER=openai-compatible
LLM_DEFAULT_BASE_URL=http://127.0.0.1:8010/v1
LLM_DEFAULT_API_KEY=local-llm-key
LLM_DEFAULT_MODEL=gpt-5.4
```

The upstream API key is not stored in this vault. The shim reads it from `C:\Users\yusu\.codex\myself-api\config-self.toml` or from `YUSU_LLM_UPSTREAM_API_KEY`.

Smoke before ingest:

```powershell
.\tools\run-codex-proxy-llm-shim.ps1
```

In a second terminal:

```powershell
$body = @{ model="gpt-5.4"; messages=@(@{role="user"; content="Say OK."}); max_completion_tokens=128 } | ConvertTo-Json -Depth 6
Invoke-RestMethod -Uri "http://127.0.0.1:8010/v1/chat/completions" -Method Post -Headers @{ Authorization="Bearer local-llm-key"; "Content-Type"="application/json" } -Body $body
```

Do not run `sync-yusu-kb-to-marginalia.ps1 -Ingest` until this returns a `chat.completion` with non-empty `choices[0].message.content`.

Verification on 2026-06-05:

- CLI proxy streaming initially returned text `OK`.
- Local LLM shim converted streaming output into non-streaming `message.content`.
- Later the upstream CLI proxy returned `502 unknown provider for model gpt-5.4`, and `/models` returned an empty model list. This is an upstream/proxy routing outage, not a Marginalia config failure.

## CarbonRAG Local BGE-M3 Embedding Route

Evidence checked on this machine:

- CarbonRAG repo: `F:\Project\CarbonRag`
- Python: `F:\Project\CarbonRag\backend\.conda\python.exe`, Python `3.11.15`
- Embedding model: `F:\Project\CarbonRag\data\outputs\models\BAAI\bge-m3`
- Reranker model: `F:\Project\CarbonRag\data\outputs\models\BAAI\bge-reranker-v2-m3`
- CarbonRAG smoke expectation: BGE-M3 dense vector dimension is `1024`, with sparse weights also available.
- CarbonRAG does not expose a native `/v1/embeddings` route; its BGE-M3 path is a Python library call.

Start the local embedding shim on Windows:

```powershell
.\tools\run-carbonrag-bge-embedding-server.ps1
```

It serves:

```text
http://127.0.0.1:8011/v1/embeddings
```

Configure Marginalia with the shim in `.marginalia-yusu/.env` or the current shell environment:

```ini
EMBEDDING_PROVIDER=openai-compatible
EMBEDDING_BASE_URL=http://127.0.0.1:8011/v1
EMBEDDING_API_KEY=local-bge-key
EMBEDDING_MODEL=BAAI/bge-m3
EMBEDDING_DIMENSIONS=1024
EMBEDDING_BATCH_SIZE=4
SEMANTIC_RECALL_ENABLED=false
```

`local-bge-key` is a local dummy bearer token for a loopback-only service, not a secret. Do not expose this shim outside `127.0.0.1` unless authentication and network policy are redesigned.

Keep `SEMANTIC_RECALL_ENABLED=false` until a real semantic index exists. Use `-UseLocalBge` during index build; after a successful non-zero build, flip `SEMANTIC_RECALL_ENABLED=true`.

Build the yusu semantic index after real ingest:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
```

Ubuntu/Linux:

```bash
export CARBONRAG_ROOT="/mnt/f/Project/CarbonRag"
export CARBONRAG_PYTHON="/path/to/linux/python3.11-with-carbonrag-deps"
bash tools/run-carbonrag-bge-embedding-server.sh
```

Then in a second shell:

```bash
USE_LOCAL_BGE=true RESUME_ARG=--resume bash tools/build-marginalia-semantic-index-yusu.sh
```

Native Ubuntu cannot execute Windows `.conda\python.exe`. If Ubuntu is not WSL, create a Linux Python 3.11 environment with CarbonRAG backend dependencies, or use a separate Ubuntu clone of CarbonRAG with the same BGE-M3 model files available under its own `data/outputs/models/`.

Verification on 2026-06-05:

- `GET /health` returned 200 and confirmed the BGE-M3 model directory exists.
- `POST /v1/embeddings` returned 200 with one vector of dimension `1024`.
- `build-marginalia-semantic-index-yusu.ps1 -UseLocalBge` runs; before real ingest it correctly reports `entries: 0`.

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

Run the API server for the desktop/web UI:

```powershell
.\tools\run-marginalia-api-yusu.ps1
```

If you only want to inspect the UI before configuring a real LLM key, use:

```powershell
.\tools\run-marginalia-api-yusu.ps1 -AllowPlaceholderKey
```

The placeholder mode is UI-only. It lets `/health`, settings, and the desktop shell load, but real chat, ingest, reflection, and LLM-dependent background work will fail until a real API key is configured.

Run the browser UI in a second terminal:

```powershell
.\tools\run-marginalia-ui-yusu.ps1
```

Open:

```text
http://127.0.0.1:5173/
```

Why the UI script copies files first: Vite fails when the project root path contains `#` (`F:\AcademicHub\0#YUSU`). The script copies the desktop source to `F:\AcademicHub\YUSU-Marginalia-Desktop-Run`, installs Node dependencies there, and runs Vite from the no-`#` path. It also uses `node@22` through npm cache under `.tools/npm-cache`, because the system Node 24 triggered a Vite dependency pre-optimization crash during the initial UI test.

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

After ingest, if the local BGE-M3 shim is running and the embedding env is configured:

```powershell
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
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

After ingest, if local BGE-M3 is exposed through the shim:

```bash
USE_LOCAL_BGE=true RESUME_ARG=--resume bash tools/build-marginalia-semantic-index-yusu.sh
```

## How Codex Should Use It

Codex integration is procedural first, API/MCP later:

1. For ordinary tasks, use `yusu-kb`, `tools/search-kb.*`, and `rg`.
2. For broad cross-project questions, sync and ingest the vault into Marginalia.
3. If semantic recall is needed, start the CarbonRAG BGE-M3 shim and build the semantic index.
4. Ask Marginalia through UI/API/CLI for a cited synthesis.
5. When writing back to the vault, cite the actual Markdown sources Marginalia read, not "Marginalia said".

An MCP wrapper is not required yet. The first stable integration point is the committed runbook plus the scripts in `tools/`. Consider MCP only after the vault is large enough that multiple AI tools need the same remote search/read API.

## Verification From Initial Windows Deployment

Verified on 2026-06-04:

- `vendor/marginalia` cloned as a submodule at `70f28bc381aafd86f047f9fe422c594c86d4330e`.
- Repo-local venv created at `.tools/marginalia-venv/` using Python `3.11.15` from `F:\Project\Simple Oscilloscope\.venv\python.exe`.
- `pip install -e .\vendor\marginalia` succeeded inside `.tools/marginalia-venv/`.
- `marginalia --help` succeeded.
- `.marginalia-yusu/.env` was initialized with `MARGINALIA_HOME=F:/AcademicHub/0#YUSU/.marginalia-yusu/data`.
- 99 Markdown/TXT files were projected into `.marginalia-yusu/data/library/yusu-kb/`.
- `/check` started Marginalia embedded mode and detected the mirrored files as new.
- API server verified at `http://127.0.0.1:8000/health` with placeholder key and `WORKER_ENABLED=false`.
- Browser UI verified at `http://127.0.0.1:5173/`; Playwright confirmed the Chinese navigation pages: `聊天`, `资料库`, `搜索`, `设置`.
- Settings page verified server state: `MARGINALIA_HOME=F:\AcademicHub\0#YUSU\.marginalia-yusu\data`, SQLite, mirror storage, worker disabled.

`/ingest --all` is intentionally not complete until the user configures a real LLM API key. A placeholder key is acceptable only for read-only `/check`; it must not be written to `.env`.

## Safety Rules

- Never commit `.tools/`, `.marginalia-yusu/`, runtime DBs, cache, history, or `.env`.
- Never write API keys, tokens, cookies, private keys, or raw private data into the vault.
- Keep Marginalia as an optional research layer. New Codex sessions should still start with `00_START_HERE_FOR_CODEX.md`, `yusu-kb`, and `rg`.
- If Marginalia is used to support a knowledge-base conclusion, cite the source Markdown files it read, not merely "Marginalia said so".
