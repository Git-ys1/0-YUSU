# Project Memories

每个项目使用一个稳定 slug，例如：

```text
01_Projects/
├── simple-oscilloscope/
├── cleanscout-rover/
└── carbonrag/
```

## Current Project Entries

| Project | Slug | Path | Notes |
|---|---|---|---|
| YUSU Codex Knowledge Vault | `yusu-codex-knowledge-vault` | `F:\AcademicHub\0#YUSU` | This vault itself; includes GitHub sync, skill setup, mature ingestion protocol, session inventory, and retrieval decisions |
| Auto Play 宏录制器 | `auto-play` | `F:\Project\auto play` | Windows 游戏宏录制器/连点器；图像识别实验保留为次级路径 |
| Simple Oscilloscope | `simple-oscilloscope` | `F:\Project\Simple Oscilloscope` | STM32F103C8T6 Keil firmware + PySide6/PyQtGraph Windows upper-computer; V0.9.5 hand-in release |
| HyperFrames | `hyperframes` | `F:\Project\HyperFrames` | HyperFrames HTML/GSAP video production workspace; first verified 10-second 1920x1080 render |
| CarbonRAG | `carbonrag` | `F:\Project\CarbonRag` | 与“双碳智答”相关；当前只建轻量占位，完整项目史待项目工程师入库 |
| 发票管理归档软件 | `invoice-archive-manager` | `F:\AcademicHub\发票管理归档软件` | Windows 本地发票/合同归档桌面软件；FastAPI + React/Vite + PyWebView |
| CleanScout Rover 总项目 | `cleanscout-rover` | `F:\Project\CleanScout_rover` | 实验室清扫巡检车聚合条目；总项目身份、奖项证据和各工程切片导航 |
| CleanScout_rover 下位机 | `cleanscout-rover-lower-firmware` | `F:\Project\CleanScout_rover` | STM32 lower-firmware slice only: formal OpenRF1 motion controller plus frozen mechanical-arm vendor baseline |
| CleanScout Rover 前后端 | `cleanscout-rover-vue3` | `Git-ys1/CleanScout_rover/vue3`; env root `%CLEANSCOUT_VUE3_ROOT%` / `$CLEANSCOUT_VUE3_ROOT`; HDS evidence `F:\Project\CSc——uniapp\vue3` | CSR/V 线软件交互系统；uni-app frontend + Express backend + edge-relay/OpenClaw/camera workers |
| 27 考研 - 北交电气学硕 | `kaoyan-bjtu-ee` | `F:\AcademicHub\000资料相关\000考研` | Long-term exam-prep workspace for 北京交通大学 080800 电气工程学硕 |
| YUSU Personal Site | `yusu-personal-site` | `F:\AcademicHub\0#YUSU\07_PersonalSite` | 本地个人展示墙 + YUSU 知识库检索入口；V0.3 local preview |

## 新项目入库

1. 从 `05_Templates/project-memory/` 复制一套文件。
2. 用小写短横线命名项目目录，例如 `simple-oscilloscope`。
3. 在项目目录 `README.md` 写明：
   - 项目真实路径
   - 操作系统和主要环境
   - 项目一句话定位
   - 最近一次入库日期
   - 维护该条目的 Codex/用户来源
4. 把旧项目 Codex 提供的经验按文件类型归档。

## 项目目录标准文件

- `README.md`: 项目记忆入口和元信息
- `00_project_brief.md`: 项目定位、目标、阶段
- `01_architecture.md`: 架构、模块、数据流
- `02_runbook.md`: 启动、构建、测试、发布、排障命令
- `03_decisions.md`: 技术决策和原因
- `04_progress.md`: 当前进度和状态
- `05_known_issues.md`: 已知坑点和不要重复犯的错
- `06_todo_next.md`: 下一步任务
- `07_development_history.md`: 成熟项目阶段史
- `08_onboarding_from_zero.md`: 从零接手路线
- `09_session_evidence.md`: 会话、Git 和命令证据索引
- `10_project_summary.md`: 最重要结论和 Memory Routing Audit
- `session-log/`: 大任务原始记录
