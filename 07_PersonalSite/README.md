# YUSU Personal Site

YUSU 知识库的本地个人站与原生 Marginalia 工作台。运行时由一个 FastAPI 进程在 `127.0.0.1:8787` 同时提供个人主页、知识库 API、Marginalia `/v1` API、React UI 和本机考研数据看板入口。

## Architecture

- Personal showcase UI: zero-build HTML/CSS/JavaScript under `web/`.
- Integrated Marginalia UI source: React/Vite under `marginalia-ui/`.
- Committed runtime UI: production build under `marginalia-dist/`.
- Integrated Marginalia backend source: Python package under `marginalia-backend/marginalia/`.
- Backend host: `server.py` loads the local backend source first, then registers YUSU routes directly on Marginalia's FastAPI app.
- Kaoyan dashboard: served directly from `F:\AcademicHub\000资料相关\000考研\00_打开-北交电气考研数据看板.html` under `/kaoyan/`.
- Data/runtime: ignored `.marginalia-yusu/` SQLite, mirror library, journal and semantic index.
- Optional semantic compute: CarbonRAG BGE-M3 shim on `127.0.0.1:8011`.

There is no iframe, frontend proxy, `5173` Vite server, or separate `8000` Marginalia API in normal use. `vendor/marginalia` remains the upstream reference copy; the integrated runtime uses `07_PersonalSite/marginalia-backend` and `07_PersonalSite/marginalia-ui`.

The Kaoyan dashboard is different from Marginalia: it is a generated, self-contained HTML artifact whose source of truth remains the exam-prep workspace. The personal site mounts that artifact from its source path and does not copy its embedded score/verification data into this vault.

## First Setup

```powershell
.\tools\setup-marginalia-yusu.ps1 -SyncProjection
$env:DEEPSEEK_API_KEY = "<your key>"
.\tools\configure-marginalia-deepseek.ps1
.\tools\build-yusu-integrated-marginalia-ui.ps1
```

The API key is written only to ignored `.marginalia-yusu/.env`.

## Run

Windows:

```powershell
.\tools\run-carbonrag-bge-embedding-server.ps1  # optional semantic recall
.\tools\run-yusu-personal-site.ps1
```

Ubuntu/Linux:

```bash
bash tools/run-carbonrag-bge-embedding-server.sh  # optional semantic recall
bash tools/run-yusu-personal-site.sh
```

Open:

- Personal site: `http://127.0.0.1:8787/`
- Kaoyan dashboard: `http://127.0.0.1:8787/kaoyan/`
- Native Agent: `http://127.0.0.1:8787/marginalia/chat`
- Library: `http://127.0.0.1:8787/marginalia/library`
- Search: `http://127.0.0.1:8787/marginalia/search`
- Settings: `http://127.0.0.1:8787/marginalia/settings`
- API/health: `http://127.0.0.1:8787/v1/*`, `http://127.0.0.1:8787/health`
- Kaoyan status: `http://127.0.0.1:8787/api/kaoyan/status`

## Kaoyan Dashboard Maintenance

Default source workspace:

```text
F:\AcademicHub\000资料相关\000考研
```

Override when moving to another machine:

```powershell
$env:YUSU_KAOYAN_WORKSPACE = "D:\path\to\000考研"
.\tools\run-yusu-personal-site.ps1
```

After changing CSV, Markdown, or analysis outputs in the exam-prep workspace, regenerate the dashboard there:

```powershell
cd 'F:\AcademicHub\000资料相关\000考研'
.\.venv\Scripts\python.exe .\scripts\build_admission_dashboard.py --workspace 'F:\AcademicHub\000资料相关\000考研'
```

Then refresh `/kaoyan/`. No personal-site rebuild is required unless this repository's navigation or server routes changed.

Privacy boundary: do not copy `00_打开-北交电气考研数据看板.html`, `output/`, `capture/`, or raw student roster exports into this vault. The local route reads the current artifact from the exam project only on `127.0.0.1`.

## Rebuild The Integrated UI

Only run this after editing `marginalia-ui/`:

```powershell
.\tools\build-yusu-integrated-marginalia-ui.ps1
```

The Windows builder copies source to a temporary path without `#`, runs TypeScript and Vite with Node 22, then mirrors `dist` back into this directory. Node/Vite do not remain running.

## Upstream And License

The integrated source is derived from `vendor/marginalia` at commit `70f28bc381aafd86f047f9fe422c594c86d4330e`.

- React UI provenance and AGPL license: `marginalia-ui/UPSTREAM.md`, `marginalia-ui/UPSTREAM_LICENSE.txt`
- Backend provenance and AGPL license: `marginalia-backend/UPSTREAM.md`, `marginalia-backend/UPSTREAM_LICENSE.txt`
