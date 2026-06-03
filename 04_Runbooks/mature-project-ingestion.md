# 成熟项目入库指南

本文件解决一个更难的问题：已经开发数月、经历上百次迭代、拥有大量 commit 和单个超长 Codex JSONL 会话的成熟项目，如何写成可供新开发者从零接手的知识库。

成熟项目入库不是“总结一下现在能怎么用”。它要回答：

- 这个项目为什么存在？
- 最开始什么都不知道时走过哪些弯路？
- 哪些方案被放弃，为什么？
- 哪些错误后来被修掉，但新开发者很可能再次踩？
- 当前架构为什么长成这样？
- 如果今天从零重做，应该按什么顺序走？

## 0. 适用范围

满足任一条件，就按成熟项目流程，不按轻量模板糊过去：

- 开发周期超过 1 个月。
- Git 历史超过约 50 commits，或用户明确说这是重点项目。
- 该项目工程师拥有一个承载主要开发周期的 Codex session JSONL，或聊天记录、issue、日志、文档明显很大。
- 项目已经有多轮架构转向、废弃方案、迁移、重写、发布或硬件/环境排障。
- 用户希望“从立项到结题”完整入库。

成熟项目的产出通常应有数百行 Markdown。上百行不是凑字数，而是因为完整项目周期必然包含阶段、决策、错误、证据和新手路线。

## 1. 信息源优先级

从高到低使用证据，不要只凭最近上下文：

1. 当前项目仓库：代码、README、AGENTS、配置、测试、脚本、发布文件。
2. Git 历史：`git log --reverse --date=short --stat`、tags、release notes、重大 diff。
3. 当前工程师自己的 Codex 会话 JSONL：通常是一个 `rollout-*.jsonl`，位于 `C:\Users\yusu\.codex\sessions`、Ubuntu `~/.codex/sessions`，或项目内保存的 session log。
4. 项目已有文档：`docs/`、`notes/`、`docs/ai-memory/`、旧 TODO、设计文档。
5. 命令输出和错误日志：构建、测试、烧录、部署、E2E、CI。
6. 用户明确确认：口头纠正、验收结论、产品方向。

不要把 local generated memories 当成最终事实。它们是线索，需要回到项目证据里验证。

## 2. 单工程师单 JSONL 原则

一个成熟项目可能由多个 Codex 工程师先后接力，但每个工程师入库时只复盘自己的那一个 JSONL。不要让一个工程师全量读取所有 sessions，也不要把别人的 JSONL 当成自己的经历。

优先找法：当前 Codex 环境通常会暴露 `CODEX_THREAD_ID`。这个 ID 应该等于当前 JSONL 第一行 `session_meta.payload.id`，并出现在 `rollout-*.jsonl` 文件名里。

Windows:

```powershell
$env:CODEX_THREAD_ID
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\find-own-codex-session.ps1 -ProjectPath "F:\Project\YourProject"
```

Ubuntu/Linux:

```bash
echo "$CODEX_THREAD_ID"
bash "$YUSU_KB_ROOT/tools/find-own-codex-session.sh" --project-path "$PWD"
```

如果 `CODEX_THREAD_ID` 不存在，再做元数据盘点。这个命令只读取 JSONL 第一行元数据，用来定位自己的文件：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\codex-session-inventory.ps1 -ProjectPath "F:\Project\YourProject" -Top 20
```

Ubuntu/Linux：

```bash
bash "$YUSU_KB_ROOT/tools/codex-session-inventory.sh" --project-path "$PWD" --top 20
```

如果仍有多个候选，用本轮对话里只有自己会话会出现的短句做只读正文确认。关键词要独特，不要用项目名这种泛词：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\find-own-codex-session.ps1 -ProjectPath "F:\Project\YourProject" -Keyword "成熟项目入库" -SearchContent
```

```bash
bash "$YUSU_KB_ROOT/tools/find-own-codex-session.sh" --project-path "$PWD" --keyword "成熟项目入库" --search-content
```

找到自己的 `rollout-*.jsonl` 后，把它作为本轮唯一会话证据：

```powershell
$env:YUSU_ENGINEER_SESSION = "C:\Users\yusu\.codex\sessions\...\rollout-....jsonl"
```

抽取原则：

