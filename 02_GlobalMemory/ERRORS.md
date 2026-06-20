# ERRORS

本文件记录可复用的环境错误、工具异常和排障结论。

## [ERR-20260603-004] git_safe_directory_dubious_ownership
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，在 Windows 上同一路径被不同 SID/用户拥有时，Git 可能报 dubious ownership，导致 `git status`、`git diff` 等命令失败。

### Error

```text
detected dubious ownership in repository
```

### Context

- OS: Windows
- Command: `git status --short` / `git diff -- ...`
- Source: legacy Codex memory import from `C:\Users\yusu\.codex\memories\ERRORS.md`

### Suggested Fix

确认路径可信后，用 `git config --global --add safe.directory <repo-path>` 加入安全目录；不要在未确认路径来源时盲目全局放开。

## [ERR-20260603-005] py_launcher_stale_registration
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，Windows `py -3` 可能指向已不存在的 Python 安装路径，导致脚本启动失败。

### Error

```text
Requested Python version points to a missing interpreter.
```

### Context

- OS: Windows
- Command class: `py -3 -V` / launcher `.cmd` relying on `py -3`
- Source: legacy Codex memory import

### Suggested Fix

优先显式调用项目虚拟环境或已验证的 `python.exe`；交付启动脚本时不要只依赖 `py -3`。

## [ERR-20260603-006] powershell_upload_mime
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，PowerShell `Invoke-WebRequest -Form` 上传图片时可能没有按后端预期携带 `image/png` 等 MIME，导致后端拒绝。

### Error

```text
Backend rejects uploaded image MIME.
```

### Context

- OS: Windows
- Command: `Invoke-WebRequest -Method Post -Form @{ images = Get-Item '...png' }`
- Source: legacy Codex memory import

### Suggested Fix

遇到严格 MIME 校验时，改用可显式设置 multipart content type 的客户端或脚本；不要先假设上传功能本身坏了。

## [ERR-20260603-007] codex_rg_windowsapps_access_denied
**Logged**: 2026-06-03
**Priority**: low
**Status**: active

### Summary

旧记忆显示，Codex 桌面环境里的 `rg.exe` 如果来自 WindowsApps 路径，检索时可能遇到 access denied 或路径权限问题。

### Error

```text
Access denied while running rg from WindowsApps-packaged path.
```

### Context

- OS: Windows
- Tool: `rg`
- Source: legacy Codex memory import

### Suggested Fix

若 `rg` 异常，先检查 `Get-Command rg` 的真实路径；必要时安装独立 ripgrep 或改用本地工具链路径。

## [ERR-20260603-008] powershell_git_upstream_ref_quoting
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，在 PowerShell 里裸写 Git 上游引用 `@{u}` 会被解析成 PowerShell 哈希字面量。

### Error

```text
Missing '=' operator after key in hash literal.
```

### Context

