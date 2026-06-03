# Global AGENTS Snippet

把下面片段加入 Windows 和 Ubuntu 各自的全局 `~/.codex/AGENTS.md`，可以让未来 Codex 自动知道这份共享知识库。

不要让 Codex 自动覆盖全局 `AGENTS.md`；由用户确认后手动合并，或在明确授权时追加。

本机 Windows 的 `C:\Users\yusu\.codex\AGENTS.md` 已经在 2026-06-03 合并了共享知识库入口；Ubuntu 侧仍需按 `ubuntu-first-run.md` 接入。

本机 Windows 还已创建 skill 发现入口：

```text
C:\Users\yusu\.agents\skills\yusu-kb -> F:\AcademicHub\0#YUSU\.agents\skills\yusu-kb
C:\Users\yusu\.codex\skills\yusu-kb  -> F:\AcademicHub\0#YUSU\.agents\skills\yusu-kb
```

## Windows 推荐片段

```md
## Shared YUSU Knowledge Vault

Use the shared Codex knowledge vault at `F:\AcademicHub\0#YUSU`.

Before non-trivial project work:
1. Read `F:\AcademicHub\0#YUSU\00_START_HERE_FOR_CODEX.md`.
2. Search `F:\AcademicHub\0#YUSU\01_Projects` and `F:\AcademicHub\0#YUSU\03_CrossProject` for project names, repo paths, tools, and recurring error keywords.
3. Apply relevant project memory before editing code.

After a non-trivial task:
1. If the result is reusable, update the relevant project entry under `F:\AcademicHub\0#YUSU\01_Projects`.
2. If the lesson crosses projects, update `F:\AcademicHub\0#YUSU\03_CrossProject`.
3. Never write secrets, credentials, private tokens, cookies, or raw private data.
```

## Ubuntu 推荐片段

```md
## Shared YUSU Knowledge Vault

Use the shared Codex knowledge vault through `$YUSU_KB_ROOT` when available. If unset, try `~/YUSU-KB`, then `/mnt/f/AcademicHub/0#YUSU`.

Before non-trivial project work:
1. Read `$YUSU_KB_ROOT/00_START_HERE_FOR_CODEX.md` if available.
2. Search `$YUSU_KB_ROOT/01_Projects` and `$YUSU_KB_ROOT/03_CrossProject` for project names, repo paths, tools, and recurring error keywords.
3. Apply relevant project memory before editing code.

After a non-trivial task:
1. If the result is reusable, update the relevant project entry under `$YUSU_KB_ROOT/01_Projects`.
2. If the lesson crosses projects, update `$YUSU_KB_ROOT/03_CrossProject`.
3. Never write secrets, credentials, private tokens, cookies, or raw private data.
```

## 更稳的跨系统写法

如果两个系统都设置了 `YUSU_KB_ROOT`，全局 `AGENTS.md` 可以只写：

```md
## Shared YUSU Knowledge Vault

Use the shared Codex knowledge vault at `YUSU_KB_ROOT`.

Before non-trivial project work, resolve the vault path, read `00_START_HERE_FOR_CODEX.md`, then search `01_Projects/` and `03_CrossProject/` for relevant project memory.

After non-trivial project work, update project-specific memory and cross-project lessons when the result is reusable. Do not store secrets.
```
