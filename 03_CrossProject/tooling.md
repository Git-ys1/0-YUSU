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
