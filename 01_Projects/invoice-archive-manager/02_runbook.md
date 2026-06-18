# Runbook

## 启动

```powershell
cd /d F:\AcademicHub\发票管理归档软件
.\启动软件.bat
```

只检查启动前置条件、不打开窗口：

```powershell
cmd /c "启动软件.bat --check"
```

## 验证

```powershell
.\.venv\Scripts\python.exe -m py_compile run_desktop.py backend\main.py backend\schemas.py
cmd /c "启动软件.bat --check"
```

启动后查看日志：

```powershell
Get-Content -Raw -Encoding UTF8 .\scratch\startup.log
```

日志里应出现：

```text
FastAPI server is ready.
Starting PyWebView event loop.
```

如果需要确认接口，使用日志中的端口：

```powershell
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:<port>/api/settings
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:<port>/api/documents
```

## 依赖

- Python 3.10+；当前项目 `.venv` 由 Codex bundled Python 3.12 创建。
- Node/npm；当前机器 `npm run build` 可成功生成 `frontend/dist`。