- OS: Windows PowerShell
- Command: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`
- Source: legacy Codex memory import

### Suggested Fix

写成带引号的形式：`git rev-parse --abbrev-ref --symbolic-full-name '@{u}'`。

## [ERR-20260603-009] sqlite_dot_read_windows_backslash
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，在 PowerShell 调 sqlite3 的 `.read C:\...\tmp.sql` 时，反斜杠会被 sqlite dot-command 当作转义处理，路径里的 `\t` 可能变成制表符导致无法打开文件。

### Error

```text
cannot open
```

### Context

- OS: Windows PowerShell
- Tool: `sqlite3`
- Source: legacy Codex memory import

### Suggested Fix

Windows 下给 sqlite3 执行临时 SQL，更稳的是通过 stdin 管道传入 SQL，而不是 `.read` 反斜杠路径。

## [ERR-20260603-010] proxy_breaks_pip_but_direct_works
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，本机开着 Clash 时，命令行系统代理 `127.0.0.1:17891` 可能让 pip 请求报 `ProxyError`；临时清空代理变量后可直连安装。

### Error

```text
ProxyError: Cannot connect to proxy
```

### Context

- OS: Windows
- Tool: pip / conda
- Source: legacy Codex memory import

### Suggested Fix

临时设置 `HTTP_PROXY=`、`HTTPS_PROXY=`、`NO_PROXY=*` 后重试；Conda 默认源不可达时可尝试 `conda-forge`。

## [ERR-20260603-011] tkinter_heavy_selection_callback_freeze
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

旧记忆显示，Tkinter `Treeview` 的 `<<TreeviewSelect>>` 回调里同步加载/解码预览图，或删除重建同一 Treeview，可能造成窗口不出现或事件重入卡死。

### Error

```text
Process exists but Tkinter window does not appear, or UI freezes after selecting a row.
```

### Context

- OS: Windows
- UI: Tkinter
- Source: legacy Codex memory import

### Suggested Fix

启动阶段只显示轻量信息；选中回调只做轻量切换；图片预览交给显式按钮/外部查看器；保存/刷新表格不要放在选中回调路径。

## [ERR-20260603-001] windows_powershell_profile_noise
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

在 Windows 上额外启动 Windows PowerShell 5.1 时，用户 profile 可能先输出解析错误或乱码，导致命令结果被噪声污染。当前 vault 验证中，`powershell -ExecutionPolicy Bypass -File ...` 曾触发 profile 报错，但脚本本身仍返回了正确路径。

### Error

```text
The string is missing the terminator: ".
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Command class: nested Windows PowerShell invocation

### Suggested Fix

优先直接在当前 PowerShell 运行脚本；如果必须启动新进程，使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...`。判断命令成败时先区分 profile 噪声和目标命令输出。

## [ERR-20260603-002] windows_timestamp_colon_ads
**Logged**: 2026-06-03
**Priority**: medium
**Status**: active

### Summary

Windows/NTFS 文件名中不能随意使用冒号。PowerShell 时间戳格式如果包含时区 `+08:00`，用于文件名时可能被 NTFS 解释成 alternate data stream，导致验证文件名异常或不可见。

### Error

```text
Timestamp contained +08:00 in a generated filename.
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Script: `tools/check-shared-access.ps1`

### Suggested Fix

生成跨系统日志或验证文件名时，将 `:` 替换成 `-`，例如 PowerShell 使用 `(Get-Date -Format "yyyy-MM-ddTHH-mm-ssK").Replace(":", "-")`。

## [ERR-20260603-003] skill_frontmatter_yaml_colon
**Logged**: 2026-06-03
**Priority**: high
**Status**: active

### Summary

Codex skill 的 `SKILL.md` frontmatter 中，如果 `description` 包含冒号但没有加引号，YAML 会解析失败，导致 skill 校验失败甚至可能无法被发现。

### Error

```text
Invalid YAML in frontmatter: mapping values are not allowed here
```

### Context

- Project/path: `F:\AcademicHub\0#YUSU`
- Skill: `yusu-kb`
- Validator: `skill-creator/scripts/quick_validate.py`

### Suggested Fix

frontmatter 只保留 `name` 和 `description`，且当 `description` 含冒号、引号、路径或复杂标点时用双引号包裹。修改后必须运行 `quick_validate.py <skill-folder>`。

## [ERR-20260604-001] missed_existing_project_python_env
**Logged**: 2026-06-04
**Priority**: high
**Status**: active

### Summary

部署 Marginalia 时，系统 PATH 只暴露 Python 3.7 且没有 `uv`，Codex 差点开始下载新的 Python/uv。用户指出 Simple Oscilloscope 项目已有 Python 3.11 venv，知识库里也已经记录了这个事实。

### Error

