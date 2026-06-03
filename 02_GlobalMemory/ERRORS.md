# ERRORS

本文件记录可复用的环境错误、工具异常和排障结论。

## [ERR-20260603-004] git_safe_directory_dubious_ownership
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，在 Windows 上同一路径被不同 SID/用户拥有时，Git 可能报 dubious ownership，导致 `git status`、`git diff` 等命令失败。

### Error

```text
detected dubious ownership in repository
```

### Context

- OS: Windows
- Command: `git status --short` / `git diff -- ...`
- Source: legacy Codex memory import from `C:\Users\yusu\.codex\memories\ERRORS.md`

### Suggested Fix

确认路径可信后，用 `git config --global --add safe.directory <repo-path>` 加入安全目录；不要在未确认路径来源时盲目全局放开。

## [ERR-20260603-005] py_launcher_stale_registration
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，Windows `py -3` 可能指向已不存在的 Python 安装路径，导致脚本启动失败。

### Error

```text
Requested Python version points to a missing interpreter.
```

### Context

- OS: Windows
- Command class: `py -3 -V` / launcher `.cmd` relying on `py -3`
- Source: legacy Codex memory import

### Suggested Fix

优先显式调用项目虚拟环境或已验证的 `python.exe`；交付启动脚本时不要只依赖 `py -3`。

## [ERR-20260603-006] powershell_upload_mime
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，PowerShell `Invoke-WebRequest -Form` 上传图片时可能没有按后端预期携带 `image/png` 等 MIME，导致后端拒绝。

### Error

```text
Backend rejects uploaded image MIME.
```

### Context

- OS: Windows
- Command: `Invoke-WebRequest -Method Post -Form @{ images = Get-Item '...png' }`
- Source: legacy Codex memory import

### Suggested Fix

遇到严格 MIME 校验时，改用可显式设置 multipart content type 的客户端或脚本；不要先假设上传功能本身坏了。

## [ERR-20260603-007] codex_rg_windowsapps_access_denied
**Logged**: 2026-06-03
**Priority**: low
**Status**: active

### Summary

旧记忆显示，Codex 桌面环境里的 `rg.exe` 如果来自 WindowsApps 路径，检索时可能遇到 access denied 或路径权限问题。

### Error

```text
Access denied while running rg from WindowsApps-packaged path.
```

### Context

- OS: Windows
- Tool: `rg`
- Source: legacy Codex memory import

### Suggested Fix

若 `rg` 异常，先检查 `Get-Command rg` 的真实路径；必要时安装独立 ripgrep 或改用本地工具链路径。

## [ERR-20260603-008] powershell_git_upstream_ref_quoting
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，在 PowerShell 里裸写 Git 上游引用 `@{u}` 会被解析成 PowerShell 哈希字面量。

### Error

```text
Missing '=' operator after key in hash literal.
```

### Context

- OS: Windows PowerShell
- Command: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
- Source: legacy Codex memory import

### Suggested Fix

写成带引号的形式：`git rev-parse --abbrev-ref --symbolic-full-name '@{u}'`。

## [ERR-20260603-009] sqlite_dot_read_windows_backslash
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，在 PowerShell 调 sqlite3 的 `.read C:\...\tmp.sql` 时，反斜杠会被 sqlite dot-command 当作转义处理，路径里的 `\t` 可能变成制表符导致无法打开文件。

### Error

```text
cannot open
```

### Context

- OS: Windows PowerShell
- Tool: `sqlite3`
- Source: legacy Codex memory import

### Suggested Fix

Windows 下给 sqlite3 执行临时 SQL，更稳的是通过 stdin 管道传入 SQL，而不是 `.read` 反斜杠路径。

## [ERR-20260603-010] proxy_breaks_pip_but_direct_works
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，本机开着 Clash 时，命令行系统代理 `127.0.0.1:17891` 可能让 pip 请求报 `ProxyError`；临时清空代理变量后可直连安装。

### Error

```text
ProxyError: Cannot connect to proxy
```

### Context

- OS: Windows
- Tool: pip / conda
- Source: legacy Codex memory import

### Suggested Fix

临时设置 `HTTP_PROXY=`、`HTTPS_PROXY=`、`NO_PROXY=*` 后重试；Conda 默认源不可达时可尝试 `conda-forge`。

## [ERR-20260603-011] tkinter_heavy_selection_callback_freeze
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，Tkinter `Treeview` 的 `<<TreeviewSelect>>` 回调里同步加载/解码预览图，或删除重建同一 Treeview，可能造成窗口不出现或事件重入卡死。

### Error

```text
Process exists but Tkinter window does not appear, or UI freezes after selecting a row.
```

### Context

- OS: Windows
- UI: Tkinter
- Source: legacy Codex memory import

### Suggested Fix

启动阶段只显示轻量信息；选中回调只做轻量切换；图片预览交给显式按钮/外部查看器；保存/刷新表格不要放在选中回调路径。

## [ERR-20260603-001] windows_powershell_profile_noise
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

在 Windows 上额外启动 Windows PowerShell 5.1 时，用户 profile 可能先输出解析错误或乱码，导致命令结果被噪声污染。当前 vault 验证中，`powershell -ExecutionPolicy Bypass -File ...` 曾触发 profile 报错，但脚本本身仍返回了正确路径。

### Error

```text
The string is missing the terminator: ".
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Command class: nested Windows PowerShell invocation

### Suggested Fix

优先直接在当前 PowerShell 运行脚本；如果必须启动新进程，使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...`。判断命令成败时先区分 profile 噪声和目标命令输出。

## [ERR-20260603-002] windows_timestamp_colon_ads
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

Windows/NTFS 文件名中不能随意使用冒号。PowerShell 时间戳格式如果包含时区 `+08:00`，用于文件名时可能被 NTFS 解释成 alternate data stream，导致验证文件名异常或不可见。

### Error

```text
Timestamp contained +08:00 in a generated filename.
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Script: `tools/check-shared-access.ps1`

### Suggested Fix

生成跨系统日志或验证文件名时，将 `:` 替换成 `-`，例如 PowerShell 使用 `(Get-Date -Format "yyyy-MM-ddTHH-mm-ssK").Replace(":", "-")`。

## [ERR-20260603-003] skill_frontmatter_yaml_colon
**Logged**: 2026-06-03
**Priority**: high
**Status**: active

### Summary

Codex skill 的 `SKILL.md` frontmatter 中，如果 `description` 包含冒号但没有加引号，YAML 会解析失败，导致 skill 校验失败甚至可能无法被发现。

### Error

```text
Invalid YAML in frontmatter: mapping values are not allowed here
```

### Context

- Project/path: `F:\AcademicHub\0#YUSU`
- Skill: `yusu-kb`
- Validator: `skill-creator/scripts/quick_validate.py`

### Suggested Fix

frontmatter 只保留 `name` 和 `description`，且当 `description` 含冒号、引号、路径或复杂标点时用双引号包裹。修改后必须运行 `quick_validate.py <skill-folder>`。

## Entry Template

```md
## [ERR-YYYYMMDD-001] command_or_tool
**Logged**: YYYY-MM-DD HH:mm
**Priority**: low | medium | high | critical
**Status**: pending | resolved | promoted | wont_fix

### Summary

...

### Error

```text
...
```

### Context

- OS:
- Project/path:
- Command:

### Suggested Fix

...
```
