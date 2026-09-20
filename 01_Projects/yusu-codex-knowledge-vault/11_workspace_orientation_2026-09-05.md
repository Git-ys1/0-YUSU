# 2026-09-05 管理员接手与本机工作区快照

本轮任务是重新认识工作区、收束旧上下文。此前个人站、日历、Marginalia 的施工任务不自动续做。
以下是 Windows 本机只读检查结果；动态状态须在开工时复核，不代替各项目负责人验收。

## 知识库现状

- 主库仍是 `F:\AcademicHub\0#YUSU`，管理员负责检索、验收入库、路由与同步。
- 快速检索使用 `yusu-kb`、`tools/search-kb.*`、`rg`；Obsidian 是阅读入口，Marginalia 是可选研究层。
- 盘点前有 15 个项目目录、214 个 Markdown 文件（统计 `00_Inbox` 至 `06_Maps`），未逐篇审计全部正文。
- `main` HEAD 为 `330a80d`（2026-07-30），与本地 `origin/main` 跟踪引用无提交差异。本轮未 fetch，不代表云端实时一致。
- 盘点前 Git status 有 52 条变更记录，包含暂存、未暂存和未跟踪内容。六月个人站代码与 CSR/G474 后续入库混在同一工作树，尚未统一验收。
- 本轮仅新增本摘要及入口链接，没有修改业务代码、自动生成记忆、API、缓存设置，也没有启动服务、清理磁盘、重建索引或提交推送。

## 工作区地图

| 位置 | 角色与证据 |
|---|---|
| `F:\AcademicHub\0#YUSU` | Markdown/Obsidian 主库，另包含 `07_PersonalSite` 个人站及集成 Marginalia 源码。 |
| `F:\Project` | 主要工程区：CleanScout、CarbonRag、Simple Oscilloscope、G474、HyperFrames、微信智能体等。 |
| `F:\CodeForge` | 开发工具和其他工程并存，含 Node、VS Code、STM32CubeIDE、ESP32、PyCharm 等目录。 |
| `F:\AcademicHub\000资料相关\000考研` | 已有北交电气考研项目、处理脚本、独立 venv 和 HTML 数据看板。 |
| `F:\AcademicHub\000资料相关\考研\电路` | 电路视频、`.sz` 文件及 MP4 检查/修复脚本；与 `000考研` 同时存在，不能当作目录改名。 |
| `F:\AcademicHub\000资料相关\26-27大创\培训` | 培训 DOCX，涵盖基础通识、YOLO11、前后端、Agent、ROS Noetic。本轮仅核对文件入口，未审阅正文。 |
| `F:\AcademicHub\DeepSeek\deepseek-harness` | DeepSeek Harness 源码安装，`master` HEAD `b150a551b8`，受跟踪文件无改动，依赖及构建产物已存在。 |

## DeepSeek 接手证据

- 进程、用户和系统环境变量均未设置 `DSH_HOME`；实际发现状态目录 `C:\Users\yusu\.dsh`，不是目录跳转。
- 只读解析 `storages/workspace.json` 与 `storages/session_projcache.json` 的路径、时间等元数据，未通读会话正文或读取凭据。
- 当前索引有两个工作区、三个会话身份：大创 `培训` 两个，`考研\电路` 一个，记录时间在 2026-08-26 至 08-29。
- 这份索引没有直接指向 `0#YUSU` 的工作区。这不能证明 DeepSeek 未通过其他入口工作，也不能把既有未提交变更全部归给 DeepSeek。
- 培训和电路素材目录尚未在项目地图中单独登记，后续应由对应负责人补充成果与过程证据。

## 重点项目

以下结合项目记忆与实际 Git 元数据，不表示本轮重做了硬件验收。

| 项目 | 当前读到的状态 | 入口 |
|---|---|---|
| CSR 下位机 | 七月已有双串口合并固件；方向、负载、30 分钟并发和 ROS-ready 仍有验收缺口。 | [[../cleanscout-rover-lower-firmware/04_progress]] |
| CSR OrangePi | 七月已有固定视角标定及可达抓取 dry-run，不能视为实物抓取成功。 | [[../cleanscout-rover-orangepi-ai/04_progress]] |
| CSR Vue3 | HDS 路径、部署待核实项仍在；本机总仓库 HEAD `b7fc1c1b`（2026-08-17 合并图片聊天 PR）。 | [[../cleanscout-rover-vue3/README]] |
| 电赛 G474 | 最新 README/总结已描述 V2.8 和 V2.8.1 未发布增量；TI 仓库 HEAD `b37d124`（2026-08-01），45 个受跟踪文件有变更。 | [[../stm32g474-tjc-display/README]] |
| Simple Oscilloscope | 本机 HEAD `38dc09e`，v0.9.5，受跟踪文件无改动；Python 3.11 环境仍可运行。 | [[../simple-oscilloscope/README]] |
| CarbonRAG | 本机 HEAD `4fa1c60`，3 个受跟踪文件有变更；知识库完整入库仍待负责人补齐。 | [[../carbonrag/README]] |

