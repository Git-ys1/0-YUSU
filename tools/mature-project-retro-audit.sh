#!/usr/bin/env bash
set -euo pipefail

slug=""
project_path=""
session_file=""
kb_root="${YUSU_KB_ROOT:-}"
min_issues=5
min_decisions=3
min_history_lines=35
min_onboarding_lines=30
min_evidence_lines=20
min_summary_lines=25
min_important_things=3
min_routing_rows=3
allow_cwd_mismatch=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)
      slug="$2"
      shift 2
      ;;
    --project-path)
      project_path="$2"
      shift 2
      ;;
    --session-file)
      session_file="$2"
      shift 2
      ;;
    --kb-root)
      kb_root="$2"
      shift 2
      ;;
    --min-issues)
      min_issues="$2"
      shift 2
      ;;
    --min-decisions)
      min_decisions="$2"
      shift 2
      ;;
    --min-summary-lines)
      min_summary_lines="$2"
      shift 2
      ;;
    --min-important-things)
      min_important_things="$2"
      shift 2
      ;;
    --min-routing-rows)
      min_routing_rows="$2"
      shift 2
      ;;
    --allow-cwd-mismatch)
      allow_cwd_mismatch=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$slug" || -z "$project_path" || -z "$session_file" ]]; then
  echo "Usage: mature-project-retro-audit.sh --slug <slug> --project-path <path> --session-file <rollout.jsonl> [--kb-root <path>]" >&2
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "$kb_root" ]]; then
  kb_root="$(bash "$script_dir/resolve-kb-root.sh")"
fi

python3 - "$slug" "$project_path" "$session_file" "$kb_root" "$min_issues" "$min_decisions" "$min_history_lines" "$min_onboarding_lines" "$min_evidence_lines" "$min_summary_lines" "$min_important_things" "$min_routing_rows" "$allow_cwd_mismatch" <<'PY'
import json
import re
import subprocess
import sys
from pathlib import Path

slug, project_path, session_file, kb_root, min_issues, min_decisions, min_history_lines, min_onboarding_lines, min_evidence_lines, min_summary_lines, min_important_things, min_routing_rows, allow_cwd_mismatch = sys.argv[1:]
min_issues = int(min_issues)
min_decisions = int(min_decisions)
min_history_lines = int(min_history_lines)
min_onboarding_lines = int(min_onboarding_lines)
min_evidence_lines = int(min_evidence_lines)
min_summary_lines = int(min_summary_lines)
min_important_things = int(min_important_things)
min_routing_rows = int(min_routing_rows)
allow_cwd_mismatch = bool(int(allow_cwd_mismatch))

project = Path(project_path).expanduser()
session = Path(session_file).expanduser()
kb = Path(kb_root).expanduser()
project_memory = kb / "01_Projects" / slug
failures = []
warnings = []

def add_check(name, passed, detail, level="FAIL"):
    status = "PASS" if passed else ("WARN" if level == "WARN" else "FAIL")
    print(f"{status:<5} {name} - {detail}")
    if not passed:
        (warnings if level == "WARN" else failures).append(name)

def read_text(path):
    try:
        return Path(path).read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""

def remove_fences(text):
    kept = []
    inside = False
    for line in text.splitlines():
        if re.match(r"^\s*```", line):
            inside = not inside
            continue
        if not inside:
            kept.append(line)
    return "\n".join(kept)

def count_regex_lines(text, pattern):
    return len(re.findall(pattern, remove_fences(text), flags=re.MULTILINE))

def substantive_lines(text):
    count = 0
    for line in remove_fences(text).splitlines():
        trim = line.strip()
        if not trim or trim == "...":
            continue
        if re.match(r"^\|\s*-+", trim):
            continue
        if re.match(r"^[-*]\s*\.\.\.$", trim):
            continue
        if re.match(r"^[#|]+$", trim):
            continue
        if re.match(r"^[A-Za-z0-9 /_-]+:\s*$", trim):
            continue
        if re.match(r"^-\s*[A-Za-z0-9 /_-]+:\s*$", trim):
            continue
        count += 1
    return count

def session_meta(path):
    with path.open("r", encoding="utf-8", errors="replace") as handle:
        first = handle.readline()
    if not first:
        raise RuntimeError(f"Session file is empty: {path}")
    meta = json.loads(first)
    payload = meta.get("payload", {})
    return {
        "session_id": str(payload.get("id", "")),
        "timestamp": str(payload.get("timestamp", "")),
        "cwd": str(payload.get("cwd", "")),
        "source": str(payload.get("source", "")),
        "path": str(path),
        "filename": path.name,
        "mb": path.stat().st_size / (1024 * 1024),
    }

print("Mature project retrospective audit")
print(f"KB root: {kb}")
print(f"Project memory: {project_memory}")
print(f"Project path: {project}")
print(f"Engineer session file: {session}")
print()

add_check("Project memory directory exists", project_memory.exists(), str(project_memory))
add_check("Project path exists", project.exists(), str(project))
add_check("Engineer session file exists", session.exists(), str(session))
add_check("Engineer session file is JSONL", str(session).endswith(".jsonl"), str(session))

required = [
    "README.md",
    "00_project_brief.md",
    "01_architecture.md",
    "02_runbook.md",
    "03_decisions.md",
    "04_progress.md",
    "05_known_issues.md",
    "06_todo_next.md",
    "07_development_history.md",
    "08_onboarding_from_zero.md",
    "09_session_evidence.md",
    "10_project_summary.md",
]

for name in required:
    add_check(f"Required file {name}", (project_memory / name).exists(), name)

