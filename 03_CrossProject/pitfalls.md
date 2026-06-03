# Cross-Project Pitfalls

## Active Pitfalls

### Pitfall: PowerShell profile noise is not target command failure
**Status**: active
**Seen In**: Windows local tooling, legacy Codex memory

### Symptom

命令输出里出现 PowerShell profile 解析错误、语言模式噪声，但目标命令可能已经成功。

### Root Cause

Windows PowerShell 启动时加载用户 profile；profile 本身可能有语法或语言模式问题。

### Better Approach

优先使用 `powershell.exe -NoProfile ...`。判断结果时先看目标命令 exit code 和有效输出。

### Pitfall: Local generated memories fragment across systems
**Status**: active
**Seen In**: Windows/Ubuntu Codex memory setup

### Symptom

Windows 和 Ubuntu 各自的 `~/.codex/memories` 不同步，导致一个系统知道的经验另一个系统不知道。

### Root Cause

Codex generated memories 是本机状态，不是跨系统共享档案。

### Better Approach

手工主记忆写入本 GitHub-backed vault；各端本地 memories 只作为召回缓存和导入来源。

### Pitfall: UI automation can be over-engineered
**Status**: active
**Seen In**: legacy Codex memory

### Symptom

用户只需要固定流程回放，代理却交付复杂图像识别或状态机，增加调试成本。

### Root Cause

没有先判断流程是固定轨迹、低分支状态机，还是高分支智能体控制。

### Better Approach

先问/观察流程稳定度。固定流程优先宏录制器；高分支流程再考虑截图识别、状态机或本地 HTTP bridge。

## Template

```md
## Pitfall: title
**Status**: candidate | active | resolved
**Seen In**: project-slug

### Symptom

...

### Root Cause

...

### Better Approach

...

### Evidence

- Project/path:
- Date:
- Source:
```
