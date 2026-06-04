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
| Find own Codex session | mature project ingestion | use `tools/find-own-codex-session.*` to resolve `CODEX_THREAD_ID` to the current engineer JSONL |
| Mature project retro audit | mature project ingestion | use `tools/mature-project-retro-audit.*` with one explicit engineer JSONL as a read-only quality gate before completion |
| 宏录制器 | Windows 游戏自动化 | 固定流程优先于图像识别；必须保留绝对起点并提供中断快捷键 |
| Keil MDK | STM32 firmware build | Simple Oscilloscope uses `tools\build_keil.bat`; keep Keil-first workflow unless user changes direction |
| STM32CubeProgrammer | STM32 flashing | use `tools\flash_stlink.bat`, then verify device protocol version/status |
| PyInstaller | Windows desktop packaging | stop running packaged exe before rebuilding onedir dist |
| Windows desktop launchers | Windows GUI tools | provide .bat launcher, debug launcher, logs, and old-process cleanup; Auto Play evidence in start.bat / start_debug.bat |
| Windows GUI automation input stack | game automation | use RegisterHotKey, optional PyDirectInput, admin launcher, and window-mode fallback guidance |