history = read_text(project_memory / "07_development_history.md")
onboarding = read_text(project_memory / "08_onboarding_from_zero.md")
evidence = read_text(project_memory / "09_session_evidence.md")
summary = read_text(project_memory / "10_project_summary.md")
issues = read_text(project_memory / "05_known_issues.md")
decisions = read_text(project_memory / "03_decisions.md")

history_lines = substantive_lines(history)
onboarding_lines = substantive_lines(onboarding)
evidence_lines = substantive_lines(evidence)
summary_lines = substantive_lines(summary)
issue_count = count_regex_lines(issues, r"^##\s+Issue:")
decision_count = count_regex_lines(decisions, r"^##\s+Decision:")
important_thing_count = count_regex_lines(summary, r"^\|\s*[0-9]+\s*\|\s*(?!\.\.\.\s*\|)")
routing_row_count = count_regex_lines(summary, r"^\|\s*(?!\.\.\.\s*\|)(?!Candidate Lesson\s*\|)[^|]+\s*\|\s*(project-only|cross-project pitfall|cross-project pattern|cross-project tooling|architecture decision|global learning|active global rule|feature request|map only|deferred)\s*\|")
adr_dir = project_memory / "adr"
adr_count = len([p for p in adr_dir.glob("*.md") if p.name != "_template.md"]) if adr_dir.exists() else 0
total_decisions = decision_count + adr_count

add_check("Development history has enough substance", history_lines >= min_history_lines, f"{history_lines} substantive lines, required {min_history_lines}")
add_check("From-zero onboarding has enough substance", onboarding_lines >= min_onboarding_lines, f"{onboarding_lines} substantive lines, required {min_onboarding_lines}")
add_check("Session evidence has enough substance", evidence_lines >= min_evidence_lines, f"{evidence_lines} substantive lines, required {min_evidence_lines}")
add_check("Project summary has enough substance", summary_lines >= min_summary_lines, f"{summary_lines} substantive lines, required {min_summary_lines}")
add_check("Project summary important things count", important_thing_count >= min_important_things, f"{important_thing_count} ranked things, required {min_important_things}")
add_check("Memory Routing Audit row count", routing_row_count >= min_routing_rows, f"{routing_row_count} routed lessons, required {min_routing_rows}")
add_check("Known issues count", issue_count >= min_issues, f"{issue_count} issues, required {min_issues}")
add_check("Decision/ADR count", total_decisions >= min_decisions, f"{total_decisions} decisions/ADRs, required {min_decisions}")

for section in ["One-Page Summary", "Most Important Things", "Final Shape", "Hard-Won Lessons", "Rules For Future Codex", "Memory Routing Audit", "Remaining Risks"]:
    add_check(f"Summary section: {section}", re.search(rf"^##\s+{re.escape(section)}\s*$", summary, re.MULTILINE) is not None, section)

for section in ["First 30 Minutes", "First Day", "Minimal Working Loop", "Common Newcomer Traps", "If Rebuilding From Scratch"]:
    add_check(f"Onboarding section: {section}", re.search(rf"^##\s+{re.escape(section)}\s*$", onboarding, re.MULTILINE) is not None, section)

for section in ["Timeline Summary", "Phase Notes", "Lessons By Stage"]:
    add_check(f"History section: {section}", re.search(rf"^##\s+{re.escape(section)}\s*$", history, re.MULTILINE) is not None, section)

try:
    git_root = subprocess.check_output(["git", "-C", str(project), "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL, text=True).strip()
    count = subprocess.check_output(["git", "-C", str(project), "rev-list", "--count", "HEAD"], text=True).strip()
    add_check("Git history readable", True, f"{count} commits at {git_root}")
except Exception:
    add_check("Git history readable", False, "not a git repository", "WARN")

meta = None
if session.exists():
    try:
        meta = session_meta(session)
        add_check("Engineer session metadata readable", True, f"{meta['session_id']} cwd={meta['cwd']} size={meta['mb']:.2f}MB")
    except Exception as exc:
        add_check("Engineer session metadata readable", False, str(exc))

if meta:
    try:
        project_real = str(project.resolve()).lower()
    except Exception:
        project_real = str(project).lower()
    cwd = meta["cwd"]
    cwd_real = str(Path(cwd).expanduser().resolve()).lower() if cwd else ""
    cwd_matches = bool(cwd_real and (cwd_real.startswith(project_real) or project_real.startswith(cwd_real)))
    add_check("Engineer session cwd matches project path", cwd_matches, f"session cwd={cwd}", "WARN" if allow_cwd_mismatch else "FAIL")
    evidence_mentions = (meta["session_id"] and meta["session_id"] in evidence) or (meta["filename"] in evidence)
    add_check("Session evidence references this engineer JSONL", evidence_mentions, f"09_session_evidence.md must cite {meta['session_id']} or {meta['filename']}")

print()
print("Engineer session:")
if not meta:
    print("(unreadable)")
else:
    print(f"{meta['mb']:.2f} MB\t{meta['timestamp']}\t{meta['session_id']}\t{meta['cwd']}\t{meta['path']}")

print()
print("Retrospective prompts still required when the gate fails:")
for prompt in [
    "What did the project believe at the beginning that later turned out wrong?",
    "Which failures were expensive enough that a new Codex must not repeat them?",
    "Which current design choices are consequences of earlier failed attempts?",
    "What exact commands and files prove the current runbook?",
    "If rebuilding from zero, what order avoids the historical traps?",
    "What are the 3-7 most important things this project taught us?",
    "Which of those lessons must be promoted outside 01_Projects, and where?",
]:
    print(f"- {prompt}")

print()
if failures:
    print(f"FAILED mature retrospective gate: {len(failures)} blocking checks failed.")
    raise SystemExit(1)

print(f"PASSED mature retrospective gate. Warnings: {len(warnings)}.")
PY
