# Decisions

## Use Codex plugin skills as the authoring source

Decision: Use the installed `HyperFrames by HeyGen` plugin skills (`hyperframes`, `hyperframes-cli`, `gsap`) as the implementation guide.

Reason: The plugin encodes HyperFrames-specific rules that generic web knowledge misses, including `data-*` timing, paused GSAP timelines, visual identity gates, lint/inspect workflow, and render commands.

Evidence: Plugin manifest and skills were present under `C:\Users\yusu\.codex\plugins\cache\openai-curated\hyperframes\e2d08a2e`.

## Keep FFmpeg/FFprobe project-local

Decision: Add `@ffmpeg-installer/ffmpeg` and `@ffprobe-installer/ffprobe` to dev dependencies and route commands through `scripts/local-hyperframes.mjs`.

Reason: Initial doctor showed FFmpeg/FFprobe missing from PATH. A project-local wrapper makes the workflow reproducible on this Windows machine and easier to port.

Evidence: `npm run doctor` later reported FFmpeg and FFprobe as found through the wrapper.

## Freeze CLI command through npm scripts

Decision: Use npm scripts as the stable entrypoint (`npm run lint`, `npm run inspect`, `npm run dev`, `npm run render`) rather than asking future agents to remember raw `npx hyperframes` incantations.

Reason: The scripts encode version, output path, and local binary setup.

Evidence: `npm run check` and `npm run render` completed successfully on 2026-06-05.
