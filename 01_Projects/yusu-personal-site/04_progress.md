# Progress

## Current State

Local V0.3 source-integrated personal site and Marginalia runtime are in place.

## Completed

- Inspected the temporary `记得整理/` materials, then retired that folder after migrating files into `07_PersonalSite/media/`.
- Extracted video metadata from `07_PersonalSite/media/raw/reference/个人站.mp4` using the local HyperFrames ffmpeg/ffprobe packages.
- Sampled frames from the reference video and translated the design direction into a YUSU-specific brief.
- Confirmed image dimensions for certificate scans.
- Extracted structured text from:
  - `25国创赛北京赛区-三等奖.pdf`
  - `P020260526399177509374.docx`
- Added the local personal site under `07_PersonalSite/`.
- Initially added a Python standard-library backend with:
  - `/api/showcase`
  - `/api/status`
  - `/api/search`
  - `/api/doc`
  - `/media/raw/<filename>`
- Added the first structured showcase data file.
- Added read-only Markdown document opening from project links and search results, so the personal site can directly inspect old YUSU KB entries instead of only showing paths.
- Replaced the temporary proxy + iframe approach with a source-level integration:
  - copied the upstream React UI into `07_PersonalSite/marginalia-ui/` with AGPL provenance
  - copied the upstream Python backend into `07_PersonalSite/marginalia-backend/` with AGPL provenance
  - built and committed production assets under `07_PersonalSite/marginalia-dist/`
  - made `server.py` load the local backend source before importing Marginalia
  - registered personal-site routes directly on the local Marginalia FastAPI app
  - serves native `/v1`, `/marginalia/*`, and `/api/*` routes from one `8787` process
  - removed runtime dependencies on ports `8000` and `5173`
- Added direct `YUSU 主页` navigation and responsive chat/library layouts to the integrated React UI.
- Fixed a local Marginalia ingest crash where duplicate pipeline tag suggestions could insert duplicate `entry_tags` rows in one transaction.
- Added a direct regression test for duplicate tag suggestions under `07_PersonalSite/tests/`.
- Switched the local Marginalia LLM route to DeepSeek official OpenAI-compatible API in the ignored runtime `.env`.
- Ran real Marginalia ingest after DeepSeek configuration: `new=0`, `modified=0` after the follow-up `-Check`.
- Rebuilt the local BGE-M3 semantic index to 179 entries.
- After source integration and documentation updates on 2026-06-20, reran Marginalia ingest and reprocessed stuck modified files: `sync-yusu-kb-to-marginalia.ps1 -Check` now reports `in_sync=198`, `new=0`, `modified=0`, and DB verification shows 198 live files all `done`.
- Left the BGE-M3 semantic vector index at 179 entries intentionally; rebuild it later as slow maintenance rather than blocking UI/source integration.
- Improved certificate display so image scans use `object-fit: contain` and no longer crop certificate text.
- Generated a corrected landscape preview for the 2025 math-modeling certificate while preserving the raw original under `07_PersonalSite/media/raw/awards/`.
- Re-read the full 4:25 reference video through a generated contact sheet, added the formal media library, and improved the showcase visual system with a workspace dock, reference panel, hover/reveal motion, and vendored Lenis smooth scrolling.
- Added a fixed `返回 YUSU` control to the `/kaoyan/` route by injecting it only in the personal-site response, leaving the source dashboard HTML unchanged.
- Added a same-process Kaoyan dashboard route:
  - `/kaoyan/` serves the current exam-prep dashboard from `F:\AcademicHub\000资料相关\000考研`.
  - `/api/kaoyan/status` exposes availability, source path, byte size, and update time.
  - The personal-site top navigation and the Kaoyan project card now link to the dashboard.
  - The generated dashboard HTML remains in the source exam project and is not copied into the YUSU vault.

## Last Meaningful Update

- Date: 2026-06-20
- Source: administrator source-integration pass in the YUSU vault; Kaoyan static dashboard mount added
