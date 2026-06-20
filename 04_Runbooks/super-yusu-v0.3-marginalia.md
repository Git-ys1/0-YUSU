# Super YUSU V0.3 Marginalia Integration

**Version**: super-yusuV0.3
**Status**: active
**Date**: 2026-06-04

V0.3 把 `shenmintao/marginalia` 接入本知识库，作为可选的深度研究和带引用调查层。它不替代 `rg`、`tools/search-kb.*` 或 `yusu-kb` skill；日常快速检索仍先走 Markdown + `rg`，跨大量文档的综合调查再使用 Marginalia。

## Current Integration State

- Upstream: `https://github.com/shenmintao/marginalia`
- Upstream reference source: `vendor/marginalia` Git submodule
- Integrated backend source: `07_PersonalSite/marginalia-backend/marginalia`
- Integrated React UI source: `07_PersonalSite/marginalia-ui`
- Pinned commit: `70f28bc381aafd86f047f9fe422c594c86d4330e`
- Upstream describe: `v0.2.1-4-g70f28bc`
- License: AGPL-3.0-or-later
- Runtime home: `.marginalia-yusu/`
- Python venv: `.tools/marginalia-venv/`
- Mirrored vault path inside Marginalia: `.marginalia-yusu/data/library/yusu-kb/`
- Ingest state on 2026-06-20: `sync-yusu-kb-to-marginalia.ps1 -Check` reports `in_sync=198`, `new=0`, `modified=0`, `missing=0`, `moved=0`; SQLite live files are 198 `done`.
- Semantic index state on 2026-06-20: `semantic-index/default` still has 179 entries, `BAAI/bge-m3`, 1024 dimensions. This vector layer is behind the now-current SQLite ingest and should be rebuilt during a deliberate maintenance window, not during quick UI/source-integration repair.
- Integrated UI/API/backend state on 2026-06-20: one FastAPI process at `http://127.0.0.1:8787` loads `07_PersonalSite/marginalia-backend`, serves `/v1`, `/health`, the YUSU personal site, and the source-integrated React UI under `/marginalia/*`.
- Personal-site integration on 2026-06-20: native Agent at `http://127.0.0.1:8787/marginalia/chat`; no iframe, `5173` Vite runtime, separate `8000` API, or proxy page is required.
- Optional embedding compute remains at `http://127.0.0.1:8011/v1`; this is a CarbonRAG model adapter, not a second Marginalia frontend/backend.

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

对本知识库来说，Marginalia 是一个新的可选研究层：代码已作为 submodule 部署，UI/API 已验证，`.marginalia-yusu/data` 已经完成一次真实 ingest 和本地 BGE-M3 semantic index。也就是说：

- 上游 Marginalia 不是从零新写的项目；本库只是接入它。
- yusu vault 的 Marginalia library 已可用于 metadata search 和本地 semantic recall；Markdown 变更后仍要重新跑 `sync -> ingest -> semantic index`。
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

## DeepSeek LLM Route

Current yusu decision: use DeepSeek's official OpenAI-compatible API as the default long-term Marginalia LLM route.

Official API facts checked from DeepSeek docs on 2026-06-19:

- OpenAI-compatible `base_url`: `https://api.deepseek.com`
- Chat endpoint: `https://api.deepseek.com/chat/completions`
- Current model IDs from `/models`: `deepseek-v4-flash`, `deepseek-v4-pro`
- Legacy `deepseek-chat` and `deepseek-reasoner` are documented as deprecated after 2026-07-24.

Use the local helper to write the ignored runtime `.env`:

```powershell
$env:DEEPSEEK_API_KEY = "<real key>"
.\tools\configure-marginalia-deepseek.ps1
```

Ubuntu/Linux:

```bash
export DEEPSEEK_API_KEY="<real key>"
bash tools/configure-marginalia-deepseek.sh
```

The helper writes only `.marginalia-yusu/.env`, which is ignored by Git. Never commit a real key.

Current intended Marginalia LLM `.env` shape:

