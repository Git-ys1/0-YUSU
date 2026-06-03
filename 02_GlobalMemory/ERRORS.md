# ERRORS

本文件记录可复用的环境错误、工具异常和排障结论。

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
