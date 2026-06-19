# Progress

## Current State

Local V0.3 preview scaffold is in place.

## Completed

- Inspected `记得整理/` materials.
- Extracted video metadata from `个人站.mp4` using the local HyperFrames ffmpeg/ffprobe packages.
- Sampled frames from the reference video and translated the design direction into a YUSU-specific brief.
- Confirmed image dimensions for certificate scans.
- Extracted structured text from:
  - `25国创赛北京赛区-三等奖.pdf`
  - `P020260526399177509374.docx`
- Added the local personal site under `07_PersonalSite/`.
- Added a Python standard-library backend with:
  - `/api/showcase`
  - `/api/status`
  - `/api/search`
  - `/api/doc`
  - `/media/raw/<filename>`
- Added the first structured showcase data file.
- Added read-only Markdown document opening from project links and search results, so the personal site can directly inspect old YUSU KB entries instead of only showing paths.
- Added top-level `主页 / 知识库 / Agent / Marginalia` navigation, a full-page Agent console under `#agent`, and a near-full-viewport Marginalia workspace under `#marginalia`.
- Added read-only personal-site proxy endpoints:
  - `/api/marginalia/status`
  - `/api/agent/session`
  - `/api/agent/chat`
- Switched the local Marginalia LLM route to DeepSeek official OpenAI-compatible API in the ignored runtime `.env`.
- Ran real Marginalia ingest after DeepSeek configuration: `new=0`, `modified=0` after the follow-up `-Check`.
- Rebuilt the local BGE-M3 semantic index to 179 entries.
- Improved certificate display so image scans use `object-fit: contain` and no longer crop certificate text.
- Generated a corrected landscape preview for the 2025 math-modeling certificate while preserving the raw original under `记得整理/`.

## Last Meaningful Update

- Date: 2026-06-19
- Source: administrator implementation pass in the YUSU vault