G474 存在明确文档漂移：生成记忆仍指向 `v1.9.0 / projects/g474_full_integration_test`，最新项目材料已使用 `firmware/`。永久交接文件顶端仍写 V2.7，README 顶端已写 V2.8，正文又保留更早基线。后续从真实项目 README、`docs/06_handoff/`、Git 和源码核对，不照搬旧“当前基线”。本轮未代负责人修订历史。

## 本机环境

- Windows 11 家庭中文版 `10.0.22635`；i7-12650H，约 16 GB RAM，RTX 4060 Laptop GPU。
- 可用空间瞬时值：C: 11.9 GB，D: 62.2 GB，F: 620.5 GB。没有全盘统计各目录占用。
- `CODEX_HOME=F:\AcademicHub\.codex`；`C:\Users\yusu\.codex` 确认为指向它的 junction。
- `TEMP/TMP` 仍在 `C:\Users\yusu\AppData\Local\Temp`；Codex 应用二进制及本轮工具运行时在 `C:\Users\yusu\AppData\Local\OpenAI\Codex`，与迁移过的 home 是不同目录。
- `.dsh`、`.codex-backup` 也仍是 C 盘实体目录，未测量大小，不能归因为空间主因。后续构建和下载继续优先用 F 盘项目内缓存。
- Node：`F:\CodeForge\Node\node.exe`，24.11.0；Git：`D:\Git\cmd\git.exe`，2.43.0。
- PATH 默认 Python：`D:\Anaconda\python.exe`，3.7.6。项目独立环境实际版本：Simple Oscilloscope `.venv\python.exe` 和 CarbonRag `backend\.conda\python.exe` 均为 3.11.15；本库 `.tools\marginalia-venv\Scripts\python.exe` 为 3.12.14。
- Keil `D:\Work\Keil5\UV4\UV4.exe`、CubeProgrammer `F:\AcademicHub\STMicroelectronics\stm32cubeprogrammer\bin\STM32_Programmer_CLI.exe` 均存在。
- WSL 列表只显示已停止的 `docker-desktop`、WSL2。不能据此判断原生双系统 Ubuntu 是否存在或能否挂载 F 盘；跨端写回本轮未验证。

## 检索和服务

- `YUSU_KB_ROOT` 进程值、用户值正确；全局 AGENTS 的 YUSU 块存在；`.agents/skills/yusu-kb` 指向本库源文件，当前会话已发现并读取 skill。
- 只读启动发现脚本 9 项中 8 项为真，实际搜索命中；退出码 1 来自旧 `.codex/skills/yusu-kb` 兼容入口缺失，本轮未修补。
- 普通 exec 和文件补丁工具遇到 `.sandbox-bin` ACL 错误：`helper_sandbox_lock_failed / SetNamedSecurityInfoW ... 5`。审批后的沙箱外只读命令可运行，摘要通过同一 Codex 二进制的 apply_patch 入口落地；沙箱问题未修复。
- 个人站现有架构是单 FastAPI 进程，在 8787 集成主页、日历、考研看板、`/marginalia/*` 与 `/v1/*`，已不是早期 iframe 方案。
- 实时监听未见 8787、8010、8011。本轮没有启动个人站、Marginalia 或嵌入服务。
- 本地配置非敏感项为 LLM `openai-compatible / deepseek-v4-flash`、embedding `BAAI/bge-m3` / 1024 维，语义召回 true，rerank false。未测云端 API，也未据开关推断索引新鲜度。
- Ollama 在 11434 监听；只读模型列表返回 `deepseek-r1:8b`、约 4.87 GB。CarbonRAG `data/outputs/models/BAAI/bge-m3` 目录存在，二者用途不同。
- 8890 有 node 监听，但进程来源和 HTTP 根页未辨认成功，暂不标为已知项目服务。

## 接下来如何接手

1. 按归属验收既有变更，保护已暂存内容，再决定提交批次；本次环顾不等于验收入库完成。
2. 补 DeepSeek 培训、电路工作区的负责人交接，保留它们与 `000考研` 看板的边界。
3. 复核项目基线冲突及导航漏项。`video-to-codex-spec` 在两张项目表中均缺失；`wecom-deepseek-bot` 缺 project-map 行，不能把漏索引当作没入库。
4. 需要恢复服务时再测 API 和索引新鲜度；不因旧摘要中的待办自动开始长时间 ingest 或 embedding。

证据：本轮文件与目录元数据、选定环境变量、CIM 硬件信息、监听端口、Git status/log、运行时版本、WSL 列表、Ollama `/api/tags`、启动发现脚本、DSH 元数据索引及上文项目链接。

路由：`project-only` 管理员日期快照。未复制原始会话、凭据或私有资料正文，不升级机器瞬时状态为全局规则。后续施工以用户新目标为准。
