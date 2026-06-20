# Tooling Notes

这里记录跨项目复用的工具和环境经验。

## Candidate Notes

- Windows 命令执行应注意 PowerShell profile 噪声；能用 `-NoProfile` 时优先使用。
- 搜索文件和文本时优先用 `rg` 和 `rg --files`。

## Active Notes

### Windows PowerShell profile noise

在 Windows 上如果需要启动额外的 Windows PowerShell 5.1 进程，优先使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\path\to\script.ps1
```

不要把 profile 解析错误直接当成目标脚本失败；先看目标命令是否仍产生了有效输出。

### Windows-safe timestamps

用于文件名的时间戳不要包含冒号。尤其是 PowerShell 的 `K` 时区格式会生成 `+08:00`，在 NTFS 上会触发 alternate data stream 语义。跨系统日志文件名应使用 `2026-06-03T22-48-50+08-00.md` 这类格式。

### PowerShell Start-Process redirection needs separate files

`Start-Process` 不能让 `-RedirectStandardOutput` 和 `-RedirectStandardError` 指向同一个文件；否则会报错：

```text
This command cannot be run because "RedirectStandardOutput" and "RedirectStandardError" are same.
```

启动后台服务时给 stdout/stderr 分别指定不同日志，或只重定向其中一个。

Evidence: 2026-06-16 在 `kaoyan-bjtu-ee` 为本地 dashboard 启动 `python -m http.server` 时触发；改为 `dashboard-server.out.log` 和 `dashboard-server.err.log` 后成功。

### Codex skill YAML frontmatter

`SKILL.md` frontmatter 只写 `name` 和 `description`。如果 `description` 含冒号，必须加双引号；否则 YAML 会把冒号当成映射语法，导致 skill 校验失败。创建或更新 skill 后运行：

```powershell
python C:\Users\yusu\.codex\skills\.system\skill-creator\scripts\quick_validate.py <skill-folder>
```

### Freshly installed Codex skills need a fresh discovery surface

如果某个 skill 是在当前长线程中刚创建或安装的，不要声称“当前线程已经被动触发成功”。当前线程的技能清单可能是在会话开始时加载的。可立即验证的证据是：

- `SKILL.md` frontmatter 有效
- skill 已链接到实际发现路径
- 全局 `AGENTS.md` 会提示使用它
- 搜索脚本能命中知识库

要证明被动触发，应开启新的 Codex 线程或重启后观察技能清单/行为。

HyperFrames evidence: on 2026-06-05 the `HyperFrames by HeyGen` plugin was installed and its skills were available in the plugin cache, but a newly created delegated thread with `@HyperFrames by HeyGen` reported `systemError`. For plugin work, treat current worktree artifacts, CLI outputs, and rendered files as stronger completion evidence than delegated-thread status alone.

### Project-local wrappers for native media CLIs

Video/audio render tools often depend on native binaries such as FFmpeg and FFprobe. If `doctor` reports missing tools on Windows, prefer a project-local wrapper that prepends npm-installed binary directories to `PATH` instead of relying on machine-wide PATH mutation.

Pattern:

```powershell
npm install --save-dev @ffmpeg-installer/ffmpeg @ffprobe-installer/ffprobe
```

Then route stable scripts through a Node wrapper that sets `FFMPEG_PATH`, `FFPROBE_PATH`, and `PATH` before calling the render CLI.

Evidence: HyperFrames on `F:\Project\HyperFrames` initially failed doctor for missing FFmpeg/FFprobe; `scripts/local-hyperframes.mjs` fixed `npm run doctor`, `npm run check`, and `npm run render`.

### Video completion needs visual-frame evidence

For HTML-to-video workflows, successful encode metadata is necessary but not enough. A valid MP4 can still have clipped text, missing timed elements, or bad layout. Pair lint/inspect with key-frame snapshots or contact sheets before claiming the video is correct.

Evidence: HyperFrames first demo used `npm run check`, FFprobe metadata, and `npm run hf -- snapshot --at 0.8,2.6,4.0,5.6,8.0 --describe false`; the contact sheet confirmed the title and three lines appeared in sequence.

If the video is supposed to have sound, also verify FFprobe shows an `audio` stream. HyperFrames v0.6.72 on `F:\Project\HyperFrames` reported `audioCount: 1` during render, but the MP4 initially contained only video. The stable workaround was to render an intermediate video-only MP4 and then mux the audio with FFmpeg (`scripts/mux-audio.mjs`), producing a final file with H.264 video and AAC audio.

### GitHub repository names may be normalized

GitHub 远端仓库名不一定保留本地目录名中的特殊字符。本次请求 `0#YUSU`，GitHub CLI 创建结果为 `Git-ys1/0-YUSU`。以后写同步指南时，要区分本地路径名和远端仓库名，不要硬假设二者完全相同。

