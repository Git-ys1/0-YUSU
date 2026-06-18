# Session Evidence

## 2026-06-17 启动修复

Commands and evidence:

- `python --version` returned `Python 3.7.6`; `python -c "import fastapi"` failed.
- Codex bundled Python `C:\Users\yusu\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe` returned `Python 3.12.13`.
- Created project `.venv` and installed `backend\requirements.txt` plus `pywebview`.
- `npm run build` in `frontend` succeeded with Vite and generated `frontend/dist`.
- `cmd /c "启动软件.bat --check"` returned `[CHECK] Startup prerequisites are ready.`
- HTTP smoke after launch returned:
  - `/api/settings`: 200 and project-local archive paths.
  - `/api/documents`: 200 and `[]`.
- Running desktop process had window title `智能文档管理中心 (Intelligent Document Management)`.

Changed files:

- `启动软件.bat`
- `run_desktop.py`
- `backend/schemas.py`
- `config.json`
