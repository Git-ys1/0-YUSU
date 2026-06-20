# Integrated Marginalia UI

This directory is a source-level integration of the Marginalia desktop UI.

- Upstream: `https://github.com/shenmintao/marginalia`
- Source snapshot: `vendor/marginalia` at `70f28bc381aafd86f047f9fe422c594c86d4330e`
- Upstream license: AGPL-3.0-or-later; preserved in `UPSTREAM_LICENSE.txt`
- YUSU changes: same-origin `/v1` API, `/marginalia` router base, no Tauri sidecar or editable remote API address, and a direct YUSU home link

Runtime uses the committed build under `07_PersonalSite/marginalia-dist/`. Rebuild it after changing this source with `tools/build-yusu-integrated-marginalia-ui.*`.
