# Obsidian Setup

这个目录可以直接作为 Obsidian vault 打开。

Obsidian 的定位是“人类阅读和可视化索引”，不是 Codex 的硬依赖。Codex 默认直接检索 Markdown 文件；Obsidian 只负责让用户更舒服地浏览、链接和复盘。

## Windows

1. 打开 Obsidian。
2. 选择 `Open folder as vault`。
3. 选择 `F:\AcademicHub\0#YUSU`。
4. 打开 `INDEX.md` 作为首页。

## Ubuntu

推荐先按 `windows-ubuntu-shared-folder.md` 创建 `~/YUSU-KB`。

然后在 Obsidian 中打开：

```text
~/YUSU-KB
```

## 推荐插件

先只装最少插件：

- Smart Connections：用于本地语义检索和跨笔记关联。
- Omnisearch：用于更强的全文搜索。

等知识库稳定后再考虑：

- Obsidian Copilot
- Khoj
- Basic Memory / MCP

## 大库写入规则

- 项目事实写入 `01_Projects/<project-slug>/`。
- 导航索引写入 `06_Maps/`。
- 跨项目规律写入 `03_CrossProject/`。
- 未整理材料写入 `00_Inbox/`。
- 过时但要留证据的材料写入 `99_Archive/`。

## Obsidian 适配点

- `INDEX.md` 是首页。
- `06_Maps/` 是大库导航层。
- `.obsidian/app.json` 已设置新文件默认进 `00_Inbox`。
- `.obsidian/templates.json` 指向 `05_Templates/obsidian`。
- 文件使用 Markdown 链接和 Wiki 链接，方便 Obsidian 和普通文本工具同时读取。

## 使用约定

- `INDEX.md` 是总索引。
- 每个项目目录都应有自己的 `README.md`。
- 不要让 Obsidian 自动格式化或重命名项目文件，除非确认不会破坏 Codex 引用路径。

## Sources

- Obsidian data storage: https://help.obsidian.md/data-storage
- Obsidian manage vaults: https://obsidian.md/help/Files%20and%20folders/Manage%20vaults
