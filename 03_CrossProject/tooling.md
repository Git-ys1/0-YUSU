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

### PowerShell and Git special syntax

在 PowerShell 里使用 Git 上游引用必须给 `@{u}` 加引号：

```powershell
git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
```

### SQLite temporary SQL on Windows

Windows 下避免 `sqlite3 .read C:\...\tmp.sql` 这种反斜杠路径 dot-command；路径里的 `\t` 可能被当作制表符。优先通过 stdin 管道给 sqlite3 输入 SQL。

### Playwright file upload allowed roots

Playwright 文件上传工具可能只能从声明的 allowed roots 选文件。若目标仓库文件不在允许目录，先复制临时文件到 allowed root，再测试上传，避免误判为上传功能坏了。

### Windows desktop tool launchers

交付 Windows GUI/自动化工具时，不要让用户双击 `app.py`。系统文件关联可能调用旧 Python 并一闪而过。应提供 `.bat` 启动入口，直接调用项目虚拟环境里的 `python.exe`，并提供 debug 启动脚本、日志和 `pause`。

Evidence:

- Auto Play evidence: `start.bat`, `start_debug.bat`, `stop_running_scripts.ps1`, `logs/startup.log`.

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

### Marginalia scripted ingest must auto-confirm and wait

Marginalia `/ingest --all` prompts for confirmation and then queues per-file background tasks. Automation should use:

```text
/ingest --all --yes
/quit
w
```

Otherwise a script can report success after file projection while DB ingest tasks are still pending or never accepted. Always verify `tasks` and `files.ingest_status` afterward.

Evidence: On 2026-06-05, yusu vault ingest applied 98 entries only after `--yes`; waiting completed 98 `ingest_file` tasks and left 98 files `done`.

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