### Dual-boot shared folder is not proven until both OSes write-read

Windows 上存在 `F:\...` 不能证明 Ubuntu 原生双系统能看见它。只有 Ubuntu 挂载/clone 后写入检查文件，并且 Windows 能读到，才算共享闭环。未验证前优先采用 GitHub private repo pull/push 作为跨端同步层。

### Tailscale Serve HTTP fallback

若 Tailscale 已运行且 MagicDNS 可用，但证书域名条件不足，HTTPS Serve 可能卡住。只用于私网手机访问时，HTTP Serve 可先落地，链路仍走 Tailscale 加密隧道；等证书条件满足再切 HTTPS。

### Codex session restore is SQLite plus JSONL

导入或修复 Codex 会话时，不能只复制 `sessions/**/rollout-*.jsonl`。还要检查 `state_5.sqlite` 中的 thread 记录、`cwd` 过滤、`rollout_path`、`updated_at`、`agent_role`，以及 JSONL 第一条 `session_meta.payload.id` 是否与目标 thread id 对齐。

### Codex home junction and disk pressure

On this Windows machine, `C:\Users\yusu\.codex` is a junction to `F:\AcademicHub\.codex`. Seeing the C-path in logs or tools does not prove Codex data is physically on C. Verify with:

```powershell
Get-Item C:\Users\yusu\.codex -Force | Select FullName,Attributes,LinkType,Target
fsutil reparsepoint query C:\Users\yusu\.codex
```

When deleting huge Codex temp directories through the junction, Windows may send the files to Recycle Bin; free space may not return until Recycle Bin is emptied. Use `tools\check-yusu-disk-footprint.ps1 -IncludeAppDataCaches` from the YUSU vault to check C/F free space, the Codex junction target, repo-local caches, and common AppData caches.

### PowerShell and Git special syntax

在 PowerShell 里使用 Git 上游引用必须给 `@{u}` 加引号：

```powershell
git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
```

### SQLite temporary SQL on Windows

Windows 下避免 `sqlite3 .read C:\...\tmp.sql` 这种反斜杠路径 dot-command；路径里的 `\t` 可能被当作制表符。优先通过 stdin 管道给 sqlite3 输入 SQL。

### Python py_compile pycache permission on Windows

Windows 上 `python -m py_compile ...` 可能在替换已有 `__pycache__/*.pyc` 时因为文件锁或权限报 `WinError 5`，但源码语法本身没问题。只做语法检查时，可改用 `compile(Path(...).read_text(...), path, "exec")`，避免写 pyc。

