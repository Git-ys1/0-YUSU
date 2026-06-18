# Known Issues

## 全局 Python 过旧会让启动器不可用

Evidence: 2026-06-17 当前机器 `python` 指向 `D:\Anaconda\python.exe`，版本 3.7.6，且没有 `fastapi`。原 `启动软件.bat` 直接调用全局 `python` / `pip`，导致用户无法启动。

Resolution: `启动软件.bat` 改为项目本地 `.venv` 优先；缺失时创建 venv；只在依赖导入检查失败时安装依赖。

## 前端 dist 可能陈旧并导致白屏

Evidence: `scratch/frontend_error.log` 曾记录 `Uncaught ReferenceError: duplicateWarning is not defined`，来源是旧构建 `assets/index-B-eGjsZg.js`。源码中已存在 `duplicateWarning` state，说明后端托管的是陈旧或损坏的 dist。

Resolution: 重新运行 `npm run build`；启动器比较 `frontend/src`、`frontend/public`、`frontend/package*.json`、`frontend/index.html`、`frontend/vite.config.js` 与 `frontend/dist/index.html` 的时间戳，必要时自动构建。

## config.json 不应保留旧机器桌面路径

Evidence: 2026-06-17 `config.json` 指向 `C:\Users\Administrator\Desktop\项目\archive` 和 `archive_invoices`，本机不存在。项目目录内已有 `archive` 和 `archive_invoices`。

Resolution: 配置改为 `F:\AcademicHub\发票管理归档软件\archive` 和 `F:\AcademicHub\发票管理归档软件\archive_invoices`。

## PyWebView 可能派生子 Python 进程承载窗口

Evidence: 2026-06-17 启动后 `.venv` Python 作为父进程，PyWebView 又派生 Codex bundled Python 子进程运行同一个 `run_desktop.py`，窗口标题和监听端口显示在子进程上。

Resolution: 判断是否启动成功时看 `scratch/startup.log`、窗口标题和端口 HTTP 响应，不要只按父进程 PID 查监听端口。
