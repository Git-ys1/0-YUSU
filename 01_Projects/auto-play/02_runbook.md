# 运行手册

## 安装

用户优先路径：

```powershell
.\install.bat
```

手动等价命令：

```powershell
conda create -y -n auto-play python=3.11 pip --override-channels -c conda-forge
conda run -n auto-play python -m pip install -r requirements.txt
```

这台机器上已知可用的环境路径：`D:\Anaconda\envs\auto-play\python.exe`。

## 启动

普通启动：

```powershell
.\start.bat
```

带控制台和 `logs/startup.log` 的调试启动：

```powershell
.\start_debug.bat
```

目标游戏以管理员权限运行时，用管理员启动：

```powershell
.\以管理员启动宏录制器.bat
```

不要让用户直接双击 `app.py`；Windows 文件关联可能调用旧 Python，导致静默失败。

## 清理旧进程

`start.bat` 已经调用 `stop_running_scripts.ps1` 清理旧项目 Python 进程。手动清理：

```powershell
.\关闭已运行脚本.bat
```

## 验证

开发中使用过的检查：

```powershell
D:\Anaconda\envs\auto-play\python.exe -m compileall app.py autogame
```

连点器可用 monkeypatch 替换 `KeyClicker._press_key` 和 `_release_keys`，先验证生成的按键顺序，避免真实敲键。

图像匹配旧路径可跑：

```powershell
D:\Anaconda\envs\auto-play\python.exe -m autogame.self_test
```

## 用户流程

1. 用 `start.bat` 打开宏录制器。
2. 先录一个无风险短宏。
3. 用配置的停止快捷键结束录制。
4. 选择宏，设置重复次数或无限循环；需要时开启游戏兼容输入。
5. 用 `Shift+F5` 或当前配置的停止快捷键中断。
6. 高频键盘输入时，在连点器输入框填一个或多个键，例如 `F J K`。

## 全屏 / 游戏注意事项

- 独占全屏注入失败时，优先切到无边框窗口或窗口化全屏。
- 游戏以管理员权限启动时，宏录制器也要管理员启动。
- 普通快捷键监听失效时，优先使用 Windows `RegisterHotKey`。
