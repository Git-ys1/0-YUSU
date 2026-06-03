#!/usr/bin/env bash
set -euo pipefail

sessions_root="${HOME}/.codex/sessions"
project_path=""
keyword=""
top=50
min_mb=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sessions-root)
      sessions_root="$2"
      shift 2
      ;;
    --project-path)
      project_path="$2"
      shift 2
      ;;
    --keyword)
      keyword="$2"
      shift 2
      ;;
    --top)
      top="$2"
      shift 2
      ;;
    --min-mb)
      min_mb="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

python3 - "$sessions_root" "$project_path" "$keyword" "$top" "$min_mb" <<'PY'
import json
import os
import sys
from pathlib import Path

sessions_root, project_path, keyword, top, min_mb = sys.argv[1:]
top = int(top)
min_mb = float(min_mb)
root = Path(sessions_root).expanduser()
if not root.exists():
    raise SystemExit(f"Sessions root not found: {root}")

project_real = str(Path(project_path).expanduser().resolve()).lower() if project_path else ""
keyword = keyword.lower()
rows = []

for path in root.rglob("*.jsonl"):
    size_mb = path.stat().st_size / (1024 * 1024)
    if size_mb < min_mb:
        continue
    cwd = ""
    session_id = ""
    source = ""
    timestamp = ""
    model_provider = ""
    try:
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            first = handle.readline()
        if first:
            meta = json.loads(first)
            payload = meta.get("payload", {})
            cwd = str(payload.get("cwd", ""))
            session_id = str(payload.get("id", ""))
            source = str(payload.get("source", ""))
            timestamp = str(payload.get("timestamp", ""))
            model_provider = str(payload.get("model_provider", ""))
    except Exception:
        source = "unreadable-meta"

    if project_real:
        if not cwd:
            continue
        cwd_real = str(Path(cwd).expanduser().resolve()).lower()
        if not (cwd_real.startswith(project_real) or project_real.startswith(cwd_real)):
            continue

    haystack = f"{path} {cwd} {session_id} {source}".lower()
    if keyword and keyword not in haystack:
        continue

    rows.append((path.stat().st_mtime, size_mb, timestamp, session_id, cwd, source, model_provider, str(path)))

rows.sort(reverse=True)
print("MB\tLastWriteUnix\tSessionId\tCWD\tPath")
for mtime, size_mb, timestamp, session_id, cwd, source, model_provider, path in rows[:top]:
    print(f"{size_mb:.2f}\t{int(mtime)}\t{session_id}\t{cwd}\t{path}")
PY
