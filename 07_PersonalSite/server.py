from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = Path(__file__).resolve().parent
WEB_ROOT = APP_ROOT / "web"
DATA_FILE = APP_ROOT / "data" / "showcase.json"
RAW_MEDIA_ROOT = ROOT / "记得整理"
MARGINALIA_RUNTIME = ROOT / ".marginalia-yusu"
MARGINALIA_DIST = APP_ROOT / "marginalia-dist"
MARGINALIA_BACKEND = APP_ROOT / "marginalia-backend"

SEARCH_ROOTS = [
    ROOT / "01_Projects",
    ROOT / "02_GlobalMemory",
    ROOT / "03_CrossProject",
    ROOT / "04_Runbooks",
    ROOT / "06_Maps",
    ROOT / "07_PersonalSite",
    ROOT / "INDEX.md",
    ROOT / "README.md",
]


def _load_env_file(path: Path) -> None:
    if not path.is_file():
        return
    for raw_line in path.read_text(encoding="utf-8-sig", errors="replace").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip("\"'")
        if key:
            os.environ.setdefault(key, value)


# Marginalia reads configuration while its modules are imported. Load the
# ignored repo-local runtime first, then enable its worker in this one process.
_load_env_file(MARGINALIA_RUNTIME / ".env")
os.environ.setdefault("MARGINALIA_HOME", str(MARGINALIA_RUNTIME / "data"))
os.environ["WORKER_ENABLED"] = os.environ.get("YUSU_MARGINALIA_WORKER", "true")
os.environ.setdefault("MARGINALIA_DESKTOP", "1")

if MARGINALIA_BACKEND.is_dir():
    sys.path.insert(0, str(MARGINALIA_BACKEND))

from fastapi import HTTPException, Query  # noqa: E402
from fastapi.responses import FileResponse, RedirectResponse  # noqa: E402
from fastapi.staticfiles import StaticFiles  # noqa: E402
from marginalia.config import get_settings, resolve_profile  # noqa: E402
from marginalia.main import app  # noqa: E402


def _is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def _iter_markdown_files() -> list[Path]:
    files: list[Path] = []
    for root in SEARCH_ROOTS:
        if root.is_file() and root.suffix.lower() == ".md":
            files.append(root)
        elif root.is_dir():
            files.extend(path for path in root.rglob("*.md") if path.is_file())
    return sorted(files)


def _resolve_markdown_doc(rel_path: str) -> Path | None:
    clean = unquote(rel_path).replace("\\", "/").strip()
    if not clean or clean.startswith("/") or "\x00" in clean:
        return None
    if any(part == ".." for part in clean.split("/")):
        return None

    target = (ROOT / clean).resolve()
    if target.suffix.lower() != ".md":
        return None
    allowed = {path.resolve() for path in _iter_markdown_files()}
    return target if target in allowed else None


def _first_heading(text: str, fallback: str) -> str:
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("#"):
            return line.lstrip("#").strip() or fallback
    return fallback


def _snippet(lines: list[str], line_index: int, width: int = 1) -> str:
    start = max(0, line_index - width)
    end = min(len(lines), line_index + width + 1)
    joined = " ".join(part.strip() for part in lines[start:end] if part.strip())
    return joined[:420]


def search_markdown(query: str, limit: int = 14) -> list[dict]:
    terms = [term.lower() for term in re.split(r"\s+", query.strip()) if term.strip()]
    if not terms:
        return []

    results: list[dict] = []
    for path in _iter_markdown_files():
        try:
            text = _read_text(path)
        except OSError:
            continue
        lowered = text.lower()
        matched_terms = [term for term in terms if term in lowered]
        if not matched_terms:
            continue

        lines = text.splitlines()
        hit_index = next(
            (
                index
                for index, line in enumerate(lines)
                if any(term in line.lower() for term in matched_terms)
            ),
            0,
        )
        rel = path.relative_to(ROOT).as_posix()
        raw_score = sum(lowered.count(term) for term in matched_terms)
        results.append(
            {
                "title": _first_heading(text, path.stem),
                "path": rel,
                "line": hit_index + 1,
                "snippet": _snippet(lines, hit_index),
                "score": len(matched_terms) * 1000 + raw_score,
            }
        )

    results.sort(key=lambda item: (-item["score"], item["path"]))
    return results[:limit]


