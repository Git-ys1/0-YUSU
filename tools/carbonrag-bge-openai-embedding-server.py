from __future__ import annotations

import argparse
import os
import sys
import time
from pathlib import Path
from typing import Any

from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel


DEFAULT_MODEL = "BAAI/bge-m3"
DEFAULT_DIMENSIONS = 1024
DEFAULT_API_KEY = "local-bge-key"

_CONFIGURED = False
_MODEL_LOADED = False
_LAST_EMBED_MS: int | None = None

app = FastAPI(title="CarbonRag BGE-M3 OpenAI-Compatible Embedding Shim")


class EmbeddingRequest(BaseModel):
    input: str | list[str]
    model: str = DEFAULT_MODEL
    dimensions: int | None = None
    encoding_format: str | None = "float"


def configure_runtime(
    *,
    carbonrag_root: str | None = None,
    model_cache_dir: str | None = None,
) -> None:
    global _CONFIGURED
    if _CONFIGURED:
        return

    root = Path(
        carbonrag_root
        or os.environ.get("CARBONRAG_ROOT")
        or r"F:\Project\CarbonRag"
    ).expanduser()
    backend = root / "backend"
    if not backend.exists():
        raise RuntimeError(f"CarbonRag backend not found: {backend}")

    if str(backend) not in sys.path:
        sys.path.insert(0, str(backend))

    cache_dir = Path(
        model_cache_dir
        or os.environ.get("RAG_MODEL_CACHE_DIR")
        or root / "data" / "outputs" / "models"
    )

    os.environ.setdefault("PYTHONPATH", str(backend))
    os.environ.setdefault("RAG_EMBEDDING_PROVIDER", "bge_m3")
    os.environ.setdefault("RAG_EMBEDDING_MODEL", DEFAULT_MODEL)
    os.environ.setdefault("RAG_EMBEDDING_DEVICE", "cpu")
    os.environ.setdefault("RAG_MODEL_CACHE_DIR", str(cache_dir))
    os.environ.setdefault("RAG_MODEL_AUTO_DOWNLOAD", "false")
    os.environ.setdefault("RAG_HF_ENDPOINT", "https://hf-mirror.com")
    os.environ.setdefault("HF_ENDPOINT", os.environ["RAG_HF_ENDPOINT"])

    _CONFIGURED = True


def _model_dir() -> Path:
    cache_dir = Path(os.environ.get("RAG_MODEL_CACHE_DIR", ""))
    return cache_dir / "BAAI" / "bge-m3"


def _expected_api_key() -> str:
    return os.environ.get("BGE_EMBEDDING_API_KEY", DEFAULT_API_KEY)


def _check_auth(authorization: str | None) -> None:
    expected = _expected_api_key()
    if not expected or expected.lower() == "none":
        return
    if authorization != f"Bearer {expected}":
        raise HTTPException(status_code=401, detail="invalid local embedding api key")


def _normalize_inputs(value: str | list[str]) -> list[str]:
    if isinstance(value, str):
        return [value]
    if not isinstance(value, list):
        raise HTTPException(status_code=400, detail="input must be a string or list of strings")
    out: list[str] = []
    for item in value:
        if not isinstance(item, str):
            raise HTTPException(status_code=400, detail="only string inputs are supported")
        out.append(item)
    return out


def _validate_request(payload: EmbeddingRequest) -> None:
    accepted_models = {DEFAULT_MODEL, "bge-m3"}
    if payload.model not in accepted_models:
        raise HTTPException(
            status_code=400,
            detail=f"unsupported model {payload.model!r}; use {DEFAULT_MODEL}",
        )
    if payload.dimensions and int(payload.dimensions) != DEFAULT_DIMENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"BGE-M3 dimensions are fixed at {DEFAULT_DIMENSIONS}",
        )


@app.get("/health")
def health() -> dict[str, Any]:
    configure_runtime()
    return {
        "status": "ok",
        "provider": "carbonrag-bge-m3",
        "model": DEFAULT_MODEL,
        "dimensions": DEFAULT_DIMENSIONS,
        "model_dir": str(_model_dir()),
        "model_dir_exists": _model_dir().exists(),
        "model_loaded": _MODEL_LOADED,
        "last_embed_ms": _LAST_EMBED_MS,
    }


@app.get("/v1/models")
def list_models(authorization: str | None = Header(default=None)) -> dict[str, Any]:
    _check_auth(authorization)
    return {
        "object": "list",
        "data": [
            {
                "id": DEFAULT_MODEL,
                "object": "model",
                "owned_by": "local-carbonrag",
            }
        ],
    }


@app.post("/v1/embeddings")
def create_embeddings(
    payload: EmbeddingRequest,
    authorization: str | None = Header(default=None),
) -> dict[str, Any]:
    global _MODEL_LOADED, _LAST_EMBED_MS
    _check_auth(authorization)
    _validate_request(payload)
    configure_runtime()
    texts = _normalize_inputs(payload.input)
    started = time.perf_counter()
    try:
        from app.rag.embeddings import embed_documents

        result = embed_documents(texts)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"local BGE-M3 embedding failed: {exc}") from exc
    _MODEL_LOADED = True
    _LAST_EMBED_MS = int((time.perf_counter() - started) * 1000)

    vectors = result.dense
    if len(vectors) != len(texts):
        raise HTTPException(
            status_code=500,
            detail=f"embedding count mismatch: expected {len(texts)}, got {len(vectors)}",
        )
    for vector in vectors:
        if len(vector) != DEFAULT_DIMENSIONS:
            raise HTTPException(
                status_code=500,
                detail=f"unexpected BGE-M3 vector dimension: {len(vector)}",
            )

    return {
        "object": "list",
        "data": [
            {
                "object": "embedding",
                "index": index,
                "embedding": vector,
            }
            for index, vector in enumerate(vectors)
        ],
        "model": DEFAULT_MODEL,
        "usage": {
            "prompt_tokens": 0,
            "total_tokens": 0,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Serve CarbonRag BGE-M3 through an OpenAI-compatible embeddings endpoint."
    )
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8011)
    parser.add_argument("--carbonrag-root", default=os.environ.get("CARBONRAG_ROOT"))
    parser.add_argument("--model-cache-dir", default=os.environ.get("RAG_MODEL_CACHE_DIR"))
    args = parser.parse_args()

    configure_runtime(
        carbonrag_root=args.carbonrag_root,
        model_cache_dir=args.model_cache_dir,
    )

    import uvicorn

    uvicorn.run(app, host=args.host, port=args.port)


if __name__ == "__main__":
    main()