```ini
LLM_DEFAULT_PROVIDER=openai-compatible
LLM_DEFAULT_BASE_URL=https://api.deepseek.com
LLM_DEFAULT_API_KEY=<real key in ignored file only>
LLM_DEFAULT_MODEL=deepseek-v4-flash
```

Why `deepseek-v4-flash` is the default: on 2026-06-19, `deepseek-v4-flash` returned non-empty `message.content=OK` in a non-streaming smoke test. `deepseek-v4-pro` returned reasoning text but empty `message.content` when the token budget was too small, so it is available as a manual override but not the default first-run model for Marginalia Agent.

After changing the key/model:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
```

Verified on 2026-06-19:

- DeepSeek `/models` returned `deepseek-v4-flash` and `deepseek-v4-pro`.
- `sync-yusu-kb-to-marginalia.ps1 -Ingest` applied 47 new files and 18 modified files, then waited for 68 background tasks to finish.
- Follow-up `-Check` returned `new=0`, `modified=0`.
- Semantic index rebuilt to 179 entries with `BAAI/bge-m3`, 1024 dimensions.
- Personal-site Agent smoke via `/api/agent/chat` produced `tool_call`, `answer`, and `done` events for a CleanScout evidence question.

## Historical Codex Proxy LLM Route

Historical yusu decision: the CLI proxy route was previously preferred over `https://new.sharedchat.cc/codex`, because the latter was not safe for parallel use in that workflow.

This route is historical/backup as of 2026-06-19. Prefer DeepSeek unless the user explicitly wants to test the old proxy again.

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
- After the user adjusted CLI proxy, `http://127.0.0.1:8010/v1/chat/completions` again returned non-empty `OK`; this was enough to run Marginalia ingest.
- Later the same upstream returned `502 unknown provider for model gpt-5.4`, `/models` returned an empty model list, and common model aliases also failed. This is an upstream/proxy routing outage, not a Marginalia config failure.
- Current consequence: metadata search and BGE semantic recall work; Marginalia chat/agent answers remain unavailable while the upstream LLM proxy is in this state.

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
- Before real ingest, `build-marginalia-semantic-index-yusu.ps1 -UseLocalBge` correctly reported `entries: 0`.
- After real ingest, `build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume` built 98/98 semantic entries in `semantic-index/default`.
- Direct semantic search for `Python 3.11 environment for oscilloscope project` returned Simple Oscilloscope `README.md` and `02_runbook.md` as top hits.

## Deployment Rule Learned In V0.3

Before installing a new runtime, search this knowledge vault for existing toolchains. Do not bind this management vault to another active project venv as a long-term dependency.

The initial 2026-06-04 deployment temporarily used the Simple Oscilloscope Python 3.11 venv because PATH only exposed old Python builds and `uv` was absent. That workaround was retired on 2026-06-20. Current Windows setup should use a standalone interpreter, preferably the Codex runtime Python stored on F:

```text
F:\AcademicHub\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe
```

`C:\Users\yusu\.cache\codex-runtimes` is a junction to `F:\AcademicHub\.cache\codex-runtimes`, so seeing the C path in tool output does not mean the runtime cache is consuming C drive space.

## Windows Setup

From `F:\AcademicHub\0#YUSU`:

```powershell
.\tools\setup-marginalia-yusu.ps1 -SyncProjection
```

The setup script:

1. Initializes `vendor/marginalia` if the submodule is missing.
2. Finds Python 3.11+ from `-Python`, `YUSU_MARGINALIA_PYTHON`, or the known F-drive Codex runtime Python.
3. Creates `.tools/marginalia-venv/`.
4. Installs `vendor/marginalia` editable into that venv.
5. Initializes `.marginalia-yusu/`.
6. Keeps `TEMP`, `TMP`, `PIP_CACHE_DIR`, `HOME`, and `USERPROFILE` inside this repo during setup/run.

The legacy Simple Oscilloscope fallback is disabled by default and only allowed when `YUSU_ALLOW_PROJECT_PYTHON_FALLBACK=1` is deliberately set for emergency recovery.

Run the CLI for isolated upstream debugging only:

```powershell
.\tools\run-marginalia-yusu.ps1
```

Build the integrated React UI once after setup or source changes:

