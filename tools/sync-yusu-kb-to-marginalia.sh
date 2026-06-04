#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tool_root="$root/.tools"
runtime_dir="$root/.marginalia-yusu"
library_root="$runtime_dir/data/library/yusu-kb"
marginalia_bin="$tool_root/marginalia-venv/bin/marginalia"
check=0
ingest=0
clean=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      check=1
      shift
      ;;
    --ingest)
      ingest=1
      shift
      ;;
    --no-clean)
      clean=0
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ ! -x "$marginalia_bin" ]]; then
  echo "Marginalia is not installed. Run tools/setup-marginalia-yusu.sh first." >&2
  exit 1
fi

if [[ "$clean" -eq 1 ]]; then
  rm -rf "$library_root"
fi
mkdir -p "$library_root" "$tool_root/tmp" "$runtime_dir/home"

count=0
while IFS= read -r -d '' file; do
  rel="${file#$root/}"
  case "$rel" in
    .git/*|.obsidian/*|.tools/*|.marginalia-yusu/*|vendor/*|00_Inbox/shared-checks/*)
      continue
      ;;
  esac
  mkdir -p "$library_root/$(dirname "$rel")"
  cp "$file" "$library_root/$rel"
  count=$((count + 1))
done < <(find "$root" -type f \( -name '*.md' -o -name '*.txt' \) -print0)

echo "Projected $count file(s) into $library_root"

if [[ "$check" -eq 0 && "$ingest" -eq 0 ]]; then
  exit 0
fi

export TMPDIR="$tool_root/tmp"
export PIP_CACHE_DIR="$tool_root/pip-cache"
export HOME="$runtime_dir/home"
export MARGINALIA_HOME="$runtime_dir/data"

cd "$runtime_dir"
if [[ "$ingest" -eq 1 ]]; then
  export WORKER_ENABLED=true
  printf '/check\n/ingest --all\n/quit\nq\n' | "$marginalia_bin"
else
  export WORKER_ENABLED=false
  export LLM_DEFAULT_API_KEY="${LLM_DEFAULT_API_KEY:-placeholder-for-readonly-check}"
  printf '/check\n/quit\nq\n' | "$marginalia_bin"
fi
