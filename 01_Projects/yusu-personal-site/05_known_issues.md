# Known Issues

## Raw certificate images are not yet normalized

Some certificate photos are rotated or captured with perspective distortion. The display layer now uses readable `contain` previews and one generated landscape preview for the 2025 math-modeling certificate, while preserving raw originals. A later pass can still generate fully cropped, perspective-corrected derivatives for every certificate.

## Search is lexical, not semantic

The built-in `/api/search` endpoint scans Markdown with keyword matching. Native Marginalia chat/search under `/marginalia/*` still depends on the derived Marginalia DB and semantic index being synced separately after Markdown merges.

2026-06-20 note: one ingest blocker was fixed in the integrated backend. If a pipeline returns duplicate tag suggestions for the same file, the local backend now deduplicates them before inserting `entry_tags` instead of retrying until the index falls behind.

2026-06-20 state: SQLite ingest is current at 198 live files all `done`; the BGE-M3 semantic vector index remains at 179 entries until the next deliberate slow rebuild.

## Semantic recall still uses an optional local model service

The Marginalia frontend and backend now run in one `8787` process. Semantic query embedding still uses the CarbonRAG BGE-M3 shim on `8011`; this is an optional model-compute dependency, not a second Marginalia frontend/backend. Without it, disable semantic recall or use lexical/metadata retrieval.

## The site is local-only

There is no cloud deployment, auth layer, or public privacy review yet. Do not expose this server outside `127.0.0.1` until the raw media and project facts have been reviewed for public release.

The `/kaoyan/` route serves a generated exam-prep dashboard from `F:\AcademicHub\000资料相关\000考研`. Treat it as local-only as well: it may include named admissions rows and browser-local verification workflows, so do not publish it or copy its generated HTML into the shared YUSU vault.

The `/routine/` route stores private Tomato ToDo exports and merged routine records under ignored `07_PersonalSite/local/routine/`. Do not commit those files.

## Tomato ToDo `.xls` should be parsed in the browser

The user's Tomato ToDo export is a real old OLE/BIFF `.xls`. Direct Excel COM calls from an interactive PowerShell console can read Chinese correctly, but Python-launched backend COM/xlrd attempts produced mojibake for Chinese fields such as `高等数学`.

The stable path is:

1. Browser loads vendored SheetJS from `07_PersonalSite/web/vendor/sheetjs/xlsx.full.min.js`.
2. `/routine/` parses `.xls/.xlsx/.csv/.tsv` in the browser.
3. Browser posts normalized JSON plus the original file to `/api/routine/import-json`.
4. Server stores the original file and merges normalized records.

Do not re-enable direct server-side `.xls` import unless the encoding path is verified with the real Tomato ToDo file.

## Codex in-app browser may block the local URL

Codex Desktop's in-app browser may reject `http://127.0.0.1:8787/#projects` under Browser Use URL policy in some sessions. Treat that as a tool limitation if the HTTP smoke tests pass; verify with `/api/status`, `/api/search`, `/api/doc`, and manual browser opening when visual QA is needed.
