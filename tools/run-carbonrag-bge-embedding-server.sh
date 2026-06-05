#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CARBONRAG_ROOT="${CARBONRAG_ROOT:-/mnt/f/Project/CarbonRag}"
HOST_ADDRESS="${HOST_ADDRESS:-127.0.0.1}"
PORT="${PORT:-8011}"
BGE_EMBEDDING_API_KEY="${BGE_EMBEDDING_API_KEY:-local-bge-key}"

if [[ -n "${CARBONRAG_PYTHON:-}" ]]; then
  PYTHON_EXE="$CARBONRAG_PYTHON"
elif [[ -x "$CARBONRAG_ROOT/backend/.venv/bin/python" ]]; then
  PYTHON_EXE="$CARBONRAG_ROOT/backend/.venv/bin/python"
elif [[ -x "$CARBONRAG_ROOT/backend/.conda/bin/python" ]]; then
  PYTHON_EXE="$CARBONRAG_ROOT/backend/.conda/bin/python"
else
  PYTHON_EXE="${PYTHON:-python3}"
fi

MODEL_CACHE="$CARBONRAG_ROOT/data/outputs/models"
MODEL_DIR="$MODEL_CACHE/BAAI/bge-m3"
if [[ ! -d "$MODEL_DIR" ]]; then
  echo "BGE-M3 model directory not found: $MODEL_DIR" >&2
  exit 1
fi

export CARBONRAG_ROOT
export RAG_MODEL_CACHE_DIR="$MODEL_CACHE"
export RAG_EMBEDDING_PROVIDER="bge_m3"
export RAG_EMBEDDING_MODEL="BAAI/bge-m3"
export RAG_EMBEDDING_DEVICE="${RAG_EMBEDDING_DEVICE:-cpu}"
export RAG_MODEL_AUTO_DOWNLOAD="false"
export BGE_EMBEDDING_API_KEY

echo "==> Starting CarbonRag BGE-M3 embedding shim"
echo "    endpoint: http://$HOST_ADDRESS:$PORT/v1/embeddings"
echo "    model:    BAAI/bge-m3"
echo "    dims:     1024"
echo "    root:     $CARBONRAG_ROOT"

exec "$PYTHON_EXE" "$ROOT_DIR/tools/carbonrag-bge-openai-embedding-server.py" \
  --host "$HOST_ADDRESS" \
  --port "$PORT" \
  --carbonrag-root "$CARBONRAG_ROOT" \
  --model-cache-dir "$MODEL_CACHE"
