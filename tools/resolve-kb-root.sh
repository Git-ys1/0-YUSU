#!/usr/bin/env bash
set -euo pipefail

candidates=()

if [[ -n "${YUSU_KB_ROOT:-}" ]]; then
  candidates+=("$YUSU_KB_ROOT")
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
candidates+=("$(cd "$script_dir/.." && pwd)")
candidates+=("$HOME/YUSU-KB")
candidates+=("/mnt/f/AcademicHub/0#YUSU")
candidates+=("/mnt/yusu-f/AcademicHub/0#YUSU")

if [[ -d "/media/${USER:-}" ]]; then
  while IFS= read -r path; do
    candidates+=("$path")
  done < <(find "/media/${USER:-}" -maxdepth 4 -type d -path "*/AcademicHub/0#YUSU" 2>/dev/null || true)
fi

seen=""
for candidate in "${candidates[@]}"; do
  [[ -n "$candidate" ]] || continue
  case "|$seen|" in
    *"|$candidate|"*) continue ;;
  esac
  seen="${seen}|${candidate}"

  if [[ -f "$candidate/00_START_HERE_FOR_CODEX.md" ]]; then
    cd "$candidate"
    pwd
    exit 0
  fi
done

echo "YUSU knowledge vault was not found. Set YUSU_KB_ROOT or mount the shared folder." >&2
exit 1

