#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_ROOT="$ROOT_DIR/.tools"
HOST_ADDRESS="${HOST_ADDRESS:-127.0.0.1}"
PORT="${PORT:-8010}"
PYTHON_EXE="${PYTHON_EXE:-$TOOL_ROOT/marginalia-venv/bin/python}"

export YUSU_LLM_SHIM_API_KEY="${YUSU_LLM_SHIM_API_KEY:-local-llm-key}"
export YUSU_LLM_MODEL="${YUSU_LLM_MODEL:-gpt-5.4}"

if [[ ! -x "$PYTHON_EXE" ]]; then
  echo "Marginalia Python not found: $PYTHON_EXE" >&2
  exit 1
fi

echo "==> Starting Codex proxy LLM shim"
echo "    endpoint: http://$HOST_ADDRESS:$PORT/v1/chat/completions"
echo "    model:    $YUSU_LLM_MODEL"

exec "$PYTHON_EXE" "$ROOT_DIR/tools/codex-proxy-chat-completions-shim.py" \
  --host "$HOST_ADDRESS" \
  --port "$PORT"
