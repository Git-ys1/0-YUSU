# YUSU Personal Site

## Metadata

- Project Name: YUSU Personal Site / Showcase Wall
- Project Slug: `yusu-personal-site`
- Primary Path: `F:\AcademicHub\0#YUSU\07_PersonalSite`
- Status: local V0.3 integrated runtime
- Last Updated: 2026-06-20
- Maintainer/Source: YUSU KB administrator

## Quick Links

- [[00_project_brief]]
- [[02_runbook]]
- [[04_progress]]
- [[05_known_issues]]
- App: `07_PersonalSite/README.md`
- Design brief: `07_PersonalSite/notes/design-brief.md`
- Materials inventory: `07_PersonalSite/notes/materials-inventory.md`

## Current Shape

The current version is a local-only personal site that combines:

- a visual proof wall from `07_PersonalSite/media/raw/`
- a structured project spine from `07_PersonalSite/data/showcase.json`
- a live Markdown search API over the YUSU vault
- a read-only Markdown document viewer for project memories and search results
- source-integrated Marginalia React UI at `/marginalia/*`
- same-process Marginalia FastAPI routes at `/v1/*`
- a same-process Kaoyan dashboard route at `/kaoyan/` with a visible return link
- vendored Lenis smooth-scroll enhancement under `07_PersonalSite/web/vendor/lenis/`
- one normal runtime port, `127.0.0.1:8787`, with no iframe or Vite dev server

It is intentionally not hosted in the cloud yet.
