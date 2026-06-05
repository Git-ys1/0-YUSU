from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
import time
from pathlib import Path
from typing import Any
from uuid import uuid4

from fastapi import FastAPI, Header, HTTPException, Request
from openai import AsyncOpenAI


DEFAULT_MODEL = "gpt-5.4"
DEFAULT_LOCAL_API_KEY = "local-llm-key"
DEFAULT_UPSTREAM_BASE_URL = "https://cli-proxy-api-latest-tqjw.onrender.com/v1"
DEFAULT_CODEX_PROXY_CONFIG = r"C:\Users\yusu\.codex\myself-api\config-self.toml"
ALLOWED_UPSTREAM_CHAT_KEYS = {
    "audio",
    "frequency_penalty",
    "function_call",
    "functions",
    "logit_bias",
    "logprobs",
    "max_completion_tokens",
    "max_tokens",
    "messages",
    "metadata",
    "modalities",
    "model",
    "n",
    "parallel_tool_calls",
    "prediction",
    "presence_penalty",
    "reasoning_effort",
    "response_format",
    "seed",
    "service_tier",
    "stop",
    "stream",
    "stream_options",
    "temperature",
    "tool_choice",
    "tools",
    "top_logprobs",
    "top_p",
    "user",
}

app = FastAPI(title="Codex Proxy Streaming Chat-Completions Shim")


def _read_simple_toml_value(path: Path, key: str) -> str | None:
    if not path.exists():
        return None
    pattern = re.compile(rf"^\s*{re.escape(key)}\s*=\s*(.+?)\s*$")
    for line in path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if not match:
            continue
        raw = match.group(1).strip()
        if raw.startswith('"') and raw.endswith('"'):
            return raw[1:-1]
        return raw
    return None


def _upstream_base_url() -> str:
    return (
        os.environ.get("YUSU_LLM_UPSTREAM_BASE_URL")
        or _read_simple_toml_value(Path(DEFAULT_CODEX_PROXY_CONFIG), "base_url")
        or DEFAULT_UPSTREAM_BASE_URL
    )


def _upstream_api_key() -> str:
    key = os.environ.get("YUSU_LLM_UPSTREAM_API_KEY")
    if key:
        return key
    parsed = _read_simple_toml_value(
        Path(DEFAULT_CODEX_PROXY_CONFIG),
        "experimental_bearer_token",
    )
    if parsed:
        return parsed
    raise RuntimeError(
        "upstream API key is not configured; set YUSU_LLM_UPSTREAM_API_KEY"
    )


def _local_api_key() -> str:
    return os.environ.get("YUSU_LLM_SHIM_API_KEY", DEFAULT_LOCAL_API_KEY)


def _check_auth(authorization: str | None) -> None:
    expected = _local_api_key()
    if not expected or expected.lower() == "none":
        return
    if authorization != f"Bearer {expected}":
        raise HTTPException(status_code=401, detail="invalid local llm shim api key")


@app.get("/health")
def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "provider": "codex-proxy-streaming-chat-shim",
        "upstream_base_url": _upstream_base_url(),
        "default_model": os.environ.get("YUSU_LLM_MODEL", DEFAULT_MODEL),
        "local_auth_enabled": bool(_local_api_key()),
    }


@app.get("/v1/models")
def list_models(authorization: str | None = Header(default=None)) -> dict[str, Any]:
    _check_auth(authorization)
    model = os.environ.get("YUSU_LLM_MODEL", DEFAULT_MODEL)
    return {
        "object": "list",
        "data": [
            {
                "id": model,
                "object": "model",
                "owned_by": "yusu-codex-proxy",
            }
        ],
    }


@app.post("/v1/chat/completions")
async def chat_completions(
    request: Request,
    authorization: str | None = Header(default=None),
) -> dict[str, Any]:
    _check_auth(authorization)
    payload = await request.json()
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail="request body must be a JSON object")

    model = str(payload.get("model") or os.environ.get("YUSU_LLM_MODEL") or DEFAULT_MODEL)
    upstream_payload = {
        key: value
        for key, value in payload.items()
        if key in ALLOWED_UPSTREAM_CHAT_KEYS and value is not None
    }
    upstream_payload["model"] = model
    upstream_payload["stream"] = True
    upstream_payload.setdefault("max_completion_tokens", 2048)

    client = AsyncOpenAI(
        api_key=_upstream_api_key(),
        base_url=_upstream_base_url(),
    )

    max_attempts = max(1, int(os.environ.get("YUSU_LLM_UPSTREAM_RETRIES", "3")))
    last_error: Exception | None = None
    for attempt in range(1, max_attempts + 1):
        try:
            return await _stream_chat_once(client, upstream_payload, model)
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            if attempt >= max_attempts:
                break
            await asyncio.sleep(min(8.0, 1.5 * attempt))
    raise HTTPException(status_code=502, detail=f"upstream streaming chat failed: {last_error}") from last_error


async def _stream_chat_once(
    client: AsyncOpenAI,
    upstream_payload: dict[str, Any],
    model: str,
) -> dict[str, Any]:
    content_parts: list[str] = []
    tool_calls_by_index: dict[int, dict[str, Any]] = {}
    finish_reason: str | None = None
    usage: dict[str, Any] | None = None

    try:
        stream = await client.chat.completions.create(**upstream_payload)
        async for chunk in stream:
            if getattr(chunk, "usage", None) is not None:
                try:
                    usage = chunk.usage.model_dump(mode="json")
                except Exception:  # noqa: BLE001
                    usage = None
            if not getattr(chunk, "choices", None):
                continue
            choice = chunk.choices[0]
            finish_reason = choice.finish_reason or finish_reason
            delta = choice.delta
            piece = getattr(delta, "content", None)
            if piece:
                content_parts.append(piece)
            for tool_call in getattr(delta, "tool_calls", None) or []:
                index = int(getattr(tool_call, "index", 0) or 0)
                current = tool_calls_by_index.setdefault(
                    index,
                    {
                        "id": getattr(tool_call, "id", None) or f"call_{uuid4().hex[:12]}",
                        "type": "function",
                        "function": {"name": "", "arguments": ""},
                    },
                )
                if getattr(tool_call, "id", None):
                    current["id"] = tool_call.id
                if getattr(tool_call, "type", None):
                    current["type"] = tool_call.type
                function = getattr(tool_call, "function", None)
                if function is not None:
                    if getattr(function, "name", None):
                        current["function"]["name"] += function.name
                    if getattr(function, "arguments", None):
                        current["function"]["arguments"] += function.arguments
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(str(exc)) from exc

    content = "".join(content_parts)
    tool_calls = [
        tool_calls_by_index[index]
        for index in sorted(tool_calls_by_index)
    ]
    message: dict[str, Any] = {
        "role": "assistant",
        "content": content or None,
    }
    if tool_calls:
        message["tool_calls"] = tool_calls

    return {
        "id": f"chatcmpl-shim-{uuid4().hex}",
        "object": "chat.completion",
        "created": int(time.time()),
        "model": model,
        "choices": [
            {
                "index": 0,
                "message": message,
                "finish_reason": finish_reason or ("tool_calls" if tool_calls else "stop"),
            }
        ],
        "usage": usage or {
            "prompt_tokens": 0,
            "completion_tokens": 0,
            "total_tokens": 0,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Expose a non-streaming chat-completions endpoint backed by the Codex proxy streaming API."
    )
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8010)
    args = parser.parse_args()

    _upstream_api_key()

    import uvicorn

    uvicorn.run(app, host=args.host, port=args.port)


if __name__ == "__main__":
    main()
