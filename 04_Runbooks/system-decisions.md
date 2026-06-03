# System Decisions

本文件回答三个核心问题：共享文件夹怎么做、Codex 怎么检索、记忆到底写在哪里。

## Decision 1: 知识主库放在这里

**Canonical memory vault**: `F:\AcademicHub\0#YUSU`

**Private GitHub remote**: `https://github.com/Git-ys1/0-YUSU`

这个目录是主库。Windows 和 Ubuntu 都应读写这一份文件，而不是复制一份再同步。

原因：

- Obsidian 官方把 vault 定义为本地文件夹里的 Markdown 纯文本文件，因此这个目录可以直接作为 Obsidian vault。
- Codex 官方说明：必须总是生效的规则应放在 `AGENTS.md` 或仓库文档；Codex Memories 只是本地召回层，不应作为唯一规则来源。
- 双系统场景下，`~/.codex/memories` 分别属于两个系统，天然隔离；它们适合当各系统的自动生成缓存，不适合做跨系统主档案。
- 当 Ubuntu 不能直接挂载 Windows 分区时，通过 GitHub 私有仓库 clone/pull/push 同步，仍保持 Windows 本地目录为主副本。

## Decision 2: Codex 的写入层级

以后按这个优先级写：

1. **项目事实** -> `01_Projects/<project-slug>/`
2. **跨项目经验** -> `03_CrossProject/`
3. **共享全局规则候选** -> `02_GlobalMemory/LEARNINGS.md`
4. **稳定高优先级规则** -> `02_GlobalMemory/ACTIVE.md`
5. **Codex 自带 Memories** -> 只允许自动生成或排障查看，不作为手工主库

如果某个项目仓库已有 `docs/ai-memory/`，它可以保留一份项目内近场记忆；但跨项目、跨系统、长期可复用的最终整理版必须进入本库。

## Decision 3: Codex 检索不依赖 Obsidian

Obsidian 是人类阅读、浏览图谱和语义插件的 UI，不是 Codex 的主检索通道。

Codex 的默认检索通道是：

1. 全局 `AGENTS.md` 强制提醒
2. 用户级 `yusu-kb` skill
3. `tools/search-kb.ps1` / `tools/search-kb.sh`
4. `rg` 直接搜索 Markdown

MCP 暂不作为第一阶段必需项。等这里积累到数百或上千条经验、关键词检索不够时，再上本地语义索引或 MCP。

## Decision 3.1: skill 源文件和发现入口

`yusu-kb` skill 的唯一源文件放在：

```text
F:\AcademicHub\0#YUSU\.agents\skills\yusu-kb
```

Windows 侧为了兼容官方路径和当前 Codex 桌面实际扫描路径，创建两个 junction：

```text
C:\Users\yusu\.agents\skills\yusu-kb -> F:\AcademicHub\0#YUSU\.agents\skills\yusu-kb
C:\Users\yusu\.codex\skills\yusu-kb  -> F:\AcademicHub\0#YUSU\.agents\skills\yusu-kb
```

Ubuntu 侧也应创建：

```bash
ln -sfn "$YUSU_KB_ROOT/.agents/skills/yusu-kb" "$HOME/.agents/skills/yusu-kb"
ln -sfn "$YUSU_KB_ROOT/.agents/skills/yusu-kb" "$HOME/.codex/skills/yusu-kb"
```

## Decision 4: 双系统共享以 NTFS 数据分区为主

当前主副本在 Windows `F:` 盘。Ubuntu 20.04 需要挂载同一个 NTFS 分区，再把 `AcademicHub/0#YUSU` 暴露成稳定路径，例如 `~/YUSU-KB`。

关键安全点：

- Windows Fast Startup/休眠会让 Ubuntu 写 NTFS 产生丢失或拒绝写入风险。
- Ubuntu 侧要用 `ntfs-3g` 或系统可用的 NTFS 驱动读写。
- 同一时间只允许一个系统的 Obsidian 或 Codex 写这个 vault。

## Sources

- OpenAI Codex AGENTS.md: https://developers.openai.com/codex/guides/agents-md
- OpenAI Codex Memories: https://developers.openai.com/codex/memories
- OpenAI Codex Skills: https://developers.openai.com/codex/skills
- OpenAI Codex MCP: https://developers.openai.com/codex/mcp
- Ubuntu Mounting Windows Partitions: https://help.ubuntu.com/community/MountingWindowsPartitions
- Ubuntu ntfs-3g manpage: https://manpages.ubuntu.com/manpages/jammy/man8/mount.ntfs.8.html
- Microsoft System Power States: https://learn.microsoft.com/en-us/windows/win32/power/system-power-states
- Obsidian data storage: https://help.obsidian.md/data-storage
