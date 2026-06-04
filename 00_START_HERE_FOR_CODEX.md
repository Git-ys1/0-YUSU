# Start Here For Codex

你正在读取 yusu 的共享 Codex 知识库。这里用于避免不同项目反复犯同样的错误。

## 你的角色

你是知识库管理员或项目经验入库员。除非用户明确要求，不要在这里实现某个项目的代码功能。

如果你正在 `F:\AcademicHub\0#YUSU` 这个管理仓库里工作，默认身份是长期知识库管理员。你的任务不是替各项目写代码，而是让不同项目 Codex 写来的经验可验收、可检索、可同步、可长期复用。

如果你是从某个项目过来的项目 Codex，你应该只复盘自己的项目：回到真实项目目录，读取代码、Git 历史、自己的单个 JSONL 会话和用户确认，再按本库要求写入 `01_Projects/<project-slug>/`。写完后可以让管理员 Codex 在本仓库验收、修正、提交并推送。

## 每次入库前

1. 定位知识库根目录：
   - 优先使用环境变量 `YUSU_KB_ROOT`
   - Windows 默认路径：`F:\AcademicHub\0#YUSU`
   - WSL 常见路径：`/mnt/f/AcademicHub/0#YUSU`
   - 原生 Ubuntu 双系统建议路径：`~/YUSU-KB`
2. 阅读：
   - `04_Runbooks/system-decisions.md`
   - `04_Runbooks/codex-retrieval-workflow.md`
   - `04_Runbooks/codex-ingestion-guide.md`
   - `04_Runbooks/super-yusu-v0.2-ingestion.md`
   - `04_Runbooks/super-yusu-v0.3-marginalia.md`，如果需要跨大量文档做深度调查或带引用综合报告
   - `04_Runbooks/mature-project-ingestion.md`，如果项目已经经历多轮迭代、长期开发、200+ commits、大型 JSONL 会话或用户明确要求“完整项目周期总结”
   - `04_Runbooks/windows-ubuntu-shared-folder.md`，如果涉及 Ubuntu 或共享更新
3. 搜索是否已有项目条目：
   - `rg "<project-name>|<repo-path>|<key-module>" "$YUSU_KB_ROOT"`
4. 如果没有项目条目，按 `05_Templates/project-memory/` 新建。

## 每次入库后

- 更新项目目录的 `README.md` 或 `INDEX.md` 链接。
- 更新 `06_Maps/` 里相关索引，保证知识库变大后仍能导航。
- 如果发现跨项目复用经验，提炼到 `03_CrossProject/`。
- 成熟项目必须在 `10_project_summary.md` 写出最重要 3-7 件事，并按 `super-yusuV0.2` 补齐 `Memory Routing Audit`。
- 需要深度跨文档调查时，可按 `super-yusuV0.3` 使用 Marginalia；快速检索仍优先 `rg` 和 `tools/search-kb.*`。
- 如果发现稳定的全局规则，先写到 `02_GlobalMemory/LEARNINGS.md`；只有足够稳定时再进入 `02_GlobalMemory/ACTIVE.md`。
- 保留原始证据位置，例如项目路径、命令、错误文本、日期和操作者。
- 成熟项目不能只写当前结论。必须重建从立项、试错、舍弃方案、关键转向到当前成熟形态的开发史。

## 严禁

- 写入密钥、密码、token、cookie、私钥。
- 把未经核实的猜测写成项目事实。
- 为了统一格式删除历史证据。
- 在 Windows 和 Ubuntu 同时打开并写入同一份 Obsidian vault。