- 先看自己 JSONL 第一条 `session_meta.payload.cwd`、时间、大小，确认它就是目标项目和本工程师会话。
- 再在这个 JSONL 内按阶段抽样：最早期、第一次跑通、最大重构、故障密集期、最近稳定期。
- 只摘录可复用结论和证据位置，不复制大段聊天原文。
- 遇到隐私、token、cookie、账号信息，跳过或脱敏。
- 不读取其他工程师的 JSONL。后续回访其他工程师时，让他们各自用自己的 JSONL 补充同一项目目录。

本机验证记录：当前知识库维护线程里，`CODEX_THREAD_ID=019e8dde-4f46-7b81-800b-99ad9b6e9392`，对应文件为 `C:\Users\yusu\.codex\sessions\2026\06\03\rollout-2026-06-03T22-23-37-019e8dde-4f46-7b81-800b-99ad9b6e9392.jsonl`。

## 3. 成熟项目入库流程

### Pass A: 当前状态盘点

目标：先知道项目现在是什么，而不是直接写历史。

必须记录：

- 项目路径、远端、主分支、当前 commit。
- 主要语言、框架、硬件、外部服务、数据库。
- 一键启动、构建、测试、发布、烧录或部署命令。
- 当前可用功能、已知不可用功能。
- AGENTS/README/package/config 里已有的约定。

输出到：

- `00_project_brief.md`
- `01_architecture.md`
- `02_runbook.md`
- `04_progress.md`

### Pass B: 时间线复原

目标：把“项目怎么走到今天”重建出来。

证据命令：

```bash
git log --reverse --date=short --pretty=format:"%ad %h %s"
git tag --sort=creatordate
git branch --all
```

要找的节点：

- 立项动机和第一版目标。
- 第一次跑通的版本。
- 第一次遇到核心技术瓶颈。
- 第一次重构或路线切换。
- 关键 bug 修复和性能/稳定性突破。
- 发布、验收、阶段完成点。
- 近期正在推进但未完成的方向。

输出到：

- `07_development_history.md`
- `04_progress.md`
- `09_session_evidence.md`

### Pass C: 失败史和坑点考古

目标：让新开发者不要重复旧项目已经付过学费的错误。

从这些地方找：

- 自己 JSONL 中的失败命令、错误输出、用户纠正。
- Git commit message 里的 `fix`、`bug`、`timeout`、`hang`、`rollback`、`revert`。
- issue/TODO/known problems。
- 当前代码里的 workaround、compat、fallback、guard。

每个坑点至少写：

- 症状
- 根因
- 错误尝试
- 已验证解决方式
- 以后 Codex 的规则
- 证据位置

输出到：

- `05_known_issues.md`
- `03_decisions.md`
- 必要时提炼到 `03_CrossProject/pitfalls.md`

### Pass D: 决策和被舍弃方案

目标：让成熟产品背后的取舍可见。

每个关键决策要写清：

- 当时上下文是什么。
- 选择了什么。
- 没选什么。
- 付出了什么代价。
- 现在是否仍然成立。
- 如果以后重开，什么信号说明要重新评估。

输出到：

- `03_decisions.md`
- `adr/YYYY-MM-DD-short-title.md`
- 必要时提炼到 `03_CrossProject/architecture-decisions.md`

### Pass E: 从零上手路线

目标：强迫成熟项目开发者换位到“什么都不知道的人”。

不能只写“直接运行 npm start”。必须回答：

- 新开发者第一天应该先读哪些文件？
- 哪些概念不懂就会误判？
- 最小可运行闭环是什么？
- 最容易失败的环境步骤是什么？
- 第一处适合改的小功能在哪里？
- 哪些目录不要先碰？
- 如果从零重做，正确顺序是什么？

输出到：

- `08_onboarding_from_zero.md`
- `02_runbook.md`
- `05_known_issues.md`

## 4. 写入文件标准

成熟项目建议至少形成这些文件：

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
├── 07_development_history.md
├── 08_onboarding_from_zero.md
├── 09_session_evidence.md
├── adr/
│   └── YYYY-MM-DD-short-title.md
└── session-log/
    └── YYYY-MM-DD.md
