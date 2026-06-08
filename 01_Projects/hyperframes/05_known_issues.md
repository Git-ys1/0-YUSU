# Known Issues

## FFmpeg/FFprobe not on system PATH

Evidence: initial `npx hyperframes doctor` reported FFmpeg and FFprobe missing.

Resolution: install project-local binaries:

```powershell
npm install --save-dev @ffmpeg-installer/ffmpeg @ffprobe-installer/ffprobe
```

Use `scripts/local-hyperframes.mjs` for all CLI calls so HyperFrames sees those binaries.

## Chrome missing on first run

Evidence: initial `npx hyperframes doctor` reported Chrome missing.

Resolution:

```powershell
npx hyperframes browser ensure
```

## Codex new-thread delegation can report systemError

Evidence: creating a separate thread with `@HyperFrames by HeyGen` returned thread id `019e978e-7001-74b3-abe0-023e4e2a4bcc`, but `read_thread` showed status `systemError`.

Resolution: treat the current worktree, CLI outputs, and rendered artifacts as authoritative completion evidence. Do not rely on the delegated thread status alone.

## HyperFrames v0.6.72 recognized audio but final MP4 lost the stream

Evidence: after adding an `<audio>` element, HyperFrames render metadata showed `audioCount: 1`, but FFprobe on the MP4 showed only the H.264 video stream.

Resolution: keep the `<audio>` element in composition source, but make `npm run render:001` render a video-only intermediate and then use `scripts/mux-audio.mjs` to mux the local audio file into the named final MP4. Verify final output with FFprobe and require both `video` and `audio` streams.


## HyperFrames local TTS: use text files on Windows

Evidence: running `node scripts/local-hyperframes.mjs tts "This is my first HyperFrames video..." --voice af_nova` on 2026-06-05 produced an unusably short 0.81-second WAV. Running the same narration from `productions/001-first-hyperframes-demo/assets/audio/001-first-hyperframes-demo-narration.txt` produced the expected 7.98-second WAV.

Resolution: for reusable narration, save exact spoken text as a `.txt` file beside the audio assets and pass that file to `npm run tts:<id>` / `hyperframes tts`. Keep the spoken text in source control or the production folder so the voiceover is reproducible.

## HyperFrames local Mandarin TTS may fail on Windows

Evidence: `zf_xiaobei --lang zh` failed on 2026-06-05 with `RuntimeError: language "zh" is not supported by the espeak backend`, even after installing `kokoro-onnx` and `soundfile` in a project-local Python 3.11 venv.

Resolution: local English Kokoro voiceover works with `af_nova`. For production Mandarin voiceover, use a hosted TTS provider such as OpenAI Audio, HeyGen TTS, or ElevenLabs, or fix the system phonemizer/eSpeak setup before relying on `zf_xiaobei`.

## Chinese voiceover resources can come from Windows SAPI or Edge TTS

Evidence: on 2026-06-05 this Windows machine had `Microsoft Huihui Desktop zh-CN` installed under System.Speech. `scripts/windows-sapi-tts.ps1` generated `001-first-hyperframes-demo-voiceover.zh-CN.wav` from a UTF-8 Chinese narration file. Installing `edge-tts` in `.tools\tts-venv` and using `zh-CN-XiaoxiaoNeural` generated `001-first-hyperframes-demo-voiceover.zh-CN.edge.mp3`, which mixed into `001-first-hyperframes-demo-narration-mix.zh-CN.edge.wav` and muxed into `001-first-hyperframes-demo.zh-CN.edge.mp4`.

Resolution: use Windows SAPI as a fully local fallback, but prefer Edge neural voice for demo-quality Chinese when internet is available. For commercial or policy-sensitive production, use an official hosted TTS API such as OpenAI Audio or Azure Speech instead of the unofficial Edge route.