Evidence: `kaoyan-bjtu-ee` on 2026-06-17; see [[02_GlobalMemory/ERRORS#ERR-20260617-001-python_py_compile_pyc_permission]].

### Playwright file upload allowed roots

Playwright 文件上传工具可能只能从声明的 allowed roots 选文件。若目标仓库文件不在允许目录，先复制临时文件到 allowed root，再测试上传，避免误判为上传功能坏了。

### Windows desktop tool launchers

交付 Windows GUI/自动化工具时，不要让用户双击 `app.py`。系统文件关联可能调用旧 Python 并一闪而过。应提供 `.bat` 启动入口，直接调用项目虚拟环境里的 `python.exe`，并提供 debug 启动脚本、日志和 `pause`。

如果桌面工具是 PyWebView / FastAPI / React 这类本地网页壳，启动器还应检查后端依赖导入、前端 `dist` 是否比源码旧、以及后端端口是否 ready；把启动过程写到 `scratch/startup.log` 或等价日志里。验证时不要只按父进程 PID 查端口，因为 PyWebView 可能派生子 Python 进程承载窗口和本地服务。

Evidence:

- Auto Play evidence: `start.bat`, `start_debug.bat`, `stop_running_scripts.ps1`, `logs/startup.log`.
- 发票管理归档软件 evidence: `启动软件.bat --check`, `run_desktop.py`, `scratch/startup.log`; fixed stale Vite dist and global Python 3.7 launch failure on 2026-06-17.

### FastAPI static frontend builds can go stale

当 FastAPI 后端直接托管 React/Vite 的 `dist` 时，源码正确不代表用户看到的包正确。若浏览器错误指向旧 hash bundle，先重建 `frontend/dist`，并让启动器用时间戳或构建脚本避免继续托管旧包。

Evidence: 发票管理归档软件 on 2026-06-17 had `scratch/frontend_error.log` showing `duplicateWarning is not defined` in old `assets/index-B-eGjsZg.js`, while current source already defined the state. `npm run build` regenerated `dist`, and the launcher now rebuilds when source files are newer than `frontend/dist/index.html`.

### Windows GUI automation input stack

游戏或桌面自动化在独占全屏、管理员权限游戏、DirectInput 场景下，普通 `pynput` 监听和标准输入注入可能失效。优先考虑 Windows `RegisterHotKey`、PyDirectInput、管理员启动入口，并提示用户必要时切到无边框窗口或窗口化全屏。

Evidence:

- Auto Play evidence: `autogame/win_hotkeys.py`, `autogame/macro_engine.py`, `以管理员启动宏录制器.bat`, `README.md`.
### 宏录制器冒烟测试

测试键盘连点器或宏引擎时，先避免不可控真实输入。优先 monkeypatch 底层 press/release 方法，断言生成的事件顺序；确认后再在无风险窗口里测试真实输入。Auto Play 的多键连点器轮流/同时模式就适合用这个方式验证。

Evidence:

- Auto Play evidence: multi-key clicker sequence/simultaneous smoke test monkeypatched `_press_key` and `_release_keys` before any real input test.



### Windows PyInstaller rebuilds can fail when the packaged exe is still running

When rebuilding a PyInstaller onedir app on Windows, the previous packaged exe or DLLs may be locked by a still-running process. The symptom is `Access is denied` while removing or overwriting `dist\<AppName>`.

Before retrying, inspect and stop the packaged process:

```powershell
Get-Process | Where-Object { $_.ProcessName -like '*SimpleScopePC*' }
Stop-Process -Id <pid>
```

Evidence: Simple Oscilloscope V0.9.3 failed on `dist\SimpleScopePC\SimpleScopePC.exe` until PID `22756` was stopped.

### Local BGE-M3 embedding via OpenAI-compatible shim

Some tools, including Marginalia V0.2.1, can use local embeddings only if they are exposed as an OpenAI-compatible `/v1/embeddings` API. CarbonRAG already has local `BAAI/bge-m3` model files and a Python wrapper, but it does not expose that wrapper as HTTP.

Use the yusu vault shim instead of pointing tools at CarbonRAG's normal backend:

```powershell
F:\AcademicHub\0#YUSU\tools\run-carbonrag-bge-embedding-server.ps1
```

Then configure the consumer with:

```ini
EMBEDDING_PROVIDER=openai-compatible
EMBEDDING_BASE_URL=http://127.0.0.1:8011/v1
EMBEDDING_API_KEY=local-bge-key
EMBEDDING_MODEL=BAAI/bge-m3
EMBEDDING_DIMENSIONS=1024
```

Evidence: 2026-06-05 local smoke returned one `1024`-dimension embedding through `/v1/embeddings`.

If `/v1/embeddings` returns `500` with `[Errno 22] Invalid argument` while CarbonRAG direct `embed_documents()` still works, restart only the `8011` shim and smoke a single embedding before rebuilding downstream indexes. Treat this as a stale shim/runtime state first, not as proof the BGE-M3 model files are corrupt.

Evidence: On 2026-06-08, the long-running shim failed during Marginalia semantic-index build, while CarbonRAG direct Python embedding returned `ok 1 1024 True`; restarting `tools\run-carbonrag-bge-embedding-server.ps1` restored `/v1/embeddings`.

### Codex proxy streaming needs a local non-streaming shim

Some Codex-oriented proxy endpoints can stream usable text but return empty `message.content` in non-streaming `chat.completions` or `responses`. Marginalia expects non-streaming `chat.completions`, so point Marginalia at the local shim:

```powershell
F:\AcademicHub\0#YUSU\tools\run-codex-proxy-llm-shim.ps1
```

Marginalia local `.env`:

```ini
LLM_DEFAULT_PROVIDER=openai-compatible
LLM_DEFAULT_BASE_URL=http://127.0.0.1:8010/v1
LLM_DEFAULT_API_KEY=local-llm-key
LLM_DEFAULT_MODEL=gpt-5.4
```

Run a smoke before ingest. If the upstream proxy returns `502 unknown provider for model ...`, do not blame Marginalia; wait for proxy routing to recover or switch provider.

Evidence: 2026-06-05 direct CLI proxy streaming returned `OK`, non-streaming returned empty content; later the same proxy returned `502 unknown provider for model gpt-5.4` and empty `/models`.

### DeepSeek official API is the current Marginalia LLM route

For YUSU Marginalia, prefer DeepSeek's official OpenAI-compatible API over the old Codex proxy route. Configure only the ignored local runtime file:

```powershell
$env:DEEPSEEK_API_KEY = "<real key>"
F:\AcademicHub\0#YUSU\tools\configure-marginalia-deepseek.ps1
```

Use `deepseek-v4-flash` as the first-run model because it returned non-empty `message.content` in a non-streaming smoke test. `deepseek-v4-pro` can return reasoning text but empty content when the response token budget is too small; do not use that failure mode as proof the key or DeepSeek endpoint is broken.

Evidence: On 2026-06-19, DeepSeek `/models` returned `deepseek-v4-flash` and `deepseek-v4-pro`; `deepseek-v4-flash` returned `OK`; `deepseek-v4-pro` returned empty content under a short `max_tokens` smoke. Marginalia ingest then applied 47 new and 18 modified files, and the final BGE rebuild contained 179 entries.

### Marginalia scripted ingest must auto-confirm and wait

Marginalia `/ingest --all` prompts for confirmation and then queues per-file background tasks. Automation should use:

```text
/ingest --all --yes
/quit
w
```

Otherwise a script can report success after file projection while DB ingest tasks are still pending or never accepted. Always verify `tasks` and `files.ingest_status` afterward.

Evidence: On 2026-06-05, yusu vault ingest applied 98 entries only after `--yes`; waiting completed 98 `ingest_file` tasks and left 98 files `done`.

After Git merges into the Markdown vault, do not assume Marginalia sees the new files. Run `sync-yusu-kb-to-marginalia.ps1 -Check`, then `-Ingest`, then rebuild the semantic index. Markdown/Git is canonical; Marginalia SQLite and `semantic-index/default` are derived state.

Treat a full BGE semantic rebuild as slow background maintenance, not a prerequisite for unrelated UI or documentation work. Keep Markdown canonical, bring SQLite ingest current first, and schedule the all-entry vector rebuild at a deliberate checkpoint; on 2026-06-19 a 179-entry local BGE-M3 build took about 55 minutes.

For the YUSU personal site, normal Marginalia runtime is now source-integrated rather than proxied: `07_PersonalSite/server.py` loads `07_PersonalSite/marginalia-backend` first, registers YUSU routes on the local Marginalia FastAPI app, and the copied React source under `07_PersonalSite/marginalia-ui/` builds to same-origin `/marginalia/*`. `tools/run-yusu-personal-site.*` replaces the old three-process `8787 + 8000 + 5173` startup. Keep `vendor/marginalia`, `run-marginalia-api-yusu.*`, and `run-marginalia-ui-yusu.*` only for upstream reference or isolated debugging.

Marginalia ingest can fail if a pipeline returns duplicate tag suggestions for a single entry and the handler inserts duplicate `(entry_id, tag_id)` rows in one transaction. Fix this at the backend source level by tracking seen tag ids before `EntryTag` inserts and by incrementing `Tag.doc_count` only when a new relation is actually attached. Evidence: YUSU integrated backend patch on 2026-06-20 plus `07_PersonalSite/tests/test_marginalia_ingest_tags.py`.

If a file remains `ingest_status=pending` even though its `ingest_file` task is `done`, prefer the official reprocess path. The modified-file ingest path can leave `ingested_at` set, causing the handler to skip the file and never flip it back to `done`.

Evidence: On 2026-06-08, CSR lower firmware and CleanScout Vue3 Markdown were committed, but Marginalia initially saw 48 new and 12 modified files. After ingest and BGE reindex, the CSR semantic smoke query ranked `01_Projects/cleanscout-rover-lower-firmware/02_runbook.md` first, and the final index contained 146 entries.

### Avoid piped Chinese prompts into Marginalia CLI on Windows

PowerShell-piped Chinese chat prompts can be corrupted before Marginalia sends the request, producing `UnicodeEncodeError: surrogates not allowed`. Use ASCII automation prompts, a UTF-8-safe invocation, or the browser UI for Chinese questions.

Evidence: Marginalia CLI failed on a piped Chinese question on 2026-06-05; the same path with ASCII reached the LLM provider.

### FlagEmbedding Optional import bug

`FlagEmbedding` in the CarbonRAG environment can fail on direct import because one trainer module references `Optional` before importing it. CarbonRAG's `app.rag.embeddings` works around this by injecting `typing.Optional` into `builtins` before importing `BGEM3FlagModel`.

When reusing CarbonRAG's BGE-M3, call `app.rag.embeddings.embed_documents()` instead of importing `FlagEmbedding` directly.

Evidence: direct `import FlagEmbedding` failed on 2026-06-05 with `NameError: name 'Optional' is not defined`; `from app.rag.embeddings import embed_documents` returned `bge_m3 BAAI/bge-m3 1 1024 True`.

### Keil plus STM32CubeProgrammer Windows release loop

For Keil-first STM32 repositories, preserve the existing project files and use the local command-line build/flash scripts as the release path. A practical loop is:

```powershell
tools\build_keil.bat
tools\flash_stlink.bat
```

Then verify the running firmware through its normal serial protocol. This avoids confusing "hex was built" with "board was flashed."

Evidence: Simple Oscilloscope V0.9.3 generated `Objects\SimpleOscilloscope.hex`, flashed by ST-Link, and COM14 returned firmware `0.9.3`.

### HyperFrames TTS on Windows

For HyperFrames `tts` on Windows, keep exact narration in a `.txt` file and pass the file path to the CLI. Inline quoted text can generate an unusably short WAV even when the same text works from a file.

Also treat non-English Kokoro voices as environment-sensitive. On `F:\Project\HyperFrames`, `zf_xiaobei --lang zh` failed with `RuntimeError: language "zh" is not supported by the espeak backend`; English `af_nova` worked after a project-local Python 3.11 venv installed `kokoro-onnx` and `soundfile`.

Evidence: On 2026-06-05, inline English narration generated a 0.81-second WAV, while file input generated a 7.98-second WAV. The final narration mix was muxed into the HyperFrames MP4 and verified with FFprobe plus FFmpeg `volumedetect`.

### Chinese TTS fallback ladder on Windows

When a local TTS stack cannot synthesize Mandarin, check installed Windows SAPI voices before reaching for paid APIs:

```powershell
Add-Type -AssemblyName System.Speech
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.GetInstalledVoices() | ForEach-Object { $_.VoiceInfo }
```

On `F:\Project\HyperFrames`, `Microsoft Huihui Desktop zh-CN` was available and generated a valid WAV through System.Speech. For better demo quality without an API key, `edge-tts` with `zh-CN-XiaoxiaoNeural` generated a much more natural Chinese MP3, which FFmpeg could mix/mux into a HyperFrames MP4. Treat Edge TTS as convenient but unofficial; for commercial or policy-sensitive production, use an official hosted provider such as OpenAI Audio, Azure Speech, HeyGen TTS, or ElevenLabs.

### Edge TTS VTT can drive lyric-video timing

For lyric or caption-driven videos, generate `edge-tts` media and subtitles together, then treat the VTT as the timing source for HyperFrames scenes:

```powershell
.tools\tts-venv\Scripts\edge-tts.exe --voice zh-CN-XiaoxiaoNeural --file narration.zh-CN.txt --write-media voice.mp3 --write-subtitles voice.vtt
```

Evidence: HyperFrames production `002-guobao-fan-lyric-video` used the Edge VTT line timings to build `TIMING.md` and a GSAP scene table. `npm run check:002` returned 0 lint errors/warnings and 0 layout issues; the rendered MP4 had verified video/audio streams and contact sheets showed the Chinese lyric lines aligned with matching visual beats.

### Historical STM32 build logs do not prove the current machine can compile

Imported STM32 vendor examples often include `*.build_log.htm` or IDE HTML logs that show a previous machine once built successfully. Treat those logs as artifact evidence only, not as proof that the current machine already has a usable Keil toolchain.

Before claiming a newly imported example is locally buildable:

1. rediscover the current machine's `UV4.exe` or equivalent;
2. compare that real path against the historical log path;
3. only say "local build verified" after an actual rebuild on the current machine.

If the current machine cannot yet rediscover the compiler path, it is acceptable to flash a verified existing `hex`, but say clearly that flashing was verified while local rebuild was not.

Evidence: CleanScout Rover lower-firmware mechanical-arm vendor baseline on 2026-06-07 had `template.build_log.htm` pointing at `D:\Keil_v5\ARM\ARMCC\Bin`, while the current machine could not confirm that Keil path. The safe path was to keep the log as historical evidence and flash the already generated `template.hex`.

### ST-Link read-only identity check before flashing imported STM32 hex

When a repository receives a new STM32 subproject or vendor baseline, do a read-only ST-Link connection check before writing flash. A minimal pattern is:

```powershell
STM32_Programmer_CLI.exe -c port=SWD mode=UR reset=HWrst -r32 0x08000000 4
```

This confirms probe visibility, target voltage, device ID / density, flash size, and that the board at least responds under reset. Only after that should you flash the imported `hex`. This reduces the chance of blindly writing a mismatched image just because ST-Link was detected.

Evidence: CleanScout Rover lower-firmware mechanical-arm baseline on 2026-06-07 was first identified as `STM32F101/F103 High-density`, `Device ID 0x414`, `256 KB`, and only then flashed with `template.hex`.

### Board firmware cannot be assumed equal to repo artifacts

In long-running embedded projects with local experimental branches, do not assume the MCU currently runs the same image as the latest repo `hex` or the latest `main` commit. Verify the board state explicitly through one or more of:

- read-only flash comparison
- version/identity over the normal runtime protocol
- fresh flash plus post-flash behavior check

Without that verification, "the repo changed" and "the board changed" are separate claims.

Evidence: CleanScout Rover lower-firmware auditing on 2026-06-07 showed that the STM32 board contents did not exactly match the current formal RF1 firmware outputs, even after comparing current and reconstructed local artifacts.

### Keil GUI may rewrite project XML and local debug fields

Keil/uVision can rewrite `.uvprojx`, `.uvoptx`, local debug fields, and formatting just by opening or saving a project. In embedded repos where the project file itself is versioned, treat GUI-side changes as suspicious until a zero-diff or intentional-diff review proves otherwise.

Recommended discipline:

1. isolate project-file changes from source changes;
2. diff `.uvprojx` separately before commit;
3. ignore `.uvguix.*`, `.uvoptx`, local J-Link logs, and generated debug config unless the project explicitly needs them.

Evidence: CleanScout Rover lower-firmware cleanup on 2026-06-07 had to restore Keil project files after GUI-side rewrites, even though the underlying runtime behavior was meant to stay unchanged.

### Backend deploy scripts must load runtime env before Prisma

Prisma CLI validates `schema.prisma` before migrations run, so update/bootstrap scripts must load the production env file first. If `DATABASE_URL` is missing during `npx prisma migrate deploy`, the deployment script is wrong even if the systemd service would later have the env.

Evidence: CleanScout `cleanscout-rover-vue3` V-1.9.7 update script fixes and repeated VPS `DATABASE_URL` failures.

### Deployed revision marker for cloud update verification

When a deployment syncs only a backend subdirectory, write the source commit to a deployed revision file such as `/opt/vline-backend/backend/.deploy-revision`. Future operators can verify whether cloud backend is actually latest without guessing from Git state elsewhere.

Evidence: CleanScout `cleanscout-rover-vue3` V-1.9.7 cloud update verification.

### Raw MJPEG relay over parse/repack for display streams

If a camera's native MJPEG endpoint is smooth, preserve its stream shape as far as possible before trying FPS constants. For H5 display, backend can relay multipart MJPEG directly; snapshot remains fallback.

Evidence: CleanScout `cleanscout-rover-vue3` V-2.2.2.

### Orange Pi remote SSH development access

For the local Windows Codex environment, the Orange Pi 5 Max at `10.53.110.224` is reachable as `orangepi@10.53.110.224`. On 2026-06-08, a dedicated local SSH key was created at `C:\Users\yusu\.ssh\orangepi_10_53_110_224_ed25519`, its public key was added to the remote `authorized_keys`, and `C:\Users\yusu\.ssh\config` gained aliases `opi5max`, `orangepi5max`, and `10.53.110.224`.

Use `ssh opi5max` for future development. Verified remote baseline: hostname `orangepi5max`, Ubuntu 20.04.6 / Orange Pi Focal, kernel `5.10.160-rockchip-rk3588`, user `orangepi`, Git 2.25.1, Python 3.8.10, Docker 28.1.1, and about 33G free on `/`.

Do not store or repeat the device password in the knowledge vault.

### NoMachine install recovery on Orange Pi

If `apt install ./nomachine_arm64.deb` on `opi5max` appears stuck at around 60% with `/var/lib/dpkg/lock-frontend` held by `apt`, do not remove lock files first. Inspect `ps`, `lsof`, `dpkg -l nomachine`, `/var/log/dpkg.log`, and `/var/log/apt/term.log`.

On 2026-06-08, the package had actually reached `status installed nomachine:arm64 9.6.3-1`, while the outer `sudo apt` / `apt` processes were stopped (`T`) and still held the frontend/archive locks, with a defunct `dpkg` child. The safe recovery was to terminate the stopped outer apt/sudo processes, then run:

```bash
sudo dpkg --configure -a
sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y
/usr/NX/bin/nxserver --status
ss -lntp | grep ':4000'
```

Verified result: `dpkg -s nomachine` reports `Status: install ok installed`, NoMachine 9.6.3 services `nxserver`, `nxnode`, and `nxd` are enabled, and port `4000` listens on IPv4/IPv6. Windows `Test-NetConnection 10.53.110.224 -Port 4000` succeeded.

### RKNN Runtime integrity before model or OS blame

On RK3588 / RKNN deployments, do not trust Runtime version strings alone. A damaged `librknnrt.so` can still expose the expected version via `strings` while crashing at `RKNNLite.init_runtime()`.

Minimum ladder:

1. compare file size and SHA-256 against the official aarch64 runtime;
2. run `readelf` to catch truncated or malformed ELF sections;
3. run a direct `ctypes.CDLL("/usr/lib/librknnrt.so")` smoke test;
4. run a minimal C API `rknn_init` smoke test;
5. only then blame the model, Python Lite2 wheel, driver, or OS image.

Evidence: CleanScout OrangePi AI on 2026-06-09 found `/usr/lib/librknnrt.so` reported RKNN Runtime 2.3.2 but was 28 bytes shorter than the official v2.3.2 file and segfaulted on direct `dlopen`. Replacing it with the official `airockchip/rknn_model_zoo` v2.3.2 aarch64 runtime made C API and Python RKNNLite inference succeed.

### PowerPoint COM targeted slide edits

Windows 上定点修改现有 PPTX 时，如果用户给的是已完成视觉稿截图，优先考虑把该图作为整页图片替换目标页，而不是重建复杂科技风元素。重建会消耗时间且容易出现风格、对齐、分层和素材质感偏差。

如果必须用 PowerPoint COM 改可编辑元素，注意：

1. `slide.Shapes.Item(n)` 按集合序号取对象，不按 `Shape.Id` 取对象；按 ID 删除或改形状时要倒序遍历 `slide.Shapes` 并比较 `$shape.Id`。
2. `Line.Weight`、`Line.Transparency`、`Fill.Transparency` 等 COM 属性在 PowerShell 中要显式传 `[double]`，`TextRange.Font.Size` 要传 `[int]`，否则可能出现 `Unable to cast object`。
3. 修改前先复制原 PPTX，修改后用 PowerPoint 导出目标页 PNG 做视觉校验，确认页数、尺寸、文件大小正常。

Evidence: 2026-06-13 大创立项 PPT 第 8 页修改中，手工拼接参考页效果差；改为从原 PPT 复制后清空第 8 页并铺满用户给定 PNG，输出 `实验室具身智能与近场作业平台_第8页图片版.pptx`，11 页和 960x540 尺寸校验通过。
