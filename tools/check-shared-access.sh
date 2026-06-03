#!/usr/bin/env bash
set -euo pipefail

actor="${1:-ubuntu}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(bash "$script_dir/resolve-kb-root.sh")"
check_dir="$root/00_Inbox/shared-checks"
mkdir -p "$check_dir"

timestamp="$(date -Iseconds | tr ':' '-')"
file="$check_dir/$actor-$timestamp.md"

cat > "$file" <<EOF
# Shared Access Check

- Actor: $actor
- OS: $(uname -a)
- Time: $timestamp
- KB Root: $root
EOF

echo "KB root: $root"
echo "Wrote: $file"
ls -lt "$check_dir" | head

