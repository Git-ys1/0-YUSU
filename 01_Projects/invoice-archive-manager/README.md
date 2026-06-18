# 发票管理归档软件

**Slug**: `invoice-archive-manager`
**项目路径**: `F:\AcademicHub\发票管理归档软件`
**系统 / 环境**: Windows，本地 `.venv` Python 3.12，FastAPI + React/Vite + PyWebView
**最近更新**: 2026-06-17
**定位**: 本地发票、合同、收发货单和回款凭证 OCR 解析、归档、台账维护桌面软件。

## 当前状态

- 用户侧启动入口是 `启动软件.bat`。
- 启动器会优先使用项目 `.venv\Scripts\python.exe`，缺失时用可用的 Python 3.10+ 创建本地 venv。
- 后端依赖已安装到项目 `.venv`。
- 前端静态包由 `frontend/dist` 托管，启动器会在源码比 dist 新时自动 `npm run build`。
- 归档目录配置为项目内 `archive` 和 `archive_invoices`。
