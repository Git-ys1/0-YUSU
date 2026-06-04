# Templates

项目入库时复制 `project-memory/` 下的文件到：

```text
01_Projects/<project-slug>/
```

轻量项目可以只填基础文件。成熟项目必须继续补齐 `07_development_history.md`、`08_onboarding_from_zero.md`、`09_session_evidence.md`、`10_project_summary.md` 和 `adr/`，并按 `04_Runbooks/mature-project-ingestion.md` 做多轮证据挖掘，最后按 `04_Runbooks/super-yusu-v0.2-ingestion.md` 完成 `Memory Routing Audit`。

成熟项目提交前先用 `tools/find-own-codex-session.*` 找到当前工程师自己的 JSONL，再运行 `tools/mature-project-retro-audit.*`。审计脚本只读项目、Git 和当前工程师传入的单个 Codex JSONL，用失败退出码约束复盘质量。

如果要在项目仓库内也建立 `docs/ai-memory/`，同样可以复制这些模板。

`project_AGENTS.template.md` 是给项目仓库根目录使用的示例，不要原样覆盖已有项目 `AGENTS.md`，应合并到现有规则中。
