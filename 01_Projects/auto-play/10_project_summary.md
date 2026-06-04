# 项目总结

## One-Page Summary

Auto Play 是一个 Windows 本地游戏自动化工具，当前成熟形态不是图像识别框架，而是“宏录制器 + 游戏兼容输入 + 全局快捷键 + 高频键盘连点器”。它的开发经历很有价值：需求最初被描述为“识别屏幕固定位置图像并点击”，中途做过通用图像识别、厨房小游戏状态机、MaaNTE/agent 方向调研，但真正可用的路径来自用户现场验证：目标流程足够固定，宏回放比视觉识别更简单、更稳、更好调。

当前默认入口是 `app.py -> autogame.macro_ui.main()`，主模块是 `autogame/macro_ui.py` 和 `autogame/macro_engine.py`。项目没有 Git 历史，证据来自当前源码、README、当前工程师 JSONL、用户确认和运行/测试记录；这一限制已记录在 `09_session_evidence.md`。

## Most Important Things

| # | Lesson | Evidence | Routing |
|---|---|---|---|
| 1 | 固定流程优先宏录制器，不要默认上图像识别。 | `07_development_history.md` 阶段 1-3；`03_decisions.md` 默认宏录制器决策；用户确认 MouseRecorder 路线可用。 | cross-project pattern |
| 2 | 坐标宏必须记录并恢复第一个全屏绝对起点。 | `05_known_issues.md` 回放漂移坑；`03_decisions.md` 绝对首坐标决策；`macro_engine.py` 的 `mouse_origin`。 | cross-project pitfall |
| 3 | Windows 游戏自动化需要分层输入栈。 | `05_known_issues.md` 全屏/管理员输入坑；`win_hotkeys.py`、`PyDirectInput`、管理员启动器。 | cross-project tooling |
| 4 | 可观察自动化 UI 是视觉自动化的基本能力。 | `07_development_history.md` 厨房状态机阶段；`08_onboarding_from_zero.md` 重启图像识别路线。 | cross-project pattern |
| 5 | Windows GUI 工具要交付启动器、调试启动器、日志和旧进程清理。 | `02_runbook.md` 启动/清理；`start.bat`、`start_debug.bat`、`stop_running_scripts.ps1`。 | cross-project tooling |
| 6 | 不要把无关自动化实验揉进一个主界面。 | `10_project_summary.md` 原总结；`00_project_brief.md` 非目标；`MaaNTE/` 与自动弹琴工具是外部研究资产。 | architecture decision |
| 7 | 不要覆盖用户设置和用户宏文件。 | `08_onboarding_from_zero.md` 新手陷阱；`profiles/macro_settings.json`、`profiles/macros/` 是用户状态。 | cross-project pitfall |

## Final Shape

当前最终形态是一个以宏录制器为核心的 Windows 桌面小工具：

- `app.py` 默认启动宏录制器，不默认启动图像识别 UI。
- `MacroRecorder` 负责记录鼠标、键盘、滚轮和 `mouse_origin`。
- `MacroPlayer` 支持重复次数、无限循环、速度、开始延迟和游戏兼容输入。
- `WindowsHotkeyListener` 使用 `RegisterHotKey` 提供跨窗口快捷键。
- `KeyClicker` 支持单键或多键列表，支持轮流和同时模式。
- 启动脚本负责选择 Conda Python、写日志、清理旧进程，并提供管理员启动路径。

图像识别、厨房模式、MaaNTE agent bridge、自动弹琴工具都应视为保留资产或研究材料，不是默认用户体验的一部分。

## Hard-Won Lessons

- 需求措辞里的“识别屏幕并点击”不等于必须上图像识别；先验证流程稳定度。
- 用户不会也不应该手填坐标；需要录制、选择器、预览和截图证据。
- 没有可观察性的视觉自动化 UI 会快速变成黑盒：用户无法区分模板错、区域错、状态机错，还是输入没生效。
- 游戏“完全没反应”常常是权限、全屏模式或输入后端问题，不是业务逻辑问题。
- 回放宏时不恢复绝对起点会产生非常隐蔽但致命的错位。
- Windows GUI 工具的启动体验本身就是产品：`.bat`、debug log、旧进程清理、管理员入口都不能省。
- 用户设置和用户宏属于用户状态，除非用户明确要求，Codex 只能读取和兼容，不能随手覆盖。

