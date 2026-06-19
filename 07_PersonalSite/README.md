# YUSU Personal Site

本目录是 YUSU 知识库 V0.3 的本地个人站第一版：既展示项目和竞赛证据，也把共享知识库检索入口放进同一个前台。

## Stack

- Frontend: zero-build HTML/CSS/JavaScript under `web/`
- Backend: Python standard-library HTTP server in `server.py`
- Data: `data/showcase.json`
- Raw media: repository folder `记得整理/`

选择零构建前端是为了让 Windows、WSL、Ubuntu clone 后都能立即运行，避免 Node 依赖、Vite `dist` 陈旧和多端环境不一致。后续如果页面复杂到需要组件系统，再迁移到 React/Vite 或 Vue。

## Run

Windows:

```powershell
python .\07_PersonalSite\server.py --host 127.0.0.1 --port 8787
```

If the system Python is unsuitable, use the Codex bundled Python:

```powershell
& 'C:\Users\yusu\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' .\07_PersonalSite\server.py --host 127.0.0.1 --port 8787
```

Ubuntu/Linux:

```bash
python3 07_PersonalSite/server.py --host 127.0.0.1 --port 8787
```

Open:

```text
http://127.0.0.1:8787/
```

## What It Does

- Serves a full-bleed personal showcase wall.
- Reads structured achievements and project links from `data/showcase.json`.
- Serves raw local media from `记得整理/` through `/media/raw/<filename>`.
- Searches live Markdown under the YUSU vault through `/api/search?q=...`.
- Opens matched Markdown entries through the read-only `/api/doc?path=...` endpoint.
- Provides a full-page Marginalia-backed Agent view at `#agent` through `/api/agent/session` and `/api/agent/chat`.
- Provides a dedicated near-full-viewport Marginalia UI workspace at `#marginalia` when `http://127.0.0.1:5173/` is running.

The search and document APIs read files only. Agent chat writes only to Marginalia's local session/journal database under the ignored `.marginalia-yusu/` runtime.

## Marginalia / DeepSeek

Configure the local, ignored Marginalia `.env` with:

```powershell
$env:DEEPSEEK_API_KEY = "<your key>"
.\tools\configure-marginalia-deepseek.ps1
```

Then start the supporting services:

```powershell
.\tools\run-carbonrag-bge-embedding-server.ps1
.\tools\run-marginalia-api-yusu.ps1
.\tools\run-marginalia-ui-yusu.ps1
```

The committed scripts never contain the real API key.
