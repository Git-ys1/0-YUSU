# Session Evidence

## Primary Engineer Session

The primary project session for the original 0#YUSU vault setup is:

```text
C:\Users\yusu\.codex\sessions\2026\06\03\rollout-2026-06-03T22-23-37-019e8dde-4f46-7b81-800b-99ad9b6e9392.jsonl
```

Session metadata from the local inventory:

- Session ID: `019e8dde-4f46-7b81-800b-99ad9b6e9392`
- CWD: `F:\AcademicHub\0#YUSU`
- Approximate size at inventory time: 9.33 MB
- Topic hits in inventory: `yusu=15527`, `kb_ingestion=3995`, `marginalia=12194`, `carbonrag=2758`, `cleanscout=1813`, `tooling=887`

This is the session that matches the project path and is the correct primary session for mature-project audit.

## Current Continuation Thread

The current long-running thread that resumed the strict traversal and ingestion work is:

```text
C:\Users\yusu\.codex\sessions\2026\04\27\rollout-2026-04-27T13-29-02-019dcf21-0ba7-75fb-8df3-477b17916caf.jsonl
```

Session metadata from the local inventory:

- Session ID: `019dcf21-0ba7-75fb-8df3-477b17916caf`
- CWD: `c:\Users\yusu\.codex`
- Approximate size at inventory time: 1176.5 MB
- Role in this project: continuation evidence and strict traversal instruction source, not the primary project setup JSONL.

## Session Inventory Evidence

The vault includes a privacy-preserving traversal report:

```text
01_Projects\yusu-codex-knowledge-vault\session-log\2026-06-09-session-inventory.md
```

That report records:

- Session root: `C:\Users\yusu\.codex\sessions`
- Files scanned: 38
- Total bytes: 2456112127
- Total MB: 2342.33
- Traversal method: first-line metadata for every rollout file plus `rg` topic scans.
- Privacy rule: no copied raw conversation text.

This satisfies the administrator-side requirement to inventory the available session corpus without turning private chats into vault content.

## Repository Evidence

Git history for `F:\AcademicHub\0#YUSU` provides the project timeline:

- `4f62a6e` 初始化YUSU共享知识库
- `676532d` 记录GitHub远端验证结果
- `4c08d1c` 修复Windows端Codex接入脚本
- `66b2300` 补充知识库自身项目记忆
- `4329e4d` 导入旧Codex全局记忆
- `3f5693f` 强化成熟项目入库流程
- `d44eb9b` 补充成熟项目总结层
- `50655d2` 升级入库协议到super-yusuV0.2
- `1ed349b` 接入Marginalia作为super-yusuV0.3研究层
- `7ced968` 验收auto-play与simple-oscilloscope入库
- `3acac62` 记录管理员验收入库规则
- `9c3ec90` 强化知识库管理员角色说明
- `20b3874` 补充Marginalia用户界面启动入口
- `45fe0b3` 接入Marginalia本地LLM和Embedding适配
- `2cb4659` 修正Marginalia入库脚本并记录实测状态
- `cc6e607` Add CleanScout Rover Vue3 knowledge entry
- `5683218` 验收本地项目经验入库
- `07b9a91` 合并HDS侧CleanScout Vue3入库
- `15599cf` 记录Marginalia索引修复与管理员验收经验
- `32eb7c1` 补充SuperYUSU会话盘点工具
- `6e15e77` 完善SuperYUSU会话盘点报告
- `f097c8e` 修正会话盘点读取与报告信息

## File Evidence

Core rules:

- `00_START_HERE_FOR_CODEX.md`
- `04_Runbooks/system-decisions.md`
- `04_Runbooks/codex-ingestion-guide.md`
- `04_Runbooks/mature-project-ingestion.md`
- `04_Runbooks/super-yusu-v0.2-ingestion.md`
- `04_Runbooks/super-yusu-v0.3-marginalia.md`

Project memory:

- `01_Projects\yusu-codex-knowledge-vault\README.md`
- `01_Projects\yusu-codex-knowledge-vault\00_project_brief.md`
- `01_Projects\yusu-codex-knowledge-vault\03_decisions.md`
- `01_Projects\yusu-codex-knowledge-vault\05_known_issues.md`
- `01_Projects\yusu-codex-knowledge-vault\session-log\2026-06-09-session-inventory.md`

Cross-project routing evidence:

- `03_CrossProject\tooling.md`
- `06_Maps\tool-map.md`
- `06_Maps\project-map.md`

## Commands Used During Evidence Collection

```powershell
git log --reverse --date=short --pretty=format:'%ad %h %s' -- .
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\build-superyusu-session-inventory.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\find-own-codex-session.ps1 -ProjectPath F:\AcademicHub\0#YUSU
rg -n -i "yusu|入库|marginalia|CarbonRag|CleanScout|tooling" C:\Users\yusu\.codex\sessions
```

## Evidence Limits

- The inventory intentionally does not copy raw private session text.
- The mature-project audit should use the primary 0#YUSU session file, because its cwd matches `F:\AcademicHub\0#YUSU`.
- The current thread is valuable as continuation evidence, but its cwd is `c:\Users\yusu\.codex`; using it as the primary audit session would require a cwd mismatch waiver.
- Some old project-specific memories imported on 2026-06-03 are source material, not automatically verified facts for each project.
