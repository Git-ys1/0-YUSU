#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tool_root="$root/.tools"
runtime_dir="$root/.marginalia-yusu"
marginalia_bin="$tool_root/marginalia-venv/bin/marginalia"

if [[ ! -x "$marginalia_bin" ]]; then
  echo "Marginalia is not installed. Run tools/setup-marginalia-yusu.sh first." >&2
  exit 1
fi

mkdir -p "$tool_root/tmp" "$runtime_dir/home"
export TMPDIR="$tool_root/tmp"
export PIP_CACHE_DIR="$tool_root/pip-cache"
export HOME="$runtime_dir/home"
export MARGINALIA_HOME="$runtime_dir/data"
export WORKER_ENABLED="${WORKER_ENABLED:-false}"

cd "$runtime_dir"
exec "$marginalia_bin" "$@"
