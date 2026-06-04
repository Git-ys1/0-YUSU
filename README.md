# YUSU Codex Knowledge Vault

这是 yusu 的跨项目 Codex 知识库根目录。它的目标不是替代每个项目仓库里的 `README.md` 和 `AGENTS.md`，而是把不同项目里可复用的经验、坑点、环境结论、工作流规则集中沉淀成一套 Markdown 档案。

## 核心定位

- 给 Codex 读：后续每个项目的 Codex 都可以读取这里的入库指南和历史经验。
- 给人检索：这个目录可以直接作为 Obsidian vault 打开。
- 给双系统共享：Windows 和 Ubuntu 20.04 都应通过同一份文件更新，而不是各自维护一套副本。

## 入口

- Codex 先读：[00_START_HERE_FOR_CODEX.md](00_START_HERE_FOR_CODEX.md)
- 人类总索引：[INDEX.md](INDEX.md)
- 系统级决策：[04_Runbooks/system-decisions.md](04_Runbooks/system-decisions.md)
- 检索工作流：[04_Runbooks/codex-retrieval-workflow.md](04_Runbooks/codex-retrieval-workflow.md)
- GitHub 私有仓库同步：[04_Runbooks/github-sync.md](04_Runbooks/github-sync.md)
- 入库指南：[04_Runbooks/codex-ingestion-guide.md](04_Runbooks/codex-ingestion-guide.md)
- 成熟项目入库：[04_Runbooks/mature-project-ingestion.md](04_Runbooks/mature-project-ingestion.md)
- Marginalia 深度研究层：[04_Runbooks/super-yusu-v0.3-marginalia.md](04_Runbooks/super-yusu-v0.3-marginalia.md)
- Windows/Ubuntu 共享指南：[04_Runbooks/windows-ubuntu-shared-folder.md](04_Runbooks/windows-ubuntu-shared-folder.md)
- 全局 `AGENTS.md` 接入片段：[04_Runbooks/global-agents-snippet.md](04_Runbooks/global-agents-snippet.md)

## 目录结构

```text
.
├── 00_Inbox/              # 临时收件箱：未整理的项目经验、粘贴记录、待归档片段
├── 01_Projects/           # 每个项目一套长期记忆
├── 02_GlobalMemory/       # 跨系统共享的用户/工作流记忆
├── 03_CrossProject/       # 跨项目复用的坑点、模式、工具经验
├── 04_Runbooks/           # 给 Codex 和用户执行的操作指南
├── 05_Templates/          # 新项目入库模板
├── 06_Maps/               # Obsidian MOC/索引，给大库导航
├── 99_Archive/            # 废弃、过时、保留但不再默认读取的材料
├── vendor/                 # 外部依赖子模块，例如 Marginalia
└── tools/                 # 辅助定位脚本
```

## 使用原则

1. 项目事实优先放到 `01_Projects/<project-slug>/`。
2. 跨项目稳定经验再提炼到 `03_CrossProject/` 或 `02_GlobalMemory/`。
3. 不保存 API key、密码、token、私钥、cookie、真实隐私数据。
4. 不把猜测写成事实；不确定内容必须标注来源和置信度。
5. 旧内容不要直接删除，优先移动到 `99_Archive/` 并说明原因。

## GitHub Remote

本地主库目录名是 `0#YUSU`。GitHub 创建时实际规范化为私有仓库 `Git-ys1/0-YUSU`：

- https://github.com/Git-ys1/0-YUSU
