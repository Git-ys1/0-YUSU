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

## Codex in-app browser may block the local URL

Codex Desktop's in-app browser may reject `http://127.0.0.1:8787/#projects` under Browser Use URL policy in some sessions. Treat that as a tool limitation if the HTTP smoke tests pass; verify with `/api/status`, `/api/search`, `/api/doc`, and manual browser opening when visual QA is needed.
