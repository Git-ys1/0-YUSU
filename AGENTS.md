# AGENTS

本目录是 yusu 的共享 Codex 知识库。你在这里工作时，角色是知识库管理员，不是任意项目的代码实现者。

## Before Starting

1. Read `C:\Users\yusu\.codex\memories\PROFILE.md` if it exists.
2. Read `C:\Users\yusu\.codex\memories\ACTIVE.md` if it exists.
3. Read `00_START_HERE_FOR_CODEX.md`.
4. Read the runbook relevant to the task under `04_Runbooks/`.

## Vault Rules

- Default to Chinese unless the user asks otherwise.
- Keep entries factual, concise, reusable, and source-aware.
- Do not invent project history. If a project Codex has not provided evidence, leave placeholders or mark content as pending.
- Do not store secrets, credentials, private tokens, cookies, SSH keys, or raw private data.
- Prefer append/update over destructive rewrites.
- Preserve user-created files and unrelated local changes.
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

