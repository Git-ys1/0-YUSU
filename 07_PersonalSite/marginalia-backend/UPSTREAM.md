# Marginalia Backend Upstream

This directory contains the source-integrated backend used by the YUSU personal site.

## Provenance

- Upstream repository: `https://github.com/shenmintao/marginalia`
- Source path copied from: `vendor/marginalia/src/marginalia`
- Upstream commit: `70f28bc381aafd86f047f9fe422c594c86d4330e`
- Copied into this vault: 2026-06-20

## Local Integration

`07_PersonalSite/server.py` prepends `07_PersonalSite/marginalia-backend` to `sys.path` before importing `marginalia.main`. This makes the single `8787` FastAPI process use the backend source committed in this repository.

Local patches should be small, evidence-backed, and documented in the YUSU runbooks. Keep `vendor/marginalia` as the upstream reference for diffing and isolated debugging.

## License

Marginalia is licensed as AGPL-3.0-or-later. The upstream license text is preserved in `UPSTREAM_LICENSE.txt`.
