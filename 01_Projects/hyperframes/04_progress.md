# Progress

## 2026-06-05

- Initialized `F:\Project\HyperFrames` with `npx hyperframes init . --example blank --non-interactive --skip-skills --resolution landscape`.
- Confirmed HyperFrames CLI v0.6.72 and Codex plugin `HyperFrames by HeyGen`.
- Added project-local FFmpeg/FFprobe via npm dev dependencies and `scripts/local-hyperframes.mjs`.
- Created `DESIGN.md` and a 10-second 1920x1080 GSAP composition in `index.html`.
- Ran `npm run check`: 0 lint warnings/errors and 0 visual layout issues.
- Started preview on `http://localhost:3022/#project/001-first-hyperframes-demo`.
- Rendered and verified the first root `output.mp4`: H.264, 1920x1080, 30fps, 10.000s.
- Captured visual snapshots at 0.8s, 2.6s, 4.0s, 5.6s, and 8.0s.
- Reorganized workspace into `productions/001-first-hyperframes-demo/` so each video keeps source, assets, logs, snapshots, and outputs together.
- Added local audio bed and stable FFmpeg post-render mux; final `001-first-hyperframes-demo.mp4` now has H.264 video plus AAC audio stream.


- Added local HyperFrames `tts` voiceover workflow for production `001`: narration text file, generated `af_nova` voiceover, 10-second narration mix, `scripts/mix-voiceover.mjs`, `npm run audio:001`, and final render muxed with the narration mix.
- Verified final `001-first-hyperframes-demo.mp4`: H.264 1920x1080 30fps duration 10.000s; AAC audio 48000 Hz mono duration 9.962s. FFmpeg `volumedetect` on final audio showed non-silent output (`mean_volume: -33.5 dB`, `max_volume: -13.7 dB`).
- Documented that local Mandarin Kokoro TTS (`zf_xiaobei --lang zh`) currently fails on this Windows setup because the eSpeak backend does not support `zh`; hosted TTS is the practical Mandarin production route for now.
- Created production `002-guobao-fan-lyric-video`, a 48-second 1920x1080 Chinese entertainment fan lyric video themed around Guo Bao Te Gong using original HTML/CSS fruit-mecha visuals.
- Generated Chinese Edge TTS voiceover with `zh-CN-XiaoxiaoNeural`, used the generated VTT timestamps to build `TIMING.md`, mixed the narration with a generated original tone bed, and rendered `outputs/002-guobao-fan-lyric-video.mp4`.
- Verified production `002`: `npm run check:002` returned 0 lint errors, 0 warnings, 0 layout issues; FFprobe showed H.264 1920x1080 30fps 48.000s plus AAC 24000 Hz mono 47.915s; audio `volumedetect` showed non-silent output (`mean_volume: -25.9 dB`, `max_volume: -6.5 dB`).
- Created production `003-tian-binxian-profile`, a 30-second 1920x1080 premium founder-profile concept video for Tian Binxian using the user-provided headshot, real energy-sector background research, and explicitly fictionalized achievements labeled on-screen as `概念人物志 / 虚构演绎`.
- Generated Chinese Edge TTS narration with `zh-CN-YunyangNeural`, created a 30-second corporate energy audio bed, mixed narration plus bed, rendered `outputs/003-tian-binxian-profile.mp4`, captured six key-frame snapshots, and started preview on `http://localhost:3024/#project/003-tian-binxian-profile`.
- Verified production `003`: `npm run check:003` returned 0 lint errors, 0 warnings, 0 layout issues; FFprobe showed H.264 1920x1080 30fps 30.000s plus AAC 24000 Hz mono 29.952s; audio `volumedetect` showed non-silent output (`mean_volume: -32.5 dB`, `max_volume: -7.8 dB`).
