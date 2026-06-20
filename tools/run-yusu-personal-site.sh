#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$ROOT/.marginalia-yusu"
PYTHON="${YUSU_MARGINALIA_PYTHON:-$ROOT/.tools/marginalia-venv/bin/python}"
SERVER="$ROOT/07_PersonalSite/server.py"

if [[ ! -x "$PYTHON" ]]; then
  echo "Marginalia runtime is missing: $PYTHON" >&2
  exit 1
fi
if [[ ! -f "$ROOT/07_PersonalSite/marginalia-dist/index.html" ]]; then
  echo "Integrated UI is missing. Run tools/build-yusu-integrated-marginalia-ui.sh first." >&2
  exit 1
fi

mkdir -p "$ROOT/.tools/tmp" "$RUNTIME_DIR/home"
export TMPDIR="$ROOT/.tools/tmp"
export HOME="$RUNTIME_DIR/home"
export MARGINALIA_HOME="$RUNTIME_DIR/data"
export MARGINALIA_DESKTOP=1
export YUSU_MARGINALIA_WORKER=true

exec "$PYTHON" "$SERVER" --host "${YUSU_SITE_HOST:-127.0.0.1}" --port "${YUSU_SITE_PORT:-8787}"
