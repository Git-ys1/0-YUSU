# Tooling Notes

这里记录跨项目复用的工具和环境经验。

## Candidate Notes

- Windows 命令执行应注意 PowerShell profile 噪声；能用 `-NoProfile` 时优先使用。
- 搜索文件和文本时优先用 `rg` 和 `rg --files`。

## Active Notes

### Windows PowerShell profile noise

在 Windows 上如果需要启动额外的 Windows PowerShell 5.1 进程，优先使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\path\to\script.ps1
```

不要把 profile 解析错误直接当成目标脚本失败；先看目标命令是否仍产生了有效输出。

### Windows-safe timestamps

用于文件名的时间戳不要包含冒号。尤其是 PowerShell 的 `K` 时区格式会生成 `+08:00`，在 NTFS 上会触发 alternate data stream 语义。跨系统日志文件名应使用 `2026-06-03T22-48-50+08-00.md` 这类格式。

### Codex skill YAML frontmatter

`SKILL.md` frontmatter 只写 `name` 和 `description`。如果 `description` 含冒号，必须加双引号；否则 YAML 会把冒号当成映射语法，导致 skill 校验失败。创建或更新 skill 后运行：

```powershell
python C:\Users\yusu\.codex\skills\.system\skill-creator\scripts\quick_validate.py <skill-folder>
```

### Freshly installed Codex skills need a fresh discovery surface

如果某个 skill 是在当前长线程中刚创建或安装的，不要声称“当前线程已经被动触发成功”。当前线程的技能清单可能是在会话开始时加载的。可立即验证的证据是：

- `SKILL.md` frontmatter 有效
- skill 已链接到实际发现路径
- 全局 `AGENTS.md` 会提示使用它
- 搜索脚本能命中知识库

要证明被动触发，应开启新的 Codex 线程或重启后观察技能清单/行为。

### GitHub repository names may be normalized

GitHub 远端仓库名不一定保留本地目录名中的特殊字符。本次请求 `0#YUSU`，GitHub CLI 创建结果为 `Git-ys1/0-YUSU`。以后写同步指南时，要区分本地路径名和远端仓库名，不要硬假设二者完全相同。

### Dual-boot shared folder is not proven until both OSes write-read

Windows 上存在 `F:\...` 不能证明 Ubuntu 原生双系统能看见它。只有 Ubuntu 挂载/clone 后写入检查文件，并且 Windows 能读到，才算共享闭环。未验证前优先采用 GitHub private repo pull/push 作为跨端同步层。

### Tailscale Serve HTTP fallback

若 Tailscale 已运行且 MagicDNS 可用，但证书域名条件不足，HTTPS Serve 可能卡住。只用于私网手机访问时，HTTP Serve 可先落地，链路仍走 Tailscale 加密隧道；等证书条件满足再切 HTTPS。

### Codex session restore is SQLite plus JSONL

导入或修复 Codex 会话时，不能只复制 `sessions/**/rollout-*.jsonl`。还要检查 `state_5.sqlite` 中的 thread 记录、`cwd` 过滤、`rollout_path`、`updated_at`、`agent_role`，以及 JSONL 第一条 `session_meta.payload.id` 是否与目标 thread id 对齐。

### PowerShell and Git special syntax

在 PowerShell 里使用 Git 上游引用必须给 `@{u}` 加引号：

```powershell
git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
```

### SQLite temporary SQL on Windows

Windows 下避免 `sqlite3 .read C:\...\tmp.sql` 这种反斜杠路径 dot-command；路径里的 `\t` 可能被当作制表符。优先通过 stdin 管道给 sqlite3 输入 SQL。

### Playwright file upload allowed roots

Playwright 文件上传工具可能只能从声明的 allowed roots 选文件。若目标仓库文件不在允许目录，先复制临时文件到 allowed root，再测试上传，避免误判为上传功能坏了。

### Windows desktop tool launchers

交付 Windows GUI/自动化工具时，不要让用户双击 `app.py`。系统文件关联可能调用旧 Python 并一闪而过。应提供 `.bat` 启动入口，直接调用项目虚拟环境里的 `python.exe`，并提供 debug 启动脚本、日志和 `pause`。

Evidence:

- Auto Play evidence: `start.bat`, `start_debug.bat`, `stop_running_scripts.ps1`, `logs/startup.log`.

### Windows GUI automation input stack

游戏或桌面自动化在独占全屏、管理员权限游戏、DirectInput 场景下，普通 `pynput` 监听和标准输入注入可能失效。优先考虑 Windows `RegisterHotKey`、PyDirectInput、管理员启动入口，并提示用户必要时切到无边框窗口或窗口化全屏。

Evidence:

- Auto Play evidence: `autogame/win_hotkeys.py`, `autogame/macro_engine.py`, `以管理员启动宏录制器.bat`, `README.md`.
### 宏录制器冒烟测试

测试键盘连点器或宏引擎时，先避免不可控真实输入。优先 monkeypatch 底层 press/release 方法，断言生成的事件顺序；确认后再在无风险窗口里测试真实输入。Auto Play 的多键连点器轮流/同时模式就适合用这个方式验证。

Evidence:

- Auto Play evidence: multi-key clicker sequence/simultaneous smoke test monkeypatched `_press_key` and `_release_keys` before any real input test.



### Windows PyInstaller rebuilds can fail when the packaged exe is still running

When rebuilding a PyInstaller onedir app on Windows, the previous packaged exe or DLLs may be locked by a still-running process. The symptom is `Access is denied` while removing or overwriting `dist\<AppName>`.

Before retrying, inspect and stop the packaged process:

```powershell
Get-Process | Where-Object { $_.ProcessName -like '*SimpleScopePC*' }
Stop-Process -Id <pid>
```

Evidence: Simple Oscilloscope V0.9.3 failed on `dist\SimpleScopePC\SimpleScopePC.exe` until PID `22756` was stopped.

### Keil plus STM32CubeProgrammer Windows release loop

For Keil-first STM32 repositories, preserve the existing project files and use the local command-line build/flash scripts as the release path. A practical loop is:

```powershell
tools\build_keil.bat
tools\flash_stlink.bat
```

Then verify the running firmware through its normal serial protocol. This avoids confusing "hex was built" with "board was flashed."

Evidence: Simple Oscilloscope V0.9.3 generated `Objects\SimpleOscilloscope.hex`, flashed by ST-Link, and COM14 returned firmware `0.9.3`.