```text
No suitable system Python 3.11 found, but an existing project-local Python 3.11 venv was already documented.
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Existing interpreter: `F:\Project\Simple Oscilloscope\.venv\python.exe`
- Evidence: `01_Projects/simple-oscilloscope/02_runbook.md` says PC runtime uses Python 3.11 venv.

### Suggested Fix

Before installing a new runtime, search this vault for existing project-local toolchains, venvs, conda envs, and setup scripts. Prefer an already validated non-C-drive interpreter when it satisfies the version requirement.

## [ERR-20260605-001] flagembedding_optional_import
**Logged**: 2026-06-05
**Priority**: medium
**Status**: active

### Summary

CarbonRAG's Python environment has local BGE-M3 available, but direct `import FlagEmbedding` can fail because the installed package references `Optional` before importing it.

### Error

```text
NameError: name 'Optional' is not defined
```

### Context

- OS: Windows
- Project/path: `F:\Project\CarbonRag`
- Python: `F:\Project\CarbonRag\backend\.conda\python.exe`
- Command class: direct `import FlagEmbedding`

### Suggested Fix

Reuse CarbonRAG's wrapper instead of importing `FlagEmbedding` directly:

```python
from app.rag.embeddings import embed_documents
```

The wrapper injects `typing.Optional` into `builtins` before importing `BGEM3FlagModel`. Local smoke on 2026-06-05 returned one `1024`-dimension `BAAI/bge-m3` vector.

## [ERR-20260605-002] codex_proxy_nonstream_empty_or_unrouted
**Logged**: 2026-06-05
**Priority**: medium
**Status**: active

### Summary

The recommended CLI proxy for local Codex-style LLM access can behave differently by protocol and time: streaming chat returned usable text, while non-streaming `chat.completions` / `responses` returned empty content; later the same endpoint returned `502 unknown provider for model gpt-5.4`.

### Error

```text
message.content = null
output = []
502 unknown provider for model gpt-5.4
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Upstream class: OpenAI-compatible CLI proxy
- Consumer: Marginalia LLM profiles

### Suggested Fix

Use `tools/run-codex-proxy-llm-shim.ps1` to convert streaming output into non-streaming `chat.completions`, and always smoke the shim before running Marginalia ingest. If the upstream proxy itself returns `unknown provider`, pause ingest and retry later or switch provider.

## [ERR-20260605-003] marginalia_ingest_prompt_and_background_wait
**Logged**: 2026-06-05
**Priority**: high
**Status**: resolved

### Summary

Marginalia CLI `/ingest --all` is interactive. If an automation pipes `/ingest --all` without `--yes`, the confirmation prompt defaults to cancel; if it quits with `q`, background `ingest_file` tasks remain pending.

### Error

```text
apply 98 changes? [y/N] cancelled.
98 ingest task(s) queued
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Tool: Marginalia embedded CLI
- Scripts: `tools/sync-yusu-kb-to-marginalia.ps1`, `tools/sync-yusu-kb-to-marginalia.sh`

### Suggested Fix

For scripted ingest, send `/ingest --all --yes`, then `/quit`, then `w` to wait for background tasks. Verify SQLite state afterward:

```text
tasks: ingest_file done
files: ingest_status done
```

## [ERR-20260605-004] marginalia_cli_windows_piped_chinese_unicode
**Logged**: 2026-06-05
**Priority**: medium
**Status**: active

### Summary

Piping Chinese text directly from Windows PowerShell into `marginalia.exe` can corrupt UTF-8 text into surrogate characters before the API request is built.

### Error

```text
UnicodeEncodeError: surrogates not allowed
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Tool: Marginalia CLI
- Command class: piped non-ASCII chat prompt

### Suggested Fix

Use ASCII smoke prompts for CLI automation, use a UTF-8-safe invocation, or ask Chinese questions through the browser UI. Do not diagnose this as an LLM failure unless an ASCII prompt also fails.

## [ERR-20260608-001] marginalia_markdown_ingest_index_are_separate
**Logged**: 2026-06-08
**Priority**: high
**Status**: active

### Summary

Writing Markdown into the YUSU vault and committing/pushing Git does not update Marginalia's SQLite library or BGE semantic index. After CSR lower firmware and CleanScout Vue3 were merged into Markdown, Marginalia still reported the files as `new` until `sync-yusu-kb-to-marginalia.ps1 -Ingest` and `build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume` were run.

