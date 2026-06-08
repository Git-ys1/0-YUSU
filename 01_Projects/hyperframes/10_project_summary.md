# Project Summary

## One-Page Summary

`F:\Project\HyperFrames` is now a working local HyperFrames video production workspace. Each video should live under `productions/<id-slug>/` with source, assets, logs, snapshots, timing notes, research notes, and named outputs together. The first demo uses HTML, CSS, GSAP, a local audio bed, and HyperFrames-generated voiceover as the source of truth and renders to a verified 10-second 1920x1080 MP4 with an AAC narration audio stream. The second production, `002-guobao-fan-lyric-video`, is a verified 48-second Chinese lyric video with Edge TTS voiceover, VTT-derived lyric timing, original fruit-mecha HTML/CSS visuals, snapshots, and a final 1920x1080 MP4. The third production, `003-tian-binxian-profile`, is a verified 30-second Chinese concept founder-profile video using a user-provided headshot, Edge TTS narration, public energy-sector background research, and an explicit `概念人物志 / 虚构演绎` disclosure so fictionalized achievements are not presented as verified biography. The authoring path should prefer the installed Codex plugin `HyperFrames by HeyGen`, because its skills encode HyperFrames-specific rules for composition timing, GSAP timelines, linting, inspection, and rendering. The most important local infrastructure decisions are the `scripts/local-hyperframes.mjs` wrapper for FFmpeg/FFprobe PATH stability, `scripts/mux-audio.mjs` for verified audio muxing, and project-local audio-generation scripts for repeatable voiceover/tone-bed assets. Future work should keep `DESIGN.md` current before writing new compositions, run `npm run check:<id>` before rendering, and use named scripts such as `npm run render:003` for project outputs.

## Most Important Things

| Rank | Thing | Why It Matters | Evidence |
|---|---|---|---|
| 1 | Use the HyperFrames plugin skills as the authoring guide | Generic HTML/GSAP advice misses HyperFrames timing and render contracts | `03_decisions.md`, plugin cache path in `02_runbook.md` |
| 2 | Keep FFmpeg/FFprobe project-local through a wrapper | Initial doctor failed because system PATH lacked both tools | `05_known_issues.md`, `scripts/local-hyperframes.mjs` |
| 3 | Verify with lint, inspect, metadata, and snapshots | Video output can be technically valid while text/layout is wrong | `09_session_evidence.md`, `snapshots/contact-sheet.jpg` |
| 4 | Treat delegated plugin thread status as secondary evidence | The created `@HyperFrames by HeyGen` thread returned `systemError` | `05_known_issues.md`, `09_session_evidence.md` |
| 5 | Keep every video under a named production folder | Future videos need organized source, assets, snapshots, logs, and outputs | `README.md`, `productions/README.md` |
| 6 | Verify audio streams explicitly | HyperFrames recognized audio in metadata but v0.6.72 output initially had no audio stream | `05_known_issues.md`, `09_session_evidence.md` |
| 7 | Keep narration text and timing beside generated audio | Reproducible videos need source text and line timings, not just rendered media | `TIMING.md`, `09_session_evidence.md` |
| 8 | Use subtitle output as lyric-video timing source | Edge TTS VTT provided line timings for production `002` visual sync | `TIMING.md`, `03_CrossProject/tooling.md` |
| 9 | Separate researched context from fictionalized profile claims | Private/persona videos can look authoritative, so false biography must be labeled as concept copy | `003-tian-binxian-profile/assets/research/research-notes.md`, on-screen disclosure |

## Final Shape

- Current stable architecture: root workspace scripts plus per-video production folders under `productions/`.
- Current working workflow: edit composition -> `npm run audio:<id>` when audio is needed -> `npm run check:<id>` -> `npm run dev:<id>` -> `npm run render:<id>` -> verify with FFprobe/snapshots.
- Current product boundary: local HTML-to-video generation workspace, not a general web app.
- What should not be casually changed: the local wrapper, `DESIGN.md` visual identity gate, and npm script entrypoints.

## Hard-Won Lessons

