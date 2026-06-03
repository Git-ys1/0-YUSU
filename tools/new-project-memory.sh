#!/usr/bin/env bash
set -euo pipefail

slug="${1:-}"
project_name="${2:-}"
project_path="${3:-}"

if [[ -z "$slug" ]]; then
  echo "Usage: new-project-memory.sh <slug> [project_name] [project_path]" >&2
  exit 2
fi

if [[ ! "$slug" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Slug must be lowercase letters/numbers/dashes, for example simple-oscilloscope." >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(bash "$script_dir/resolve-kb-root.sh")"
template="$root/05_Templates/project-memory"
target="$root/01_Projects/$slug"

if [[ -e "$target" ]]; then
  echo "Project memory already exists: $target" >&2
  exit 1
fi

cp -R "$template" "$target"

readme="$target/README.md"
tmp="$readme.tmp"
sed \
  -e "s/- Project Name:/- Project Name: $project_name/" \
  -e "s/- Project Slug:/- Project Slug: $slug/" \
  -e "s|- Primary Path:|- Primary Path: $project_path|" \
  -e "s/- Last Updated:/- Last Updated: $(date +%F)/" \
  "$readme" > "$tmp"
mv "$tmp" "$readme"

echo "Created: $target"

