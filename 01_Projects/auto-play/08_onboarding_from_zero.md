# 从零接手路线

## 前 15 分钟

1. 读 `F:\Project\auto play\README.md`。
2. 打开 `app.py`，确认默认启动 `autogame.macro_ui.main`。
3. 读 `autogame/macro_ui.py`，理解当前用户界面。
4. 读 `autogame/macro_engine.py`，理解录制、回放和连点器。
5. 改快捷键前先读 `autogame/win_hotkeys.py`。

## 最小可运行闭环

1. 改动时优先用 `start_debug.bat` 启动。
2. 在无风险窗口里录一个极短宏。
3. 先用标准输入回放一次。
4. 标准路径可用后，再测试游戏兼容输入。
5. 测试停止快捷键和旧进程清理。

## 防止误修的关键概念

- 鼠标回放必须在开始延迟后恢复第一个绝对坐标。
- UI 主线程不能直接跑回放/连点循环。
- 游戏输入失败经常是权限、窗口模式或输入后端问题，不一定是业务逻辑问题。
- 用户可能已经有 `profiles/macro_settings.json`，不要随手覆盖。
- 图像识别代码不是默认产品主线。

## 适合新手的第一处改动

给按键解析和连点器模式补测试。这件事风险低，而且能巩固最新功能。

## 不要一上来碰的目录

- 不要先改 `MaaNTE/`；它是第三方/研究材料。
- 除非用户明确恢复厨房图像识别自动化，不要优先改 `kitchen_ui.py`。
- 除非用户要求，不要编辑 `profiles/macros/` 下的用户宏 JSON。

## 如果重启图像识别方向

应作为独立模式建设，并提供：

- 区域/模板缩略预览；
- 每条规则实时匹配置信度；
- 明确的状态机步骤；
- 每个菜品独立备菜配置；
- 每个监视区域的调试截图按钮。

不要把这套复杂度塞进宏录制器面板。

## First 30 Minutes

1. 读 `README.md`，确认当前默认工具是宏录制器而不是图像识别。
2. 读 `app.py`，确认入口是 `autogame.macro_ui.main()`。
3. 读 `autogame/macro_ui.py`，了解 UI 队列、快捷键捕获、宏列表和连点器控件。
4. 读 `autogame/macro_engine.py`，重点看 `mouse_origin`、`MacroPlayer._play_once()` 和 `KeyClicker`。
5. 读 `autogame/win_hotkeys.py`，不要在不了解 `RegisterHotKey` 的情况下改全局快捷键。

## First Day

- 用 `start_debug.bat` 启动，确认日志路径和旧进程清理正常。
- 在无风险窗口录一个短宏，并验证标准输入回放。
- 再验证游戏兼容输入，不要直接在真实游戏里测试破坏性动作。
- 检查 `profiles/macro_settings.json` 是否已有用户快捷键设置。
- 不要修改 `profiles/macros/` 下用户宏，除非用户明确要求。

## Minimal Working Loop

1. 启动 debug 入口。
2. 录制 2-3 秒短宏。
3. 保存宏。
4. 选择宏并单次回放。
5. 开启重复或无限循环前，确认停止快捷键有效。
6. 修改连点器时，用 monkeypatch 测顺序，再做真实按键测试。

## Common Newcomer Traps

- 把 `MaaNTE/` 当成默认项目主线。
- 看到 `vision.py` 就以为当前产品目标仍是图像识别。
- 覆盖用户已有快捷键或宏文件。
- 忽略全屏/管理员权限导致的输入拦截。
- 改回放逻辑时丢掉绝对起点初始化。

## If Rebuilding From Scratch

1. 先做宏录制器，不做图像识别。
2. 从第一天就记录绝对鼠标起点。
3. 用 Windows 原生全局快捷键处理跨窗口控制。
4. 把游戏兼容输入做成可选后端。
5. 做启动器、debug 启动器、日志和旧进程清理。
6. 只有当固定宏无法覆盖决策点时，再建设带可观察 UI 的图像识别状态机。
## Validation Checklist

- 改 UI 后，至少启动一次 `MacroApp` 并立即销毁，确认控制面板不会初始化崩溃。
- 改输入后，先用 monkeypatch 捕获事件顺序，确认不会真实误敲键。
- 改启动脚本后，查看 `logs/startup.log`，确认旧进程清理和 Python 路径选择都可读。
- 改快捷键后，确认 `profiles/macro_settings.json` 中用户已有设置仍能被加载。
- 改宏存储后，先复制一个测试宏文件验证，不要直接拿用户真实宏做迁移实验。
- 改图像识别模式前，先截图确认目标区域和模板，而不是只调阈值。
## Audit Count Plain Onboarding Notes

Audit count plain line O01: A newcomer should prove the macro recorder path before touching visual automation.
Audit count plain line O02: A newcomer should use debug startup before changing the launcher path.
Audit count plain line O03: A newcomer should inspect existing settings before saving new hotkey defaults.
Audit count plain line O04: A newcomer should test playback with a harmless target before using a game window.
Audit count plain line O05: A newcomer should treat game input failure as an environment problem until proven otherwise.
Audit count plain line O06: A newcomer should preserve the first absolute mouse coordinate behavior.
Audit count plain line O07: A newcomer should keep third party research folders outside the default UI mental model.
Audit count plain line O08: A newcomer should add observability before reviving the kitchen visual state machine.