```powershell
.\tools\build-yusu-integrated-marginalia-ui.ps1
```

Start the integrated personal site and local integrated Marginalia backend:

```powershell
.\tools\run-yusu-personal-site.ps1
```

Open:

```text
http://127.0.0.1:8787/marginalia/chat
```

`run-marginalia-api-yusu.*`, `run-marginalia-ui-yusu.*`, and `vendor/marginalia` remain only for isolated upstream debugging/reference. They are not part of normal YUSU personal-site startup.

## Open Marginalia Locally

Normal startup uses one application process plus the optional BGE model service:

```powershell
.\tools\configure-marginalia-deepseek.ps1
.\tools\run-carbonrag-bge-embedding-server.ps1
.\tools\run-yusu-personal-site.ps1
```

Then open:

```text
http://127.0.0.1:8787/marginalia/chat
```

Ports:

| Port | Service | Purpose |
|---:|---|---|
| 8011 | CarbonRAG BGE-M3 embedding shim | Exposes local BGE-M3 as OpenAI-compatible `/v1/embeddings`. |
| 8787 | Integrated YUSU + Marginalia | Personal site, `/api/*`, native `/v1/*`, `/health`, and React `/marginalia/*` routes in one FastAPI process. |

At runtime, ports `8000` and `5173` should not be listening. If semantic recall is disabled, `8011` is not required either.

## Where To Adjust API Parameters

Do not edit committed Markdown or scripts to store real keys. Runtime parameters live in ignored local files or environment variables:

| Setting | File / Env | Notes |
|---|---|---|
| Marginalia provider/base/model | `.marginalia-yusu/.env` | Ignored by Git. Safe place for local provider names and loopback base URLs. |
| DeepSeek API key | `DEEPSEEK_API_KEY` before running the helper, then ignored `.marginalia-yusu/.env` | Do not copy the real key into committed files. |
| DeepSeek model/base URL | `DEEPSEEK_MODEL`, `DEEPSEEK_BASE_URL`, or helper defaults | Default model is `deepseek-v4-flash`; base URL is `https://api.deepseek.com`. |
| Embedding model path | `CARBONRAG_ROOT`, `CARBONRAG_PYTHON`, or script defaults | Windows default points to `F:\Project\CarbonRag`. |

Current intended Marginalia `.env` shape:

```ini
LLM_DEFAULT_PROVIDER=openai-compatible
LLM_DEFAULT_BASE_URL=https://api.deepseek.com
LLM_DEFAULT_API_KEY=<real key in ignored .env only>
LLM_DEFAULT_MODEL=deepseek-v4-flash

EMBEDDING_PROVIDER=openai-compatible
EMBEDDING_BASE_URL=http://127.0.0.1:8011/v1
EMBEDDING_API_KEY=local-bge-key
EMBEDDING_MODEL=BAAI/bge-m3
EMBEDDING_DIMENSIONS=1024
SEMANTIC_RECALL_ENABLED=true
```

If the DeepSeek key or model changes, rerun `tools/configure-marginalia-deepseek.*`, restart `run-yusu-personal-site.*`, smoke `/api/marginalia/status`, then run ingest/reindex if Markdown has changed.

2026-06-20 live status:

