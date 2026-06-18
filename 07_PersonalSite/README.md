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

The search API reads files only. It does not write memories, alter Codex sessions, or update Marginalia.
