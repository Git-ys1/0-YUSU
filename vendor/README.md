# Vendor Dependencies

This directory contains external dependencies that are tracked as Git submodules or source references.

## marginalia

- Upstream: `https://github.com/shenmintao/marginalia`
- Local path: `vendor/marginalia`
- Current pinned commit: `70f28bc381aafd86f047f9fe422c594c86d4330e`
- Upstream version at integration time: `v0.2.1-4-g70f28bc`
- License: AGPL-3.0-or-later

Marginalia is used by Super YUSU V0.3 as an optional deep-retrieval and source-grounded research layer for this Markdown vault. It does not replace `rg`, `tools/search-kb.*`, or the `yusu-kb` skill for fast Codex lookup.

Runtime state is not stored here. Use:

- `.tools/marginalia-venv/` for the repo-local Python environment.
- `.marginalia-yusu/` for the repo-local Marginalia home, SQLite database, mirror library, cache, and local `.env`.

Both runtime paths are ignored by Git.
