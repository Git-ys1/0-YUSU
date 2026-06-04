# AGENTS

本目录是 yusu 的共享 Codex 知识库。你在这里工作时，角色是知识库管理员，不是任意项目的代码实现者。

## Long-Term Administrator Role

- 在本管理仓库工作的 Codex 默认承担长期知识库管理员职责。
- 其他项目 Codex 的职责是回到各自真实项目树，读取代码、Git 历史、自己的 JSONL 和用户确认后，把项目经验写入本 vault。
- 知识库管理员的职责是验收这些入库改动：查证据、查敏感信息、查乱码、查路由、查索引，必要时修正格式和跨项目提炼，然后在本仓库统一提交和推送。
- 管理员不替项目 Codex 编造项目事实；证据不足的内容标为 `pending`、`deferred` 或退回项目负责人补充。

## Before Starting

1. Read `C:\Users\yusu\.codex\memories\PROFILE.md` if it exists.
2. Read `C:\Users\yusu\.codex\memories\ACTIVE.md` if it exists.
3. Read `00_START_HERE_FOR_CODEX.md`.
4. Read the runbook relevant to the task under `04_Runbooks/`.

## Vault Rules

- Default to Chinese unless the user asks otherwise.
- Keep entries factual, concise, reusable, and source-aware.
- Do not invent project history. If a project Codex has not provided evidence, leave placeholders or mark content as pending.
- For mature projects, do not write a shallow snapshot. Use `04_Runbooks/mature-project-ingestion.md` and reconstruct timeline, abandoned approaches, failures, decisions, current runbook, and from-zero onboarding from evidence.
- For broad cross-document investigation or cited synthesis, use `04_Runbooks/super-yusu-v0.3-marginalia.md`; Marginalia is optional and does not replace `rg` for quick lookup.
- Do not store secrets, credentials, private tokens, cookies, SSH keys, or raw private data.
- Prefer append/update over destructive rewrites.
- Preserve user-created files and unrelated local changes.
- Other project Codex sessions may write project memory into this vault from their own project worktrees. The vault administrator may verify those changes here, fix quality/routing/format issues, then commit and push them from this repository.
- For non-trivial structural changes, update `INDEX.md` and the relevant folder `README.md`.

## Memory Routing

- Project-specific knowledge goes to `01_Projects/<project-slug>/`.
- Cross-project lessons go to `03_CrossProject/`.
- Stable shared behavior rules go to `02_GlobalMemory/ACTIVE.md`.
- Durable user preferences go to `02_GlobalMemory/PROFILE.md`.
- Tool failures and environment gotchas go to `02_GlobalMemory/ERRORS.md` or `03_CrossProject/pitfalls.md`.
- Missing recurring capabilities go to `02_GlobalMemory/FEATURE_REQUESTS.md`.

## Cross-System Rule

Future Codex sessions should locate this vault through `YUSU_KB_ROOT` when possible. If the variable is not set, use the resolver scripts:

- Windows: `tools/resolve-kb-root.ps1`
- Ubuntu/Linux: `tools/resolve-kb-root.sh`
