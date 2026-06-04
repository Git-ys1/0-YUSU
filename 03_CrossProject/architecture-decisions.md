# Cross-Project Architecture Decisions

跨项目级技术决策放在这里。单个项目自己的 ADR 应放在 `01_Projects/<project-slug>/03_decisions.md`。

## Template

```md
## Decision: title
**Status**: proposed | accepted | superseded
**Date**: YYYY-MM-DD
**Applies To**: project-slug or cross-project

### Context

...

### Decision

...

### Consequences

...
```

## Decision: 保持自动化实验边界
**Status**: accepted
**Date**: 2026-06-04
**Applies To**: user-facing automation tools, auto-play

### Context

一个自动化工作区可能同时出现宏录制器、图像识别状态机、agent bridge、第三方项目克隆、自动弹琴工具等资产。它们都与“自动化”有关，但面向的用户任务、调试模型和风险不同。

### Decision

默认主界面只承载当前成熟主线。研究资产和实验模式保留为独立入口或明确标注的次级路径，不把所有能力揉进一个控制面板。

### Consequences

- 用户不会被不成熟实验功能干扰。
- 后续 Codex 更容易判断当前主线。
- 如果要集成实验功能，必须先写清楚触发场景、输入输出边界和调试方式。

### Evidence

- Auto Play: `app.py` 默认启动宏录制器；`MaaNTE/` 和 `NTE-Piano-Player-v1.5.2-fixed/` 保留为外部研究资产。
- Project memory: `01_Projects/auto-play/00_project_brief.md`, `01_Projects/auto-play/10_project_summary.md`.