@app.get("/api/showcase", tags=["yusu"])
async def showcase() -> dict:
    return json.loads(DATA_FILE.read_text(encoding="utf-8"))


@app.get("/api/status", tags=["yusu"])
async def site_status() -> dict:
    projects_root = ROOT / "01_Projects"
    return {
        "vaultRoot": str(ROOT),
        "markdownFiles": len(_iter_markdown_files()),
        "projectDirectories": len([path for path in projects_root.iterdir() if path.is_dir()]),
        "rawMediaFiles": len([path for path in RAW_MEDIA_ROOT.iterdir() if path.is_file()])
        if RAW_MEDIA_ROOT.exists()
        else 0,
        "searchMode": "live markdown scan",
        "marginaliaMode": "same-process FastAPI + source-integrated React UI/backend",
    }


@app.get("/api/marginalia/status", tags=["yusu"])
async def marginalia_status() -> dict:
    settings = get_settings()
    chat = resolve_profile(settings, "chat")
    return {
        "online": True,
        "apiBase": "/v1",
        "uiBase": "/marginalia",
        "integration": "same-process",
        "backendSource": str(MARGINALIA_BACKEND),
        "semanticRecall": settings.semantic_recall_enabled,
        "semanticConfigured": bool(
            settings.semantic_recall_enabled and settings.embedding_api_key
        ),
        "embeddingModel": settings.embedding_model,
        "llmProvider": chat.provider,
        "llmModel": chat.model,
        "llmBaseUrl": chat.base_url,
        "llmKeySet": bool(chat.api_key),
        "workerEnabled": settings.worker_enabled,
    }


@app.get("/api/search", tags=["yusu"])
async def search(q: str = Query(default="")) -> dict:
    return {"query": q, "results": search_markdown(q)}


@app.get("/api/doc", tags=["yusu"])
async def document(path: str = Query(default="")) -> dict:
    target = _resolve_markdown_doc(path)
    if target is None:
        raise HTTPException(status_code=404, detail="markdown document not found")
    text = _read_text(target)
    return {
        "title": _first_heading(text, target.stem),
        "path": target.relative_to(ROOT).as_posix(),
        "content": text,
        "lines": len(text.splitlines()),
    }


@app.get("/media/raw/{filename:path}", include_in_schema=False)
async def raw_media(filename: str) -> FileResponse:
    target = (RAW_MEDIA_ROOT / unquote(filename)).resolve()
    if not _is_relative_to(target, RAW_MEDIA_ROOT.resolve()) or not target.is_file():
        raise HTTPException(status_code=404, detail="media file not found")
    return FileResponse(target, headers={"Cache-Control": "public, max-age=3600"})


@app.get("/marginalia", include_in_schema=False)
async def marginalia_root() -> RedirectResponse:
    return RedirectResponse(url="/marginalia/chat", status_code=307)


@app.get("/marginalia/{asset_path:path}", include_in_schema=False)
async def marginalia_ui(asset_path: str) -> FileResponse:
    clean = unquote(asset_path).replace("\\", "/").lstrip("/")
    target = (MARGINALIA_DIST / clean).resolve()
    if _is_relative_to(target, MARGINALIA_DIST.resolve()) and target.is_file():
        return FileResponse(target)
    index = MARGINALIA_DIST / "index.html"
    if not index.is_file():
        raise HTTPException(
            status_code=503,
            detail="Marginalia UI is not built. Run tools/build-yusu-integrated-marginalia-ui.ps1",
        )
    return FileResponse(index, headers={"Cache-Control": "no-store, max-age=0"})


@app.get("/styles.css", include_in_schema=False)
async def site_styles() -> FileResponse:
    return FileResponse(WEB_ROOT / "styles.css", media_type="text/css")


@app.get("/app.js", include_in_schema=False)
async def site_javascript() -> FileResponse:
    return FileResponse(WEB_ROOT / "app.js", media_type="text/javascript")


@app.get("/", include_in_schema=False)
async def site_root() -> FileResponse:
    return FileResponse(
        WEB_ROOT / "index.html",
        headers={"Cache-Control": "no-store, max-age=0"},
    )


app.mount("/assets", StaticFiles(directory=WEB_ROOT / "assets"), name="yusu-assets")


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the integrated YUSU + Marginalia site.")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8787)
    args = parser.parse_args()

    import uvicorn

    uvicorn.run(app, host=args.host, port=args.port, log_level="info")


if __name__ == "__main__":
    main()
