# Codex 入库指南

这是给后续各项目 Codex 必读的入库指南。目标是让每个项目的经验进入同一个知识库，避免新项目重复旧项目的错误。

## 0. 先定位知识库

优先读取环境变量：

```powershell
$env:YUSU_KB_ROOT
```

```bash
echo "$YUSU_KB_ROOT"
```

如果没有设置，尝试：

- Windows: `F:\AcademicHub\0#YUSU`
- WSL: `/mnt/f/AcademicHub/0#YUSU`
- 原生 Ubuntu 双系统: `~/YUSU-KB` 或用户手动挂载后的路径

也可以运行：

```powershell
.\tools\resolve-kb-root.ps1
```

如果需要从外部启动 Windows PowerShell 5.1，避免加载用户 profile：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\resolve-kb-root.ps1
```

```bash
bash tools/resolve-kb-root.sh
```

## 1. 入库前必须回答

1. 这是哪个项目？
2. 项目真实路径是什么？
3. 这条经验是项目专属，还是跨项目复用？
4. 有无命令、错误日志、代码路径、用户确认作为证据？
5. 是否包含密钥、隐私数据或不可公开内容？

## 2. 新项目标准流程

先判断项目类型：

- 新项目或轻量项目：按本文件建立基础项目记忆。
- 成熟项目或长期项目：先读 `04_Runbooks/mature-project-ingestion.md`，按多轮证据挖掘和完整项目周期总结执行。
- 只有当前状态快照、没有历史证据时：先写 `pending`，不要假装已经完成成熟项目入库。

如果来源是旧 Codex memory 或本机散落记忆，先区分管理员职责和项目 Codex 职责：

- 知识库管理员只导入稳定的全局偏好、跨项目工具经验、跨项目坑点和来源索引。
- 项目特定历史记忆先不要代写成项目事实；只在来源说明中登记“未导入，待对应项目 Codex 认领”。
- 对应项目的 Codex 回到真实项目目录、读取代码和当前状态后，再写入 `01_Projects/<project-slug>/`。

在知识库根目录执行概念上等价的操作：

```text
01_Projects/<project-slug>/
├── README.md
├── 00_project_brief.md
├── 01_architecture.md
├── 02_runbook.md
├── 03_decisions.md
├── 04_progress.md
├── 05_known_issues.md
├── 06_todo_next.md
└── session-log/
```

推荐从 `05_Templates/project-memory/` 复制模板，然后填事实。

成熟项目还必须补齐：

- `07_development_history.md`: 从立项到当前版本的阶段史。
- `08_onboarding_from_zero.md`: 给新开发者从零接手的路线。
- `09_session_evidence.md`: 当前工程师自己的单个 Codex JSONL、Git 历史、旧文档和命令证据索引。
- `adr/`: 关键架构和产品取舍的 ADR 条目。

成熟项目完成前必须运行只读质量 gate：

先找当前工程师自己的 JSONL：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\find-own-codex-session.ps1 -ProjectPath "<project-path>"
```

```bash
bash "$YUSU_KB_ROOT/tools/find-own-codex-session.sh" --project-path "<project-path>"
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\mature-project-retro-audit.ps1 -Slug "<project-slug>" -ProjectPath "<project-path>" -SessionFile "<own-rollout-jsonl>"
```

```bash
bash "$YUSU_KB_ROOT/tools/mature-project-retro-audit.sh" --slug "<project-slug>" --project-path "<project-path>" --session-file "<own-rollout-jsonl>"
```

## 3. 写入位置

- 项目定位、路径、阶段：`01_Projects/<project-slug>/00_project_brief.md`
- 架构、模块、数据流：`01_Projects/<project-slug>/01_architecture.md`
- 启动、构建、测试、烧录、发布命令：`01_Projects/<project-slug>/02_runbook.md`
- 为什么这么做：`01_Projects/<project-slug>/03_decisions.md`
- 当前进度：`01_Projects/<project-slug>/04_progress.md`
- 历史坑点：`01_Projects/<project-slug>/05_known_issues.md`
- 下一步：`01_Projects/<project-slug>/06_todo_next.md`
- 大任务原始记录：`01_Projects/<project-slug>/session-log/YYYY-MM-DD.md`
- 跨项目规律：`03_CrossProject/`
- 共享全局规则候选：`02_GlobalMemory/LEARNINGS.md`

## 4. 质量标准

每条重要经验尽量包含：

- 日期
- 项目路径
- 操作系统或硬件环境
- 触发场景
- 具体症状
- 已验证的解决方式
- 证据位置
- 后续 Codex 应怎么做

## 5. 禁止写入

- API key、密码、token、cookie、私钥
- 未脱敏个人隐私数据
- 未经核实的“好像是”
- 没有项目名、没有路径、没有来源的孤立结论
- 为了让条目好看而删除失败过程

## 6. 推荐条目格式

```md
## [YYYY-MM-DD] short title
**Status**: active | pending | resolved | deprecated
**Source**: user | codex-session | command-output | file-review
**Scope**: project | cross-project

### Summary

一句话说明这条经验。

### Evidence

- Project/path:
- Files:
- Commands:
- Logs:

### Codex Rule

以后遇到同类任务时应如何行动。
```

## 7. 入库完成检查

- 新项目是否已加入 `01_Projects/README.md` 或 `INDEX.md`
- 是否更新了项目目录 `README.md`
- 是否把跨项目经验提炼到了 `03_CrossProject/`
- 是否保留了证据和日期
- 是否确认没有秘密信息
