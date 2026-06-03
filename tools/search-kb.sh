#!/usr/bin/env bash
set -euo pipefail

query="${1:-}"
context="${2:-2}"
mode="${3:-any}"

if [[ -z "$query" ]]; then
  echo "Usage: search-kb.sh <query> [context]" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(bash "$script_dir/resolve-kb-root.sh")"

paths=(
  "$root/01_Projects"
  "$root/03_CrossProject"
  "$root/02_GlobalMemory"
  "$root/04_Runbooks"
  "$root/06_Maps"
  "$root/00_Inbox"
)

existing=()
for path in "${paths[@]}"; do
  [[ -d "$path" ]] && existing+=("$path")
done

echo "KB root: $root"
echo "Query: $query"
echo

pattern="$query"
if [[ "$mode" != "exact" ]]; then
  pattern="$(printf '%s\n' $query | sed -e 's/[][(){}.^$*+?|\\]/\\&/g' | paste -sd'|' -)"
fi

if command -v rg >/dev/null 2>&1; then
  rg -n -i -C "$context" --glob "*.md" -- "$pattern" "${existing[@]}" || {
    code=$?
    if [[ "$code" -eq 1 ]]; then
      echo "No matches."
      exit 0
    fi
    exit "$code"
  }
else
  grep -RInE --include='*.md' -i -C "$context" -- "$pattern" "${existing[@]}" || {
    code=$?
    if [[ "$code" -eq 1 ]]; then
      echo "No matches."
      exit 0
    fi
    exit "$code"
  }
fi
