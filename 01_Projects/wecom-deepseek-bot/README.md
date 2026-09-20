# wecom-deepseek-bot

- Project path: `F:\Project\微信智能体\wecom-deepseek-bot`
- OS/environment: Windows, Node.js 24 runtime available locally, project targets Node.js >=20
- One sentence: 企业微信智能机器人长连接后端，把单聊/群聊 @机器人文本消息转给 DeepSeek，并用企业微信长连接回复。
- Last ingested: 2026-06-22
- Ingestion mode: light snapshot
- Maintainer/source: Codex project work in `F:\Project\微信智能体`

## Entry Points

- `00_project_brief.md`: 项目目标和范围
- `01_architecture.md`: 长连接、消息处理、Provider 架构
- `02_runbook.md`: 启动、测试、验收命令
- `03_decisions.md`: 关键技术决策
- `04_progress.md`: 当前完成度
- `05_known_issues.md`: 已知风险和坑点
- `06_todo_next.md`: 下一步
- `09_session_evidence.md`: 当前证据索引
- `10_project_summary.md`: 本轮结论和 Memory Routing Audit

## Secret Handling

本项目记忆不保存 Bot Secret、DeepSeek API Key、私钥或任何真实 token。真实凭据只允许放在项目本地忽略文件 `.env` 或临时进程环境变量中。
