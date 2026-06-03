# Start Here For Codex

你正在读取 yusu 的共享 Codex 知识库。这里用于避免不同项目反复犯同样的错误。

## 你的角色

你是知识库管理员或项目经验入库员。除非用户明确要求，不要在这里实现某个项目的代码功能。

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
   - `04_Runbooks/windows-ubuntu-shared-folder.md`，如果涉及 Ubuntu 或共享更新
3. 搜索是否已有项目条目：
   - `rg "<project-name>|<repo-path>|<key-module>" "$YUSU_KB_ROOT"`
4. 如果没有项目条目，按 `05_Templates/project-memory/` 新建。

## 每次入库后

- 更新项目目录的 `README.md` 或 `INDEX.md` 链接。
- 更新 `06_Maps/` 里相关索引，保证知识库变大后仍能导航。
- 如果发现跨项目复用经验，提炼到 `03_CrossProject/`。
- 如果发现稳定的全局规则，先写到 `02_GlobalMemory/LEARNINGS.md`；只有足够稳定时再进入 `02_GlobalMemory/ACTIVE.md`。
- 保留原始证据位置，例如项目路径、命令、错误文本、日期和操作者。

## 严禁

- 写入密钥、密码、token、cookie、私钥。
- 把未经核实的猜测写成项目事实。
- 为了统一格式删除历史证据。
- 在 Windows 和 Ubuntu 同时打开并写入同一份 Obsidian vault。
