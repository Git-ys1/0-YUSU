# Development History

## 2026-06-05: First setup and demo render

The user designated `F:\Project\HyperFrames` as the future production home for HyperFrames videos and asked Codex to use the HyperFrames plugin route as much as possible.

The installed Codex plugin `HyperFrames by HeyGen` was confirmed from the local plugin cache. The plugin contained skills for HyperFrames composition authoring, CLI usage, registry blocks, GSAP, and website-to-video conversion.

The workspace was empty at first. It was initialized with HyperFrames CLI using the blank landscape example. The generated project was then edited to add a `DESIGN.md`, a 10-second 1920x1080 GSAP composition, local FFmpeg/FFprobe support, workflow documentation, and npm scripts.

Environment checks initially failed for missing FFmpeg/FFprobe and Chrome. Chrome was installed through `npx hyperframes browser ensure`. FFmpeg/FFprobe were solved with npm dev dependencies plus a local wrapper.

Verification finished with:

- `npm run check`: 0 lint errors/warnings and 0 layout issues.
- Preview server running on port 3022.
- Initial `npm run render`: produced the first root-level `F:\Project\HyperFrames\output.mp4` before the workspace was reorganized.
- FFprobe confirmed H.264, 1920x1080, 30fps, 10.000s.
- HyperFrames snapshot generated five key frames for visual review.

The workspace was then reorganized so each video lives under `productions/<id-slug>/`. The first demo moved to `productions/001-first-hyperframes-demo/` with source, assets, logs, snapshots, and named output. A local audio bed was generated with FFmpeg and wired into `index.html` as an `<audio>` track. HyperFrames v0.6.72 recognized `audioCount: 1`, but the produced MP4 did not retain an audio stream, so a stable post-render FFmpeg mux step was added. The final named output now has H.264 video and AAC audio.

The separate Codex thread requested with `@HyperFrames by HeyGen` was created, but `read_thread` reported `systemError`; current worktree artifacts and command outputs were used as authoritative evidence.
