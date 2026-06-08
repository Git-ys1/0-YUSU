# Tool Map

工具经验索引。

| Tool | Scope | Notes |
|---|---|---|
| rg | cross-project search | use for Markdown and source search |
| Obsidian | human UI | not Codex primary retrieval |
| Codex AGENTS.md | instruction loading | global and project guidance |
| Codex Skills | workflow playbooks | `yusu-kb` source lives in vault and is linked into both `.agents/skills` and `.codex/skills` |
| Codex Memories | generated recall | not canonical memory storage |
| Tailscale Serve | private remote access | HTTP Serve can be fallback when HTTPS cert domain is unavailable |
| Playwright upload | browser automation | uploaded file must be under allowed roots |
| SQLite CLI | local database repair | prefer stdin SQL over `.read C:\...` paths on Windows |
| Tkinter | Windows desktop UI | keep selection callbacks lightweight |
| Git | shell tooling | quote `@{u}` in PowerShell |
| Codex session inventory | mature project ingestion | use `tools/codex-session-inventory.*` only to locate the current engineer's own JSONL via metadata |
| SuperYUSU session inventory | vault administrator audit | `tools/build-superyusu-session-inventory.ps1` scans local Codex session metadata/topic counts for this management vault without copying raw conversation text |
| Find own Codex session | mature project ingestion | use `tools/find-own-codex-session.*` to resolve `CODEX_THREAD_ID` to the current engineer JSONL |
| Mature project retro audit | mature project ingestion | use `tools/mature-project-retro-audit.*` with one explicit engineer JSONL as a read-only quality gate before completion |
| Marginalia | deep KB research | optional cited investigation layer; yusu vault has 146 ingested entries and BGE semantic index as of 2026-06-08; Markdown merges require separate ingest/reindex, and chat depends on working LLM proxy |
| Codex proxy LLM shim | local LLM API adapter | `tools/run-codex-proxy-llm-shim.*` converts streaming CLI proxy output into non-streaming chat-completions for Marginalia |
| CarbonRAG BGE-M3 embedding shim | local semantic recall | `tools/run-carbonrag-bge-embedding-server.*` exposes CarbonRAG local BGE-M3 as OpenAI-compatible `/v1/embeddings` for Marginalia |
| HyperFrames | HTML video rendering | use Codex plugin `HyperFrames by HeyGen`; local repo wrapper injects FFmpeg/FFprobe for stable render commands |
| Edge TTS | Chinese video voiceover | useful no-key Mandarin narration route for HyperFrames demos; preserve source text and verify final audio stream |
| 宏录制器 | Windows 游戏自动化 | 固定流程优先于图像识别；必须保留绝对起点并提供中断快捷键 |
| Keil MDK | STM32 firmware build | keep Keil-first workflow where the repo already depends on it, but do not trust historical build logs as proof the current machine can still compile; rediscover the real `UV4.exe` first |
| STM32CubeProgrammer | STM32 flashing | use `tools\flash_stlink.bat` or local CLI wrapper, do a read-only board identity check for imported baselines, then verify runtime behavior after flash |
| PyInstaller | Windows desktop packaging | stop running packaged exe before rebuilding onedir dist |
| Windows desktop launchers | Windows GUI tools | provide .bat launcher, debug launcher, logs, and old-process cleanup; Auto Play evidence in start.bat / start_debug.bat |
| Windows GUI automation input stack | game automation | use RegisterHotKey, optional PyDirectInput, admin launcher, and window-mode fallback guidance |
| CleanScout backend deploy scripts | cloud backend operations | load env before Prisma; record `.deploy-revision`; use bootstrap/check/update split |
| Raw MJPEG relay | camera stream display | preserve ESP32-CAM native stream through worker/backend; avoid parse/repack if native page is smooth |
| Orange Pi SSH | remote embedded/Linux development | use `ssh opi5max` from Windows Codex; dedicated key is configured for `orangepi@10.53.110.224`; never store the password in vault |
| NoMachine on Orange Pi | remote desktop | if install sticks with an apt lock, inspect stopped apt/dpkg state first; on `opi5max`, NoMachine 9.6.3 is installed and listens on port 4000 |
