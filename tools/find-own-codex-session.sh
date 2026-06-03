#!/usr/bin/env bash
set -euo pipefail

sessions_root="${HOME}/.codex/sessions"
thread_id="${CODEX_THREAD_ID:-}"
project_path=""
keyword=""
top=10
recent_scan_limit=50
search_content=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sessions-root)
      sessions_root="$2"
      shift 2
      ;;
    --thread-id)
      thread_id="$2"
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
    --recent-scan-limit)
      recent_scan_limit="$2"
      shift 2
      ;;
    --search-content)
      search_content=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

python3 - "$sessions_root" "$thread_id" "$project_path" "$keyword" "$top" "$recent_scan_limit" "$search_content" <<'PY'
import json
import sys
from pathlib import Path

sessions_root, thread_id, project_path, keyword, top, recent_scan_limit, search_content = sys.argv[1:]
root = Path(sessions_root).expanduser()
top = int(top)
recent_scan_limit = int(recent_scan_limit)
keyword = keyword.lower()
search_content = bool(int(search_content))

if not root.exists():
    raise SystemExit(f"Sessions root not found: {root}")

project_real = str(Path(project_path).expanduser().resolve()).lower() if project_path else ""
if search_content and not keyword:
    raise SystemExit("--search-content requires --keyword")

def read_meta(path):
    cwd = ""
    session_id = ""
    timestamp = ""
    source = ""
    try:
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            first = handle.readline()
        if first:
            meta = json.loads(first)
            payload = meta.get("payload", {})
            session_id = str(payload.get("id", ""))
            timestamp = str(payload.get("timestamp", ""))
            cwd = str(payload.get("cwd", ""))
            source = str(payload.get("source", ""))
    except Exception:
        source = "unreadable-meta"
    return {
        "mb": path.stat().st_size / (1024 * 1024),
        "mtime": path.stat().st_mtime,
        "timestamp": timestamp,
        "session_id": session_id,
        "cwd": cwd,
        "source": source,
        "path": str(path),
        "confidence": "",
        "reason": "",
    }

all_files = list(root.rglob("*.jsonl"))
rows = []

if thread_id:
    for path in all_files:
        if thread_id not in path.name:
            continue
        row = read_meta(path)
        if row["session_id"] == thread_id or thread_id in path.name:
            row["confidence"] = "exact"
            row["reason"] = "CODEX_THREAD_ID matched filename or session_meta.payload.id"
            rows.append(row)

if not rows:
    files = sorted(all_files, key=lambda p: p.stat().st_mtime, reverse=True)[:recent_scan_limit]
    for path in files:
        row = read_meta(path)
        passed = True
        reasons = []
        if project_real:
            cwd = row["cwd"]
            if not cwd:
                passed = False
            else:
                cwd_real = str(Path(cwd).expanduser().resolve()).lower()
                if cwd_real.startswith(project_real) or project_real.startswith(cwd_real):
                    reasons.append("cwd matched project path")
                else:
                    passed = False
        if keyword:
            haystack = f"{row['path']} {row['cwd']} {row['session_id']} {row['source']}".lower()
            if keyword in haystack:
                reasons.append("metadata matched keyword")
            elif search_content:
                found = False
                with path.open("r", encoding="utf-8", errors="replace") as handle:
                    for line in handle:
                        if keyword in line.lower():
                            found = True
                            break
                if found:
                    reasons.append("content matched keyword")
                else:
                    passed = False
            else:
                passed = False
        if passed and (project_path or keyword):
            row["confidence"] = "candidate"
            row["reason"] = "; ".join(reasons)
            rows.append(row)

rows.sort(key=lambda item: item["mtime"], reverse=True)

if thread_id:
    print(f"CODEX_THREAD_ID: {thread_id}")
else:
    print("CODEX_THREAD_ID not set; using fallback filters.")

print("MB\tLastWriteUnix\tConfidence\tSessionId\tCWD\tPath\tReason")
for item in rows[:top]:
    print(f"{item['mb']:.2f}\t{int(item['mtime'])}\t{item['confidence']}\t{item['session_id']}\t{item['cwd']}\t{item['path']}\t{item['reason']}")

raise SystemExit(0 if rows else 1)
PY
