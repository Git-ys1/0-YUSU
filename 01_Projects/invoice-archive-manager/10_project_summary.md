# Project Summary

## Key Lessons

1. 这个项目的启动入口必须控制 Python 解释器，不能依赖 Windows 全局 `python`。
2. React 前端由 FastAPI 静态托管，修前端后必须重建 `frontend/dist`，否则用户仍会加载旧 JS。
3. 桌面启动失败需要写 `scratch/startup.log`，因为双击 `.bat` 或 PyWebView 问题很容易表现为“打不开”。
4. `config.json` 是用户可见功能路径的一部分，迁移目录后必须确认它没有保留旧机器路径。

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| 本项目启动必须优先使用 `.venv`，不能依赖全局 Python 3.7 | project-only | `01_Projects/invoice-archive-manager/05_known_issues.md` | written | 2026-06-17 `python` 指向 Anaconda 3.7 且缺 `fastapi` |
| Windows GUI 工具启动器应提供本地 venv、日志和前置检查 | cross-project tooling | `03_CrossProject/tooling.md`, `06_Maps/tool-map.md` | updated | 本项目 `启动软件.bat --check` 与 `scratch/startup.log` |
| FastAPI 托管 React dist 时，源码更新后必须重建 dist | cross-project tooling | `03_CrossProject/tooling.md`, `06_Maps/tool-map.md` | updated | 旧 `frontend_error.log` 指向不存在于源码现状的旧 bundle |
| 旧机器绝对路径会让归档写到不存在目录 | project-only | `01_Projects/invoice-archive-manager/05_known_issues.md` | written | `config.json` 指向 `C:\Users\Administrator\Desktop\项目` |
