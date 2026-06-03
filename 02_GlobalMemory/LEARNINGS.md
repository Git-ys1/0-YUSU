# LEARNINGS

本文件记录尚未提升为全局规则的可复用经验。

## [LRN-20260603-001] scoped-wechat-send-preference
**Logged**: 2026-06-03
**Priority**: medium
**Status**: pending

### Summary

旧 Codex 记忆中记录：涉及微信群 `咪西咪西` 的发送请求时，用户希望不要反复追问“是否要发”；但这只代表该群的用户意图背景，不扩展到其他群聊，也不绕过实际点击发送时的工具安全确认。

### Evidence

- Project/path: `C:\Users\yusu\.codex\memories\MEMORY.md`
- Source: legacy Codex memory import

### Suggested Action

准备给 `咪西咪西` 发消息时可把它作为 standing intent context；其他群聊仍按普通确认流程判断。

## [LRN-20260603-002] tailscale-serve-http-fallback
**Logged**: 2026-06-03
**Priority**: medium
**Status**: pending

### Summary

旧记忆显示，Tailscale Serve 的 HTTPS 路径会受 `CertDomains` 等证书前置条件影响；在只需要私网手机访问时，HTTP Serve 可作为更快的可用路径，链路仍走 Tailscale 加密隧道。

### Evidence

- Project/path: `C:\Users\yusu\.codex\memories\LEARNINGS.md`
- Source: legacy Codex memory import

### Suggested Action

没有证书域名时先启用 HTTP Serve 并明确展示 `http://...ts.net/` 地址；只有证书条件满足时再切 HTTPS Serve。

## [LRN-20260603-003] codex-session-restore-and-resume
**Logged**: 2026-06-03
**Priority**: high
**Status**: pending

### Summary

旧记忆显示，Codex 会话恢复/导入不只依赖 rollout JSONL 文件，还依赖 SQLite 线程状态、rollout 路径、cwd 过滤和 session meta。导入旧会话前必须备份 JSONL 和 SQLite。

### Evidence

- Project/path: `C:\Users\yusu\.codex\memories\LEARNINGS.md`
- Source: legacy Codex memory import

### Suggested Action

修复会话可见性时同时检查 `sessions/**/rollout-*.jsonl`、`state_5.sqlite` 的 `threads.rollout_path/updated_at/agent_role/cwd`，以及 JSONL 第一条 `session_meta.payload.id` 是否与目标 thread id 对齐。

## [LRN-20260603-004] user-facing-automation-scope-control
**Logged**: 2026-06-03
**Priority**: medium
**Status**: pending

### Summary

旧记忆显示，做用户侧自动化工具时，应先判断真实需求是专用状态机、图像识别流程，还是更简单的鼠标键盘宏录制器；不要把清晰固定流程过度工程化。

### Evidence

- Project/path: `C:\Users\yusu\.codex\memories\LEARNINGS.md`
- Source: legacy Codex memory import

### Suggested Action

若流程固定且用户现成录制足够，优先交付录制、回放、重复、删除、中断热键；若流程高分支再考虑状态机、截图识别或外部 agent bridge。

## [LRN-20260603-005] bilibili-obsidian-clipping-format
**Logged**: 2026-06-03
**Priority**: low
**Status**: pending

### Summary

旧记忆显示，用户的 Bilibili Obsidian 剪藏笔记默认整理为：保留 YAML/iframe/简介，新增 `## 正文总结`，将逐秒字幕改写为无时间轴的 `## 字幕整理` 自然段。

### Evidence

- Project/path: `C:\Users\yusu\.codex\memories\LEARNINGS.md`
- Source: legacy Codex memory import

### Suggested Action

处理 `Clippings/Bilibili/` 类笔记时先查该目录是否有本地整理须知；没有更高优先级规则时按上述格式整理。

## Entry Template

```md
## [LRN-YYYYMMDD-001] title
**Logged**: YYYY-MM-DD HH:mm
**Priority**: low | medium | high | critical
**Status**: pending | resolved | promoted | wont_fix

### Summary

...

### Evidence

- Project/path:
- Command/log:
- Source:

### Suggested Action

...
```
