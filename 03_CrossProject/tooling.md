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
