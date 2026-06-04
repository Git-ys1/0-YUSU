# 项目简报

## 身份

- **名称**: Auto Play / Auto Play 宏录制器
- **路径**: `F:\Project\auto play`
- **主入口**: `app.py`
- **默认启动器**: `start.bat` / `启动宏录制器.bat`
- **主 UI**: `autogame/macro_ui.py`
- **主引擎**: `autogame/macro_engine.py`
- **2026-06-04 状态**: 可用的本地 Windows 宏录制器 + 键盘连点器；早期图像识别厨房模式仍保留在代码树里，但不是默认工具。

## 目标

给用户一个实用的小型游戏自动化工具：

1. 录制鼠标和键盘宏；
2. 按指定次数或无限循环回放；
3. 提供全局快捷键；
4. 尽量处理全屏/游戏输入常见问题；
5. 提供简单高频键盘连点器，支持多键轮流/同时触发。

## 非目标 / 当前边界

- 不把图像识别当成默认工作流假设。
- 能通过选择器/录制器捕获的位置，不要求用户手动输入屏幕坐标。
- 不把 `MaaNTE` 克隆仓库或 `NTE-Piano-Player-v1.5.2-fixed` 当成默认 Auto Play 应用的一部分。
- 不把用户宏内容写进知识库；这里只记录路径和开发经验。

## 证据

- `README.md`: 说明默认工具是宏录制器，当前不再默认做图像识别。
- `requirements.txt`: 依赖包含 OpenCV/MSS/Pillow/PyAutoGUI/pynput/PyDirectInput。
- `git status --short`: 返回 `fatal: not a git repository`，说明项目根目录当前没有 Git 历史证据。
- 当前 Codex 会话: `C:\Users\yusu\.codex\sessions\2026\05\01\rollout-2026-05-01T08-28-59-019de0f0-5390-7480-b320-ea30b41b8914.jsonl`。
