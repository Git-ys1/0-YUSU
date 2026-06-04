# 会话证据

## 当前工程师会话

- **Session id**: `019de0f0-5390-7480-b320-ea30b41b8914`
- **JSONL 路径**: `C:\Users\yusu\.codex\sessions\2026\05\01\rollout-2026-05-01T08-28-59-019de0f0-5390-7480-b320-ea30b41b8914.jsonl`
- **Session cwd**: `F:\Project\auto play`
- **定位方式**: `tools/find-own-codex-session.ps1 -ProjectPath 'F:\Project\auto play'`

## 2026-06-04 本次审阅过的命令 / 证据

- `Get-ChildItem -LiteralPath 'F:\Project\auto play'`
- `rg --files`
- `Get-Content README.md`
- `Get-Content requirements.txt`
- `git status --short` -> `fatal: not a git repository`
- `rg -n "^class |^def |DEFAULT_HOTKEYS|RegisterHotKey|PyDirectInput|set_cursor_pos|mouse_origin|KeyClicker|parse_key_labels" ...`
- `Get-Content autogame/self_test.py`
- `Get-Content autogame/vision.py`
- `Get-Content autogame/kitchen_runner.py`
- `Get-Content autogame/codex_executor.py`

## 关键源码文件

- `README.md`: 产品状态和用户运行手册。
- `app.py`: 默认入口。
- `autogame/macro_ui.py`: 当前 GUI。
- `autogame/macro_engine.py`: 录制器、回放器、连点器引擎。
- `autogame/win_hotkeys.py`: 原生全局快捷键。
- `autogame/windows_platform.py`: DPI 和光标辅助。
- `autogame/vision.py`: 历史模板匹配。
- `autogame/kitchen_runner.py`: 特化厨房状态机尝试。

## 证据限制

- 项目根目录没有 Git 历史。
- 本次入库没有复制用户宏、截图或私人游戏状态。
- 早期阶段细节来自当前会话和现有文件，不是 commit 证据。
