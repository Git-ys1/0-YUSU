# 架构

## 当前默认路径

```text
app.py
  -> autogame.windows_platform.enable_dpi_awareness()
  -> autogame.macro_ui.main()
      -> MacroApp Tk UI
          -> MacroRecorder
          -> MacroPlayer
          -> KeyClicker
          -> WindowsHotkeyListener
```

## 主要模块

- `autogame/macro_ui.py`: Tkinter 控制面板。负责宏列表、录制/回放控件、连点器控件、快捷键捕获、状态/日志队列和关闭清理。
- `autogame/macro_engine.py`: 输入引擎。包含按键序列化、`MacroRecorder`、`MacroPlayer`、`KeyClicker`。
- `autogame/win_hotkeys.py`: 基于 Windows `RegisterHotKey` 的原生全局快捷键；用于替代在游戏/全屏场景中不可靠的普通监听。
- `autogame/windows_platform.py`: DPI awareness 和绝对光标定位辅助。
- `autogame/macro_models.py`: `Macro`、`MacroEvent` 数据类。
- `autogame/macro_storage.py`: `profiles/macros/` 下的宏 JSON 持久化。
- `autogame/macro_settings.py`: `profiles/macro_settings.json` 下的快捷键设置。

## 历史 / 次级路径

- `autogame/vision.py`: OpenCV/MSS 模板匹配工具，包含兼容中文路径的图片读写。
- `autogame/runner.py` 和 `autogame/ui.py`: 早期通用图像识别规则运行器和 UI。
- `autogame/kitchen_runner.py`、`autogame/kitchen_ui.py`: 特化厨房小游戏状态机尝试，包含独立备菜区和订单扫描。
- `autogame/codex_executor.py`: 小型 CLI bridge，可做窗口激活、截图观察、鼠标/键盘/批量动作，适合未来 agent 控制实验。
- `MaaNTE/`: 用于研究的第三方自动化项目克隆，不是默认宏录制器路径。
- `NTE-Piano-Player-v1.5.2-fixed/`: 下载的自动弹琴工具，与默认宏录制器无直接关系。

## 数据流

1. 用户通过 UI 或全局快捷键开始录制。
2. `MacroRecorder` 先记录带全屏绝对坐标的 `mouse_origin`，再按时间戳记录被勾选的鼠标/键盘事件。
3. 宏 JSON 保存到 `profiles/macros/`。
4. `MacroPlayer` 读取选中宏，等待配置的开始延迟，立即移动到第一个记录的鼠标坐标，再按时间戳回放事件。
5. `KeyClicker` 独立发出高频键盘按压；现在支持 `F J K` 这类列表，并支持轮流和同时模式。

## 输入后端

- 标准输入: `pynput.keyboard.Controller` 和 `pynput.mouse.Controller`。
- 游戏兼容输入: 可用时使用 `PyDirectInput`。
- 绝对光标定位: 鼠标移动/点击前用 Windows `SetCursorPos`，避免相对起点漂移。