### Error

```text
Projected 147 file(s)
in_sync: 86
new: 48
modified: 12
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Tool: Marginalia mirror storage + semantic index

### Suggested Fix

Treat Marginalia as a second derived index. After knowledge-base merges, run:

```powershell
.\tools\sync-yusu-kb-to-marginalia.ps1 -Check
.\tools\sync-yusu-kb-to-marginalia.ps1 -Ingest
.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume
```

Then verify `new=0`, `modified=0`, active files are `ingest_status=done`, and the semantic index manifest entry count matches active indexed files. `Projected N` may be one higher than `in_sync` when the projection includes `.agents/...` because Marginalia skips hidden path parts during scan.

## [ERR-20260608-002] marginalia_modified_ingested_at_skip
**Logged**: 2026-06-08
**Priority**: medium
**Status**: active

### Summary

Marginalia's `/ingest --all` modified-file path can update `files.sha256` and set `ingest_status=pending` without clearing `ingested_at`. The `ingest_file` handler then sees `ingested_at` already set and skips work, leaving the file stuck at `pending` even though the task is `done`.

### Error

```text
files.ingest_status = pending
tasks.status = done
file_row.ingested_at is not null
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Observed file: `yusu-kb/06_Maps/tool-map.md`
- Upstream code path: `services.sync.apply_modified` -> `tasks.handlers.ingest_file`

### Suggested Fix

Use the official reprocess path for stuck modified files so `ingested_at` is cleared before re-queueing. If using a custom one-off script, load `.marginalia-yusu/.env` before constructing `TaskRunner`, then call `services.reprocess.reprocess_file` and wait until pending/running task counts return to zero.

## [ERR-20260608-003] marginalia_recovery_runner_must_load_env
**Logged**: 2026-06-08
**Priority**: high
**Status**: active

### Summary

Running Marginalia recovery/reprocess code from a bare Python process without loading `.marginalia-yusu/.env` makes `TaskRunner` think no LLM key is configured. It marks pending LLM-dependent tasks `dead`, even though the configured local LLM route is working.

### Error

```text
marked 6 pending LLM-dependent task(s) dead: no api_key configured
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Correct local LLM route is whatever `.marginalia-yusu/.env` resolves to; as of 2026-06-19 this is DeepSeek `https://api.deepseek.com`.

### Suggested Fix

Before any embedded Python runner or repair script imports Marginalia settings, load `.marginalia-yusu/.env`, set `MARGINALIA_HOME`, and set `WORKER_ENABLED=true` only for the short repair run. Smoke the currently configured LLM route first, for example through `http://127.0.0.1:8787/api/marginalia/status` and a short Agent call.

## [ERR-20260608-004] bge_shim_stale_process_invalid_argument
**Logged**: 2026-06-08
**Priority**: medium
**Status**: active

### Summary

The CarbonRAG BGE-M3 model and Python environment can be healthy while the long-running local embedding shim on `8011` fails model loading with `[Errno 22] Invalid argument`. Restarting the shim and smoking `/v1/embeddings` fixed the semantic-index build.

### Error

