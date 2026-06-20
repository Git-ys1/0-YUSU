#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/07_PersonalSite/marginalia-ui"
DIST="$ROOT/07_PersonalSite/marginalia-dist"
BUILD_DIR="${YUSU_MARGINALIA_BUILD_DIR:-/tmp/yusu-integrated-marginalia-build}"

if [[ ! -f "$SOURCE/package.json" ]]; then
  echo "Integrated Marginalia UI source not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR" "$DIST" "$ROOT/.tools/npm-cache"
rsync -a --delete --exclude node_modules --exclude dist "$SOURCE/" "$BUILD_DIR/"

export npm_config_cache="$ROOT/.tools/npm-cache"
(
  cd "$BUILD_DIR"
  npm ci
  npx --yes --package node@22 node node_modules/typescript/bin/tsc -b
  npx --yes --package node@22 node node_modules/vite/bin/vite.js build
)

rsync -a --delete "$BUILD_DIR/dist/" "$DIST/"
printf 'Integrated Marginalia UI built: %s\n' "$DIST"
