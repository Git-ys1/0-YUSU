# Known Issues

## Raw certificate images are not yet normalized

Some certificate photos are rotated or captured with perspective distortion. The display layer now uses readable `contain` previews and one generated landscape preview for the 2025 math-modeling certificate, while preserving raw originals. A later pass can still generate fully cropped, perspective-corrected derivatives for every certificate.

## Search is lexical, not semantic

The built-in `/api/search` endpoint scans Markdown with keyword matching. Marginalia Agent is available under `#agent` and the full upstream UI under `#marginalia`, but both still depend on the derived Marginalia DB and semantic index being synced separately after Markdown merges.

## The site is local-only

There is no cloud deployment, auth layer, or public privacy review yet. Do not expose this server outside `127.0.0.1` until the raw media and project facts have been reviewed for public release.

## Codex in-app browser may block the local URL

Codex Desktop's in-app browser may reject `http://127.0.0.1:8787/#projects` under Browser Use URL policy in some sessions. Treat that as a tool limitation if the HTTP smoke tests pass; verify with `/api/status`, `/api/search`, `/api/doc`, and manual browser opening when visual QA is needed.
