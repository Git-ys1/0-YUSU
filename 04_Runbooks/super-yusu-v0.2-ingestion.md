# Super YUSU V0.2 Ingestion Protocol

**Version**: super-yusuV0.2
**Status**: active
**Date**: 2026-06-04

本协议补强成熟项目入库的最后一步：复盘完成后，必须把整个项目经历压缩成少数关键结论，并逐条判断这些结论应该留在项目目录、提炼到跨项目经验、还是升级为全局记忆候选。

## Why V0.2 Exists

V0.1 已经要求成熟项目写 `10_project_summary.md`，列出最重要 3-7 件事。但实际执行时，项目 Codex 仍可能只写项目文件，或者只零散更新 `03_CrossProject/`，没有说明“哪些总结已入库、哪些只适合项目内保留、哪些暂缓”。

V0.2 的核心改动是强制增加 **Memory Routing Audit**。

## Mandatory Two-Pass Ending

成熟项目入库最后必须执行两轮收束。

### Pass 1: Project Summary

在 `01_Projects/<project-slug>/10_project_summary.md` 中总结：

- 整个项目最重要的 3-7 件事。
- 当前成熟形态背后的核心判断。
- 最昂贵的坑和它留下的规则。
- 最关键的架构、产品、工具或环境取舍。
- 未来 Codex 开工前必须先检查什么。

每条结论必须指向证据：开发史、坑点、决策、ADR、命令、commit、session id、用户确认或当前文件。

### Pass 2: Memory Routing Audit

对 Pass 1 的每条重要结论做路由判断。不能默认都留在项目目录。

| Route | Write To | Use When |
|---|---|---|
| `project-only` | `01_Projects/<project-slug>/` | 只对本项目成立，离开项目语境容易误导。 |
| `cross-project pitfall` | `03_CrossProject/pitfalls.md` + `06_Maps/pitfall-map.md` | 其他项目可能重复踩坑。 |
| `cross-project pattern` | `03_CrossProject/patterns.md` | 其他项目可复用的工程、产品或协作模式。 |
| `cross-project tooling` | `03_CrossProject/tooling.md` + `06_Maps/tool-map.md` | 工具链、环境、测试、自动化、发布或平台经验。 |
| `architecture decision` | `03_CrossProject/architecture-decisions.md` | 架构取舍本身可迁移，且有明确适用边界。 |
| `global learning` | `02_GlobalMemory/LEARNINGS.md` | 跨任务稳定但还不够进入常驻规则。 |
| `active global rule` | `02_GlobalMemory/ACTIVE.md` | 已经非常稳定、应该在多数任务中直接应用。 |
| `feature request` | `02_GlobalMemory/FEATURE_REQUESTS.md` | 用户反复需要但当前能力或工具链还缺。 |
| `map only` | `06_Maps/` | 只需要补索引，正文已经在合适位置。 |
| `deferred` | `01_Projects/<project-slug>/06_todo_next.md` | 证据不足或需要项目负责人二次确认。 |

## Required Table

`10_project_summary.md` 必须包含此表：

```md
## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| ... | project-only | 01_Projects/<project-slug>/05_known_issues.md | kept | ... |
| ... | cross-project pattern | 03_CrossProject/patterns.md | written | ... |
```

`Action` 只能使用：

- `written`: 已新增到目标文件。
- `updated`: 已补充已有目标条目。
- `kept`: 判断为项目专属，保留在项目目录。
- `pending`: 证据不足，已写入 `06_todo_next.md`。
- `rejected`: 明确不入库，并说明原因。

## Completion Rule

如果成熟项目入库后只改变了 `01_Projects/<project-slug>/`，必须在 `Memory Routing Audit` 中解释为什么所有候选结论都是 `project-only`。否则视为入库未完成。

如果修改了 `03_CrossProject/`、`02_GlobalMemory/` 或 `06_Maps/`，必须在 `10_project_summary.md` 的 `Memory Routing Audit` 中逐条对应。

## Paste Prompt For Project Codex

```text
请按 super-yusuV0.2 补做当前项目的最终总结和 Memory Routing Audit。

先读取：
F:\AcademicHub\0#YUSU\04_Runbooks\mature-project-ingestion.md
F:\AcademicHub\0#YUSU\04_Runbooks\super-yusu-v0.2-ingestion.md

不要重写已有项目记忆。先读本项目的：
- 07_development_history.md
- 08_onboarding_from_zero.md
- 09_session_evidence.md
- 10_project_summary.md
- 05_known_issues.md
- 03_decisions.md
- adr/

然后做两件事：
1. 确认 `10_project_summary.md` 已经总结整个项目最重要的 3-7 件事，每条都有证据。
2. 在 `10_project_summary.md` 增加或补齐 `Memory Routing Audit` 表格，逐条判断每个重要结论应该写到哪里。

如果某条经验可跨项目复用，请实际更新对应文件：
- `03_CrossProject/pitfalls.md`
- `03_CrossProject/patterns.md`
- `03_CrossProject/tooling.md`
- `03_CrossProject/architecture-decisions.md`
- `02_GlobalMemory/LEARNINGS.md`
- 必要时更新 `06_Maps/`

如果判断不该提升，表格里标 `project-only` 或 `rejected`，并写清原因。证据不足则标 `pending`，写入 `06_todo_next.md`。
```
