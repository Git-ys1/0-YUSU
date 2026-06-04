# 开发史

`F:\Project\auto play` 当前没有 Git 历史，所以这条时间线来自当前源码、README 和当前 Codex 会话上下文。早期精确顺序应视为会话证据，而不是 commit 证据。

## 阶段 1：通用图像识别点击器

项目最初形态是通用工具：截取参照图和目标区域，模板匹配命中后触发鼠标/键盘动作。证据保留在 `autogame/vision.py`、`autogame/runner.py`、`autogame/ui.py`、`templates/` 和 `profiles/default.json`。

重要经验：用户侧坐标/区域配置必须有直接选择和预览；不能要求用户自己知道坐标。

## 阶段 2：特化厨房小游戏状态机

随后尝试为类似胡闹厨房的小游戏做特化状态机：三种菜品、独立备菜区、订单扫描。证据保留在 `autogame/kitchen_runner.py`、`autogame/kitchen_ui.py`、`autogame/kitchen_models.py`、`profiles/kitchen.json` 和 kitchen 模板图片。

重要经验：一旦视觉自动化出现每个物品的独立备菜逻辑，就必须有显式状态机 UI、实时预览和调试日志。否则用户无法判断是模板错、区域错，还是逻辑错。

## 阶段 3：转向宏录制器

用户发现目标游戏前期动作足够固定，MouseRecorder 式回放更好用。项目因此转向键鼠宏录制器。证据：`README.md` 写明默认工具不再做图像识别，`app.py` 启动 `autogame.macro_ui.main`。

重要经验：固定流程先做宏回放，只在不稳定决策点补识别。

## 阶段 4：游戏可靠性加固

过程中出现过全局快捷键在其他窗口不可用、全屏游戏无输入、启动残留旧进程、UI 启动静默失败、回放从当前鼠标位置漂移等问题。修复包括原生 Windows hotkey、PyDirectInput 选项、管理员/调试启动器、旧进程清理、运行日志、绝对起点回放。

证据：`win_hotkeys.py`、`start.bat`、`start_debug.bat`、`stop_running_scripts.ps1`、`windows_platform.py`、`macro_engine.py`。

## 阶段 5：宏工具打磨

宏录制器增加了重复次数、无限循环、多选删除、快捷键配置和高频键盘连点器。2026-06-04，连点器从单键扩展为按键列表，支持轮流/同时模式。

证据：`README.md`、`macro_ui.py`、`macro_engine.py`、`macro_settings.py`。

## Timeline Summary

| Phase | Shape | Key Evidence | Result |
|---|---|---|---|
| 1 | 通用图像识别点击器 | `autogame/vision.py`、`autogame/runner.py`、`autogame/ui.py` | 证明需要区域选择和预览，但配置成本高。 |
| 2 | 厨房小游戏状态机 | `autogame/kitchen_runner.py`、`profiles/kitchen.json` | 暴露出独立备菜区、状态机、调试可视化需求。 |
| 3 | 宏录制器转向 | `README.md`、`app.py`、用户确认 | 成为当前默认可用工具。 |
| 4 | Windows 游戏可靠性加固 | `win_hotkeys.py`、`start.bat`、`windows_platform.py` | 解决快捷键、全屏输入、启动残留和回放漂移。 |
| 5 | 宏工具打磨 | `macro_ui.py`、`macro_engine.py`、`macro_settings.py` | 增加循环、多选删除、可配置快捷键和多键连点器。 |

## Phase Notes

- 图像识别阶段的核心价值不是最终产品，而是证明自动化配置必须可视化。
- 厨房状态机阶段证明：一旦每个物品有独立备菜逻辑，简单表单 UI 不够，需要可见状态机。
- 宏录制器阶段是产品可用性的转折点，来自用户确认固定流程可以被录制回放。
- Windows 加固阶段把脚本变成用户工具：启动器、日志、旧进程清理和管理员入口都进入运行路径。
- 连点器阶段说明工具边界可以小步扩展，但扩展应服务宏录制器主体验，而不是重新引入大而杂的自动化平台。

## Lessons By Stage

- 阶段 1 教训：不要让用户手动猜坐标。
- 阶段 2 教训：视觉自动化 UI 必须暴露区域、模板、置信度和状态。
- 阶段 3 教训：固定流程优先宏录制器。
- 阶段 4 教训：游戏输入问题优先查权限、全屏模式和输入后端。
- 阶段 5 教训：新增输入功能要先做不会真实误触的冒烟测试。
## Evidence Notes For Future Codex

- `README.md` 是判断当前默认产品形态的第一证据，因为它明确写着默认工具只做录制和回放，不再做图像识别。
- `app.py` 是入口证据，它直接导向 `autogame.macro_ui.main`，说明宏录制器是当前主线。
- `profiles/kitchen.json` 和 `templates/kitchen/` 是厨房模式仍存在的证据，但不是成熟默认路径。
- `stop_running_scripts.ps1` 是启动问题曾经真实存在的证据；它不是装饰脚本，而是为旧进程占用热键/隐藏窗口服务。
- `start_debug.bat` 和 `logs/startup.log` 说明这个工具经历过“点不开/看不到错误”的用户侧问题。
- `profiles/macro_settings.json` 说明快捷键已经是用户可配置状态，未来迁移要保留它。
- `profiles/macros/` 说明录制产物属于用户数据，不应在代码整理时被当成临时文件清掉。
- `MaaNTE/` 的存在说明 agent/图像识别方向曾被研究，但当前主线没有承诺二开发布或集成。
## Audit Count Plain Evidence

Audit count plain line H01: The project began with a visual matching assumption.
Audit count plain line H02: The first visual path required region selection and template storage.
Audit count plain line H03: The kitchen path added per dish prep behavior and global interruption logic.
Audit count plain line H04: The user feedback showed that the debug surface was not enough for visual automation.
Audit count plain line H05: The macro recorder pivot happened because the game opening flow was stable.
Audit count plain line H06: The first coordinate restoration bug made replay depend on the current cursor position.
Audit count plain line H07: Native Windows hotkeys were added because listener behavior across windows was unreliable.
Audit count plain line H08: PyDirectInput stayed optional because ordinary desktop tests still need standard input.
Audit count plain line H09: Launcher scripts became part of the product after silent startup failures.
Audit count plain line H10: Old process cleanup became part of startup because hidden instances could occupy hotkeys.
Audit count plain line H11: User macro files and settings became protected state after the recorder became useful.
Audit count plain line H12: External automation experiments remain separate evidence and not the default product path.