```

质量门槛：

- `07_development_history.md` 至少覆盖 5 个阶段，或说明为什么证据不足。
- `05_known_issues.md` 至少包含最容易复发的 5 个坑点，成熟大项目通常更多。
- `03_decisions.md` 至少写当前架构中 3 个最重要的取舍。
- `08_onboarding_from_zero.md` 必须能让新 Codex/新开发者按顺序开始工作。
- 每个重大结论都要有文件、commit、命令、session id 或用户确认作为证据。

## 5. 推荐提示词

给成熟项目 Codex 时，不要只说“总结一下”。使用这种口令：

```text
你要把当前成熟项目完整入库到 yusu 共享知识库。请先读取：
F:\AcademicHub\0#YUSU\00_START_HERE_FOR_CODEX.md
F:\AcademicHub\0#YUSU\04_Runbooks\codex-ingestion-guide.md
F:\AcademicHub\0#YUSU\04_Runbooks\mature-project-ingestion.md

这不是当前状态快照。请回到项目真实目录，读取当前代码、Git 历史、已有文档和你自己的 Codex session JSONL，重建从立项、试错、失败、转向、成熟到当前状态的完整项目史。

请至少产出：
- 07_development_history.md
- 08_onboarding_from_zero.md
- 09_session_evidence.md
- 05_known_issues.md 的高价值坑点
- 03_decisions.md / adr/ 的关键决策

不要写密钥、token、cookie、隐私数据。不要把未经核实的回忆写成事实；证据不足就标 pending。
写完更新 INDEX.md、06_Maps/，并提交推送。
```

## 6. 多轮工作节奏

成熟项目不能强求一轮完成。推荐四轮：

1. 盘点轮：只做 repo/Git/session inventory，列证据，不急着写结论。
2. 考古轮：按时间线挖失败、转向、舍弃方案和关键验收点。
3. 入库轮：写完整项目记忆和 ADR。
4. 审计轮：站在从零开发者角度检查“读完能否开工”，补缺口。

每轮都要把未完成问题写到 `06_todo_next.md`，不要让长项目记忆停在代理上下文里。

## 7. 强制质量 Gate

成熟项目入库完成前必须运行只读审计脚本。脚本只读取项目目录、Git 历史、知识库文件和你传入的单个工程师 JSONL，不会修改 session 文件，也不会扫描或读取其他工程师 JSONL。

Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\mature-project-retro-audit.ps1 -Slug "<project-slug>" -ProjectPath "F:\Project\YourProject" -SessionFile "C:\Users\yusu\.codex\sessions\...\rollout-....jsonl"
```

Ubuntu/Linux:

```bash
bash "$YUSU_KB_ROOT/tools/mature-project-retro-audit.sh" --slug "<project-slug>" --project-path "$PWD" --session-file "$HOME/.codex/sessions/.../rollout-....jsonl"
```

这个 gate 会检查：

- 成熟项目必备文件是否存在。
- `07_development_history.md`、`08_onboarding_from_zero.md`、`09_session_evidence.md` 是否有足够实质内容。
- `05_known_issues.md` 至少有 5 个真实坑点。
- `03_decisions.md` 和 `adr/` 至少有 3 个关键决策。
- `09_session_evidence.md` 必须引用当前工程师传入的 session id 或 JSONL 文件名。
- 当前工程师 JSONL 的 `cwd` 必须匹配项目路径；确有特殊原因时才使用脚本的 cwd mismatch override，并在 `09_session_evidence.md` 说明。
- Git 历史是否可读。

脚本失败时，不要绕过。按输出的缺口继续考古和补写，然后重跑。

## 8. Completion Audit

完成前逐条检查：

- 当前状态、历史阶段、失败史、决策史、从零上手、证据索引都已存在。
- 能从 `README.md` 或 `INDEX.md` 进入这些文件。
- `09_session_evidence.md` 指向了当前工程师自己的具体 JSONL、commit、日志或文档。
- 所有 secrets/隐私内容已跳过或脱敏。
- 项目特定内容没有误提炼到全局规则。
- 跨项目内容确实可复用，才进入 `03_CrossProject/`。
- `mature-project-retro-audit.*` 已通过，或未通过项已明确写入 `06_todo_next.md` 并标注为未完成。

## 9. Method References

这些不是硬依赖，而是方法来源：

- Google SRE Postmortem Culture: https://sre.google/sre-book/postmortem-culture/
- Google Cloud Architecture Decision Records: https://cloud.google.com/architecture/architecture-decision-records
- Diataxis documentation framework: https://diataxis.fr/
- arc42 documentation template: https://docs.arc42.org/
