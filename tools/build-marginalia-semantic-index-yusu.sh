#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_ROOT="$ROOT_DIR/.tools"
RUNTIME_DIR="$ROOT_DIR/.marginalia-yusu"
PYTHON_EXE="$TOOL_ROOT/marginalia-venv/bin/python"

BATCH_SIZE="${BATCH_SIZE:-4}"
CONCURRENCY="${CONCURRENCY:-1}"
PROGRESS_EVERY="${PROGRESS_EVERY:-25}"
RESUME_ARG="${RESUME_ARG:-}"

if [[ ! -x "$PYTHON_EXE" ]]; then
  echo "Marginalia is not installed. Run tools/setup-marginalia-yusu.sh first." >&2
  exit 1
fi

mkdir -p "$TOOL_ROOT/tmp" "$RUNTIME_DIR/home"
export TEMP="$TOOL_ROOT/tmp"
export TMP="$TEMP"
export PIP_CACHE_DIR="$TOOL_ROOT/pip-cache"
export HOME="$RUNTIME_DIR/home"
export MARGINALIA_HOME="$RUNTIME_DIR/data"

if [[ "${USE_LOCAL_BGE:-false}" == "true" ]]; then
  export EMBEDDING_PROVIDER="openai-compatible"
  export EMBEDDING_BASE_URL="${EMBEDDING_BASE_URL:-http://127.0.0.1:8011/v1}"
  export EMBEDDING_API_KEY="${EMBEDDING_API_KEY:-local-bge-key}"
  export EMBEDDING_MODEL="BAAI/bge-m3"
  export EMBEDDING_DIMENSIONS="1024"
  export EMBEDDING_BATCH_SIZE="$BATCH_SIZE"
  export SEMANTIC_RECALL_ENABLED="true"
fi

cd "$RUNTIME_DIR"
"$PYTHON_EXE" - \
  --batch-size "$BATCH_SIZE" \
  --concurrency "$CONCURRENCY" \
  --progress-every "$PROGRESS_EVERY" \
  $RESUME_ARG <<'PY'
from __future__ import annotations

import argparse
import asyncio

from marginalia.db.bootstrap import bootstrap_schema
from marginalia.db.engine import dispose_engine
from marginalia.db.session import session_scope
from marginalia.semantic.index import DEFAULT_INDEX_NAME, build_semantic_index


async def run(args: argparse.Namespace) -> None:
    await bootstrap_schema()
    try:
        async with session_scope() as session:
            result = await build_semantic_index(
                session,
                index_name=args.index_name,
                batch_size=args.batch_size,
                concurrency=args.concurrency,
                resume=args.resume,
                progress_every=args.progress_every,
            )
        print("semantic index built")
        print(f"  index_dir: {result.index_dir}")
        print(f"  entries: {result.entries_indexed}")
        print(f"  model: {result.model}")
        print(f"  dimensions: {result.dimensions}")
        print(f"  elapsed_ms: {result.elapsed_ms}")
        print(f"  total_tokens: {result.total_tokens}")
    finally:
        await dispose_engine()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--index-name", default=DEFAULT_INDEX_NAME)
    parser.add_argument("--batch-size", type=int, default=4)
    parser.add_argument("--concurrency", type=int, default=1)
    parser.add_argument("--progress-every", type=int, default=25)
    parser.add_argument("--resume", action="store_true")
    asyncio.run(run(parser.parse_args()))


if __name__ == "__main__":
    main()
PY
