# Project Brief

这是一个 Windows 本地桌面归档工具：Python FastAPI 后端提供上传、OCR、归档、台账、设置等 API；React/Vite 前端构建为静态文件；`run_desktop.py` 用 PyWebView 打开本地网页壳。

## 主要目标

- 让用户能双击启动并直接使用。
- 文件归档写入本项目内的 `archive` 和 `archive_invoices`。
- 启动失败时留下可读日志，避免“一闪而过/没反应”。