## Rules For Future Codex

1. 做 UI/游戏自动化前，先把任务分成固定轨迹、低分支状态机、高分支视觉 agent 三层。
2. 固定轨迹先交付宏录制器；低分支状态机必须有区域预览、置信度和状态可视化；高分支任务再考虑 agent bridge。
3. 修改宏回放逻辑时，必须保留首个全屏绝对坐标初始化。
4. 修改输入逻辑时，先用 monkeypatch 冒烟测试验证事件顺序，再做真实输入测试。
5. 遇到全屏游戏无响应，先查管理员权限、窗口模式、PyDirectInput 和 `RegisterHotKey`，再查业务逻辑。
6. 保留宏录制器主界面的边界，不把 MaaNTE、厨房识别、自动弹琴等实验功能塞进一个控制面板。
7. 任何涉及 `profiles/macro_settings.json` 或 `profiles/macros/` 的改动都要默认保护用户数据。

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| 固定流程优先宏录制器，而不是默认图像识别。 | cross-project pattern | `03_CrossProject/patterns.md` | updated | `07_development_history.md` 阶段 3；`03_decisions.md` 默认宏录制器决策。 |
| 坐标宏回放必须恢复绝对起点。 | cross-project pitfall | `03_CrossProject/pitfalls.md` + `06_Maps/pitfall-map.md` | updated | `05_known_issues.md` 回放漂移；`macro_engine.py` 的 `mouse_origin`。 |
| Windows 游戏自动化需要 RegisterHotKey、PyDirectInput、管理员/窗口化回退。 | cross-project tooling | `03_CrossProject/tooling.md` + `06_Maps/tool-map.md` | updated | `win_hotkeys.py`、`start.bat`、`以管理员启动宏录制器.bat`。 |
| 可观察自动化 UI：区域预览、置信度、状态机可见。 | cross-project pattern | `03_CrossProject/patterns.md` | written | `07_development_history.md` 阶段 2；`08_onboarding_from_zero.md` 图像识别重启路线。 |
| Windows GUI 工具要交付启动器、debug 启动器、日志和旧进程清理。 | cross-project tooling | `03_CrossProject/tooling.md` + `06_Maps/tool-map.md` | updated | `02_runbook.md`；`start.bat`、`start_debug.bat`、`stop_running_scripts.ps1`。 |
| 不要把无关自动化实验揉进一个主界面。 | architecture decision | `03_CrossProject/architecture-decisions.md` + `06_Maps/topic-map.md` | written | `00_project_brief.md` 非目标；`10_project_summary.md` Final Shape。 |
| 不要覆盖用户设置和用户宏文件。 | cross-project pitfall | `03_CrossProject/pitfalls.md` + `06_Maps/pitfall-map.md` | written | `08_onboarding_from_zero.md`；`profiles/macro_settings.json`、`profiles/macros/`。 |
| 多键连点器是 Auto Play 当前需求的具体实现。 | project-only | `01_Projects/auto-play/03_decisions.md` | kept | 只对本工具 UI/API 形态成立；跨项目已抽象为“输入行为先做冒烟测试”。 |
| Auto Play 无 Git 历史限制证据质量。 | deferred | `01_Projects/auto-play/06_todo_next.md` | pending | `09_session_evidence.md` 记录 `git status` 不是仓库；后续需用户决定是否初始化 Git。 |

## Remaining Risks

- `F:\Project\auto play` 当前不是 Git 仓库，历史复盘无法达到 commit 级证据强度。
- 厨房图像识别模式只是保留资产，不应被误认为已成熟可用。
- `MaaNTE/`、`NTE-Piano-Player-v1.5.2-fixed/` 与默认宏录制器混放在同一目录，后续新 Codex 可能误判边界。
- 用户宏和设置文件没有进入知识库，后续迁移/备份能力仍待设计。
- 全屏游戏输入永远存在平台限制；即使已有 PyDirectInput 和管理员入口，也需要用户侧窗口模式配合。