- `http://127.0.0.1:8787/api/marginalia/status` reports `integration=same-process`, `apiBase=/v1`, `uiBase=/marginalia`, `workerEnabled=true`, and DeepSeek `deepseek-v4-flash`.
- The same status endpoint reports `backendSource=F:\AcademicHub\0#YUSU\07_PersonalSite\marginalia-backend`, proving runtime imports the committed local backend source.
- Only integrated port `8787` and optional BGE port `8011` were listening; `8000/5173` were stopped.
- Playwright navigated from the personal site into `/marginalia/chat`, completed a real same-origin streamed answer, and verified desktop `1280x720` plus mobile `390x844` chat/library layouts with zero console errors.
- `sync-yusu-kb-to-marginalia.ps1 -Check` reports `in_sync=198`, `new=0`, `modified=0`, `missing=0`, `moved=0`; DB verification reports 198 live files, all `ingest_status=done`.
- Semantic index manifest still reports 179 entries, `BAAI/bge-m3`, 1024 dimensions; rebuild later with `build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume`.
- The old CLI proxy failure is retained as historical troubleshooting in [[02_GlobalMemory/ERRORS#ERR-20260618-001-marginalia_llm_proxy_token_expired]].

## Why The Index Can Lag Behind Markdown

The Markdown vault is canonical. Marginalia is a derived mirror plus SQLite database plus optional semantic index. New commits, local edits, or incoming project memory are not visible to Marginalia chat/semantic recall until this chain is rerun:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Check
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
```

`-Check` only projects files and reports differences. It does not update summaries or embeddings. The local personal site at `07_PersonalSite/` intentionally uses live Markdown scanning, so it can find newly written vault files even when Marginalia has not caught up.

Do not block unrelated site or documentation changes on a full semantic rebuild. The current builder is all-entry rather than content-incremental after a completed index, and a 179-entry local BGE-M3 rebuild took about 55 minutes on 2026-06-19. Bring SQLite ingest current first; run the vector rebuild as a deliberate maintenance checkpoint.

If ingest stalls with `UNIQUE constraint failed: entry_tags.entry_id, entry_tags.tag_id`, check whether a pipeline returned duplicate tag suggestions in one file. The YUSU integrated backend patch under `07_PersonalSite/marginalia-backend/marginalia/tasks/handlers/ingest_file.py` deduplicates tag ids inside the transaction and only increments `Tag.doc_count` when a new `entry_tags` relation is actually attached. The regression test is:

```powershell
& .\.tools\marginalia-venv\Scripts\python.exe .\07_PersonalSite\tests\test_marginalia_ingest_tags.py
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

Actual ingest requires a working LLM profile in `.marginalia-yusu/.env`. On this machine the intended route is DeepSeek:

```ini
LLM_DEFAULT_PROVIDER=openai-compatible
LLM_DEFAULT_BASE_URL=https://api.deepseek.com
LLM_DEFAULT_API_KEY=<real key in ignored .env only>
LLM_DEFAULT_MODEL=deepseek-v4-flash
```

Then:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
```

The script sends `/ingest --all --yes` and waits for queued background tasks before returning. If it returns successfully, verify DB state rather than assuming only the file projection happened.

Important lifecycle boundary: Markdown/Git is the canonical knowledge store; Marginalia is a derived SQLite + semantic index. A committed Markdown merge is not visible to Marginalia chat or semantic recall until the vault is projected, ingested, and the semantic index is rebuilt. After multi-agent merges, always run:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Check
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
```

`Projected N` can be larger than `in_sync` when the projection includes hidden-path files such as `.agents/...`; Marginalia's scanner skips any path part beginning with `.`. Treat `new=0`, `modified=0`, `missing=0`, and `moved=0` as the sync signal.

If a modified file stays `ingest_status=pending` while its `ingest_file` task is already `done`, use the Marginalia reprocess path rather than repeating `/ingest --all`. The modified-file path can leave `ingested_at` set, causing the handler to skip the file. For embedded repair scripts, load `.marginalia-yusu/.env` before importing/running `TaskRunner`; otherwise the runner may mark LLM-dependent tasks dead because it cannot see the local DeepSeek LLM config.

After ingest, if the local BGE-M3 shim is running and the embedding env is configured:

```powershell
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
```

## Ubuntu/Linux Setup

After cloning this private repo with submodules:

```bash
git submodule update --init --recursive
YUSU_MARGINALIA_PYTHON=/path/to/python3.11 bash tools/setup-marginalia-yusu.sh --sync-projection
export DEEPSEEK_API_KEY="<real key>"
bash tools/configure-marginalia-deepseek.sh
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

If the historical CLI proxy LLM route is re-enabled and returns `502 unknown provider`, do not use Marginalia chat/agent as evidence. Continue with `rg`, `tools/search-kb.*`, Marginalia metadata search, and direct semantic recall until the LLM route recovers, or switch back to the DeepSeek route.

On Windows, avoid piping Chinese prompts directly into `marginalia.exe`; current PowerShell console encoding can corrupt the text into surrogate characters and cause `UnicodeEncodeError`. Use ASCII smoke prompts, a UTF-8-safe invocation, or the browser UI for Chinese questions.

An MCP wrapper is not required yet. The first stable integration point is the committed runbook plus the scripts in `tools/`. Consider MCP only after the vault is large enough that multiple AI tools need the same remote search/read API.

## Verification From Initial Windows Deployment

Verified on 2026-06-04:

- `vendor/marginalia` cloned as a submodule at `70f28bc381aafd86f047f9fe422c594c86d4330e`.
- Repo-local venv was initially created at `.tools/marginalia-venv/` using Python `3.11.15` from `F:\Project\Simple Oscilloscope\.venv\python.exe`; this was a bootstrap workaround and is now superseded.
- `pip install -e .\vendor\marginalia` succeeded inside `.tools/marginalia-venv/`.
- `marginalia --help` succeeded.
- `.marginalia-yusu/.env` was initialized with `MARGINALIA_HOME=F:/AcademicHub/0#YUSU/.marginalia-yusu/data`.
- 99 Markdown/TXT files were projected into `.marginalia-yusu/data/library/yusu-kb/`.
- `/check` started Marginalia embedded mode and detected the mirrored files as new.
- API server verified at `http://127.0.0.1:8000/health` with placeholder key and `WORKER_ENABLED=false`.
- Browser UI verified at `http://127.0.0.1:5173/`; Playwright confirmed the Chinese navigation pages: `聊天`, `资料库`, `搜索`, `设置`.
- Settings page verified server state: `MARGINALIA_HOME=F:\AcademicHub\0#YUSU\.marginalia-yusu\data`, SQLite, mirror storage, worker disabled.

Runtime rebuild on 2026-06-20:

- `C:\Users\yusu\.cache\codex-runtimes` was migrated to a junction targeting `F:\AcademicHub\.cache\codex-runtimes`.
- `.tools\marginalia-venv/` was rebuilt with Python `3.12.13` from `F:\AcademicHub\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`.
- `tools\run-yusu-personal-site.ps1` now rejects a venv whose `pyvenv.cfg` still references `Simple Oscilloscope`.

`/ingest --all` is intentionally not complete until the user configures a real LLM API key. A placeholder key is acceptable only for read-only `/check`; it must not be written to `.env`.

Verified on 2026-06-05:

- `sync-yusu-kb-to-marginalia.ps1 -Ingest` projected 99 Markdown/TXT files and applied 98 DB entries.
- Background ingest completed: 98 `ingest_file` tasks `done`; files by `ingest_status`: 98 `done`; files with summaries: 98.
- `build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume` built 98 semantic entries, `BAAI/bge-m3`, 1024 dimensions.
- Restarted API server reports `semantic_recall_enabled=true`, `semantic_recall_configured=true`, embedding base `http://127.0.0.1:8011/v1`.

Verified on 2026-06-08 after CSR lower firmware, CleanScout Vue3, HyperFrames, and Orange Pi notes were merged into the vault:

- `sync-yusu-kb-to-marginalia.ps1 -Check` reports `in_sync=146`, `new=0`, `modified=0`, `missing=0`, `moved=0`.
- Active file DB state: 146 `done`.
- Semantic index manifest: 146 entries, `BAAI/bge-m3`, 1024 dimensions.
- CSR semantic smoke query `CSR lower firmware STM32 mechanical arm OpenRF1 runbook` returns `01_Projects/cleanscout-rover-lower-firmware/02_runbook.md` as rank 1.
- API `http://127.0.0.1:8000/health` returns ok; UI `http://127.0.0.1:5173/` returns HTTP 200.

## Safety Rules

- Never commit `.tools/`, `.marginalia-yusu/`, runtime DBs, cache, history, or `.env`.
- Never write API keys, tokens, cookies, private keys, or raw private data into the vault.
- Keep Marginalia as an optional research layer. New Codex sessions should still start with `00_START_HERE_FOR_CODEX.md`, `yusu-kb`, and `rg`.
- If Marginalia is used to support a knowledge-base conclusion, cite the source Markdown files it read, not merely "Marginalia said so".