```text
local BGE-M3 embedding failed: Failed to load BGE-M3 model ... [Errno 22] Invalid argument
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- CarbonRAG path: `F:\Project\CarbonRag`
- Shim: `tools/run-carbonrag-bge-embedding-server.ps1`

### Suggested Fix

First verify CarbonRAG direct import with `embed_documents`; if direct embedding works, restart the `8011` shim and smoke:

```powershell
Invoke-RestMethod http://127.0.0.1:8011/health
```

Then POST one sample to `/v1/embeddings` and require a 1024-dimensional vector before rebuilding the semantic index.

## [ERR-20260617-001] python_py_compile_pyc_permission
**Logged**: 2026-06-17
**Priority**: low
**Status**: resolved

### Summary

On Windows, `python -m py_compile ...` can fail with `WinError 5` while replacing an existing `__pycache__/*.pyc`, even when the source syntax is valid.

### Error

```text
[WinError 5] 拒绝访问。: '...__pycache__\\file.cpython-312.pyc.<tmp>' -> '...__pycache__\\file.cpython-312.pyc'
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\000资料相关\000考研`
- Command: `.\.venv\Scripts\python.exe -m py_compile ...`

### Suggested Fix

For syntax-only checks, avoid writing pyc files and use a small `compile(Path(...).read_text(...), path, "exec")` check instead. Treat this specific `py_compile` error as a pycache/file-lock issue unless a separate syntax traceback appears.

## [ERR-20260618-001] marginalia_llm_proxy_token_expired
**Logged**: 2026-06-18
**Priority**: high
**Status**: resolved

### Summary

The local Marginalia LLM shim can start on `127.0.0.1:8010`, and the CLI proxy `/models` endpoint can return model IDs, but actual chat completions fail because the upstream proxy token is expired.

### Error

```text
Provided authentication token is expired. Please try signing in again.
```

Earlier direct `gpt-5.4` calls also returned:

```text
auth_unavailable: no auth available
```

### Context

- Local shim health: OK.
- Current proxy model list includes `gpt-5.2`, `gpt-5`, `gpt-5-codex`, and `gpt-5.1`; `gpt-5.4` is no longer in `/models`.
- CarbonRAG BGE-M3 embedding shim on `127.0.0.1:8011` still works and returns 1024-dimensional embeddings.
- `sync-yusu-kb-to-marginalia.ps1 -Check` works without LLM and showed the Markdown mirror is ahead of Marginalia DB/index.

### Suggested Fix

Refresh the upstream CLI proxy authentication token in the user-local config, then update the Marginalia local model setting to a model currently returned by `/models`. Smoke-test `http://127.0.0.1:8010/v1/chat/completions` before running `sync-yusu-kb-to-marginalia.ps1 -Ingest`.

2026-06-19 update: this is no longer the active Marginalia blocker because the vault switched to DeepSeek's official OpenAI-compatible API. Keep this entry as historical troubleshooting for the old proxy route.

## [ERR-20260619-002] deepseek_v4_pro_short_budget_empty_content
**Logged**: 2026-06-19
**Priority**: medium
**Status**: active

### Summary

DeepSeek official API can be healthy while `deepseek-v4-pro` returns empty `message.content` in a very short non-streaming smoke test. In the observed response, the model emitted reasoning text and hit the length limit before producing final content.

### Error

```text
model: deepseek-v4-pro
message.content: ""
finish_reason: length
reasoning_content: non-empty
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Endpoint: `https://api.deepseek.com/chat/completions`
- `deepseek-v4-flash` returned non-empty `OK` in the same smoke test.

### Suggested Fix

Use `deepseek-v4-flash` as the default first-run Marginalia model. If switching to `deepseek-v4-pro`, give it enough output budget and check both `reasoning_content` and `message.content` before deciding the provider or key is broken.

## [ERR-20260619-003] marginalia_bge_semantic_rebuild_long_timeout
**Logged**: 2026-06-19
**Priority**: medium
**Status**: active

### Summary

Marginalia semantic-index rebuilds through the CarbonRAG BGE-M3 shim can exceed 15-30 minute command timeouts after large Markdown files such as `03_CrossProject/tooling.md` or `04_Runbooks/super-yusu-v0.3-marginalia.md` change. A timeout does not necessarily mean the index is corrupt; inspect tmp files, BGE health, and the final manifest.

### Error

```text
command timed out after 904542 milliseconds
command timed out after 1804169 milliseconds
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Command: `.\tools\build-marginalia-semantic-index-yusu.ps1 -UseLocalBge -Resume`
- BGE shim remained healthy and returned 1024-dimensional embeddings, but individual embedding calls could take several minutes.

### Suggested Fix

Restart the `8011` BGE shim if a request appears stuck, warm it with a single `/v1/embeddings` smoke, then rerun the semantic build with a long timeout. In the final verified recovery run, `-Resume -ProgressEvery 1` completed in about 55 minutes and wrote a 179-entry `semantic-index/default` manifest. Do not block unrelated UI work on this all-entry maintenance job.

## [ERR-20260619-001] in_app_browser_local_url_blocked
**Logged**: 2026-06-19
**Priority**: medium
**Status**: open

### Summary

Codex Desktop 的内置浏览器在一次本地个人站验收中拒绝访问 `http://127.0.0.1:8787/#projects`，并给出 Browser Use URL policy 拦截。这个限制不代表本地服务或前端接口失败。

### Error

```text
Browser Use cannot visit the requested page because its URL is blocked by the Browser Use URL policy.
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU\07_PersonalSite`
- Local server: `127.0.0.1:8787`
- The HTTP API smoke tests for `/api/status`, `/api/search`, and `/api/doc` passed in the same run.

### Suggested Fix

When this browser policy appears, do not bypass it with another browser automation surface. Verify the local site with API smoke tests, source-level checks, and manual user opening at `http://127.0.0.1:8787/` when visual confirmation is needed.

## [ERR-20260620-001] iframe_mistaken_for_source_integration
**Logged**: 2026-06-20
**Priority**: high
**Status**: resolved

### Summary

The first YUSU personal-site Marginalia integration used a custom Agent page plus an iframe pointing at a separately running `5173` UI and proxy calls to a separately running `8000` API. The user correctly rejected this: “embed” meant moving and adapting UI code so frontend and backend belong to the personal site, not placing another application inside a frame.

### Error

```text
Runtime required 8787 + 8000 + 5173, and the visible Marginalia surface was an iframe.
```

### Context

- Project/path: `F:\AcademicHub\0#YUSU\07_PersonalSite`
- Upstream: `vendor/marginalia`
- Correction date: 2026-06-20

### Suggested Fix

Treat “源码移过来 / 前后端融入 / 直接把 UI 接进来” as source integration. Mount native API routes in the host backend, build UI source under the host router, preserve upstream licensing, and prove the old frontend/backend ports are no longer required. The resolved YUSU runtime uses one `8787` FastAPI process; optional `8011` is only BGE model compute.

## [ERR-20260620-002] marginalia_duplicate_entry_tags_ingest_crash
**Logged**: 2026-06-20
**Priority**: high
**Status**: resolved

### Summary

Marginalia ingest can fail and repeatedly retry a file when one pipeline result contains duplicate tag suggestions for the same entry. A query for an existing `entry_tags` relation does not see a pending unflushed relation in the same transaction, so the handler may add duplicate `(entry_id, tag_id)` rows and hit the composite primary key.

### Error

```text
sqlite3.IntegrityError: UNIQUE constraint failed: entry_tags.entry_id, entry_tags.tag_id
```

### Context

- OS: Windows
- Project/path: `F:\AcademicHub\0#YUSU`
- Integrated backend: `07_PersonalSite/marginalia-backend/marginalia/tasks/handlers/ingest_file.py`
- Observed blocker: `materials-inventory.md` ingest task repeatedly failed while the Markdown mirror was otherwise current.

### Suggested Fix

Deduplicate tag ids inside the ingest transaction before adding `EntryTag` rows. Only increment `Tag.doc_count` and `last_used_at` after a new relation is actually attached. Keep a regression test that calls `_persist` with duplicate `TagSuggestion` values:

```powershell
& .\.tools\marginalia-venv\Scripts\python.exe .\07_PersonalSite\tests\test_marginalia_ingest_tags.py
```

## Entry Template

```md
## [ERR-YYYYMMDD-001] command_or_tool
**Logged**: YYYY-MM-DD HH:mm
**Priority**: low | medium | high | critical
**Status**: pending | resolved | promoted | wont_fix

### Summary

...

### Error

```text
...
```

### Context

- OS:
- Project/path:
- Command:

### Suggested Fix

...
```
