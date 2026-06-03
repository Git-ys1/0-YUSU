# Codex 检索工作流

这个文件解决“新项目里的 Codex 怎么快捷调用知识库”的问题。

## 结论

Codex 不需要调用 Obsidian 才能检索。Obsidian vault 本质是 Markdown 文件夹，Codex 直接用文件系统和 `rg` 更快、更稳定。

Obsidian 的职责：

- 给人看
- 做双向链接、图谱、标签
- 以后接 Smart Connections / Copilot 这类人类侧语义检索插件

Codex 的职责：

- 通过全局 `AGENTS.md` 得知知识库存在
- 通过用户级 `yusu-kb` skill 按流程搜索
- 通过 `tools/search-kb.*` 和 `rg` 找证据
- 把新经验写回正确目录

## 快速检索

Windows:

```powershell
F:\AcademicHub\0#YUSU\tools\search-kb.ps1 -Query "Simple Oscilloscope Keil hex"
```

默认按空格切词并进行 OR 搜索；如果要完整短语匹配，加 `-Exact`。

Ubuntu/WSL:

```bash
bash "$YUSU_KB_ROOT/tools/search-kb.sh" "Simple Oscilloscope Keil hex"
```

第三个参数传 `exact` 可完整短语匹配。

直接 `rg`:

```bash
rg -n -i "project|tool|error|keyword" "$YUSU_KB_ROOT/01_Projects" "$YUSU_KB_ROOT/03_CrossProject" "$YUSU_KB_ROOT/02_GlobalMemory"
```

## Startup readiness check

Windows 侧可以用这个脚本检查“新 Codex 线程开工前是否具备被动发现本库的前提”：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\check-codex-startup-readiness.ps1
```

它检查：

- `YUSU_KB_ROOT`
- 全局 `AGENTS.md` 中的 YUSU 知识库块
- `yusu-kb` skill 的 `.agents/skills` 和 `.codex/skills` 发现路径
- `search-kb.ps1` 是否能实际命中本库

注意：如果 skill 是在当前长线程中刚创建的，这个脚本只能证明新线程的发现前提已经具备，不能证明当前长线程已经重新加载了 skill 元数据。

## 检索顺序

1. 搜项目名、仓库路径、硬件名、框架名。
2. 搜错误原文的最独特片段。
3. 搜工具名和命令，例如 `Keil`, `Milvus`, `Docker`, `PowerShell`, `ROS`。
4. 先看 `01_Projects/<project-slug>/05_known_issues.md`。
5. 再看 `03_CrossProject/pitfalls.md` 和 `03_CrossProject/tooling.md`。
6. 最后看 `session-log/` 原始记录。

## 什么时候用 skill

任意项目里，只要任务涉及：

- 总结项目经验
- 入库旧项目记忆
- 查找历史踩坑
- 更新跨项目规则
- 决定某条经验写到哪里

就显式调用：

```text
$yusu-kb
```

或者让全局 `AGENTS.md` 的规则自动触发这个流程。

## skill 安装位置

`yusu-kb` 的源文件在本 vault：

```text
.agents/skills/yusu-kb/SKILL.md
```

Windows 已创建两个发现入口：

```text
C:\Users\yusu\.agents\skills\yusu-kb
C:\Users\yusu\.codex\skills\yusu-kb
```

二者都指向同一份源文件。Ubuntu 侧按 `ubuntu-first-run.md` 创建同样的链接。

## 什么时候考虑 MCP

第一阶段不需要 MCP。原因：

- 当前主库是本地 Markdown，`rg` 足够快。
- MCP 需要维护服务、配置和权限，过早上会增加复杂度。
- OpenAI 官方把 MCP 定位为连接第三方工具和上下文；这里还没有到必须接外部数据库的阶段。

升级条件：

- Markdown 条目超过约 1000 条，关键词检索开始低效。
- 需要语义搜索而不是关键词搜索。
- 需要让多个 AI 工具共享同一个检索 API。
- 需要把 Obsidian、PDF、DOCX、网页摘录统一索引。

届时优先考虑：

1. 本地向量索引 + 简单 MCP search/read server
2. Basic Memory / Khoj 这类现成 second-brain MCP
3. Obsidian 插件只作为人类 UI，不作为 Codex 的硬依赖
