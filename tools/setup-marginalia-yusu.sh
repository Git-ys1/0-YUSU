#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tool_root="$root/.tools"
venv_dir="$tool_root/marginalia-venv"
runtime_dir="$root/.marginalia-yusu"
submodule_dir="$root/vendor/marginalia"
python_bin="${YUSU_MARGINALIA_PYTHON:-python3.11}"
skip_install=0
sync_projection=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --python)
      python_bin="$2"
      shift 2
      ;;
    --skip-install)
      skip_install=1
      shift
      ;;
    --sync-projection)
      sync_projection=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

mkdir -p "$tool_root/tmp" "$tool_root/pip-cache" "$runtime_dir/home"
export TMPDIR="$tool_root/tmp"
export PIP_CACHE_DIR="$tool_root/pip-cache"
export HOME="$runtime_dir/home"

"$python_bin" - <<'PY'
import sys
if sys.version_info < (3, 11):
    raise SystemExit("Python 3.11+ is required")
print(sys.executable)
print(sys.version)
PY

if [[ ! -f "$submodule_dir/pyproject.toml" ]]; then
  git -C "$root" submodule update --init -- vendor/marginalia
fi

if [[ ! -x "$venv_dir/bin/python" ]]; then
  "$python_bin" -m venv "$venv_dir"
fi

"$venv_dir/bin/python" --version

if [[ "$skip_install" -eq 0 ]]; then
  "$venv_dir/bin/python" -m pip install -e "$submodule_dir"
fi

"$venv_dir/bin/marginalia" init "$runtime_dir"

env_file="$runtime_dir/.env"
home_value="$runtime_dir/data"
"$venv_dir/bin/python" - "$env_file" "$home_value" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
home = sys.argv[2]
updates = {
    "MARGINALIA_HOME": home,
    "WORKER_ENABLED": "false",
    "STORAGE_BACKEND": "mirror",
}
text = path.read_text(encoding="utf-8") if path.exists() else ""
lines = text.splitlines()
seen = set()
out = []
for line in lines:
    key = line.split("=", 1)[0] if "=" in line else None
    if key in updates:
        out.append(f"{key}={updates[key]}")
        seen.add(key)
    else:
        out.append(line)
for key, value in updates.items():
    if key not in seen:
        out.append(f"{key}={value}")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY

if [[ "$sync_projection" -eq 1 ]]; then
  "$root/tools/sync-yusu-kb-to-marginalia.sh"
fi

echo "Marginalia runtime: $runtime_dir"
echo "Marginalia venv: $venv_dir"
echo "Next: edit $env_file and set LLM_DEFAULT_API_KEY before /ingest --all."