- Rendering CLIs with native binaries should use project-local wrappers when system PATH is unreliable.
- HyperFrames lint/inspect and snapshot are both needed; lint alone cannot prove the viewer-facing frame.
- If sound matters, FFprobe must show an `audio` stream; do not rely only on HyperFrames `audioCount`.
- For HyperFrames TTS on Windows, prefer text-file input and preserve the exact narration text beside generated audio.
- For lyric videos, generate subtitle/VTT output and write a `TIMING.md` as the source of truth for GSAP scene synchronization.
- For fictionalized profile videos, store source notes and keep a visible concept/fiction disclosure in the composition.
- A newly created Codex plugin thread is not stronger evidence than current worktree artifacts and command outputs.

## Rules For Future Codex

- Always read `DESIGN.md` before writing HyperFrames composition HTML.
- Always run `npm run check:<id>` before rendering or presenting a result.
- Always verify final MP4 duration and dimensions with FFprobe.
- Always verify final MP4 audio stream when a video is supposed to have sound.
- Never assume FFmpeg is on system PATH; use npm scripts.
- Escalate to the user when a new video requires branding, assets, voiceover, or source footage not present in the repository.
- Use original generated/vector/CSS visuals for fan-themed videos unless licensed official assets are explicitly supplied.
- For private-person or fictionalized persona videos, do not convert researched background context into fake verified biography; label concept work in video and docs.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| HyperFrames project should use the installed Codex plugin skills as authoring source | project-only | `01_Projects/hyperframes/03_decisions.md` | kept | Plugin cache and current project-specific workflow |
| Rendering CLIs with FFmpeg/FFprobe should use project-local wrapper when PATH is unreliable | cross-project tooling | `03_CrossProject/tooling.md` | written | Initial doctor failure and resolved wrapper |
| New plugin/thread discovery surfaces may fail or lag; current artifact evidence remains authoritative | cross-project tooling | `03_CrossProject/tooling.md` | updated | Existing fresh skill discovery note plus HyperFrames delegated thread `systemError` |
| Video completion needs lint/inspect plus visual snapshots, not metadata alone | cross-project tooling | `03_CrossProject/tooling.md` | written | `npm run check`, FFprobe, and snapshot contact sheet |
| Keep repo-local workflow docs for repeatable media generation | project-only | `F:\Project\HyperFrames\docs\WORKFLOW.md` | kept | User asked this workspace to become the video production home |
| Upgrade HyperFrames CLI from 0.6.72 to 0.6.73 | deferred | `01_Projects/hyperframes/06_todo_next.md` | pending | Doctor reported newer version, but current render is verified |
| Per-video production folders prevent output/source sprawl | project-only | `F:\Project\HyperFrames\productions\README.md` | written | User requested organized project outputs and code |
| Audio stream must be verified and may need mux workaround | cross-project tooling | `03_CrossProject/tooling.md` | updated | HyperFrames metadata recognized audio but FFprobe initially showed no audio stream |
| HyperFrames TTS should use text-file input on Windows and Mandarin may need fallback providers | cross-project tooling | `03_CrossProject/tooling.md` | updated | Local Kokoro Mandarin failed; Windows SAPI and Edge TTS were verified |
| Edge TTS VTT can drive lyric-video timing | cross-project tooling | `03_CrossProject/tooling.md` | updated | Production `002` used Edge VTT for `TIMING.md` and GSAP scene synchronization |
| Fan-themed videos should use original visuals unless licensed assets are supplied | project-only | `productions/002-guobao-fan-lyric-video/DESIGN.md` | written | User asked to search materials; implementation used public references but no official image imports |
| Fictionalized profile videos need explicit concept disclosure and source/claim separation | cross-project pattern | `03_CrossProject/patterns.md` | written | Production `003` used real energy-sector sources only as background and kept achievements fictionalized with an on-screen `概念人物志 / 虚构演绎` label |

## Remaining Risks

| Risk | Why It Remains | Next Check |
|---|---|---|
| HyperFrames CLI update available | Current pinned generated version is 0.6.72; doctor reports 0.6.73 | Run upgrade compatibility check before changing scripts |
| Delegated `@HyperFrames by HeyGen` thread hit `systemError` | The app thread tool created the thread but did not produce a usable run | Retry from Codex UI if plugin-thread behavior itself needs validation |
| Generated artifacts may need retention policy | Some videos/snapshots should be deliverables; some logs should not be committed | Decide versioning policy before Git initialization |

## Source Links

- Development history: `07_development_history.md`
- Known issues: `05_known_issues.md`
- Decisions: `03_decisions.md`
- Session evidence: `09_session_evidence.md`

