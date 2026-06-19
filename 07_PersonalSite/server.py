from __future__ import annotations

import argparse
import json
import mimetypes
import os
import re
import urllib.error
import urllib.request
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse


ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = Path(__file__).resolve().parent
WEB_ROOT = APP_ROOT / "web"
DATA_FILE = APP_ROOT / "data" / "showcase.json"
RAW_MEDIA_ROOT = ROOT / "记得整理"
MARGINALIA_API_BASE = os.environ.get("YUSU_MARGINALIA_API", "http://127.0.0.1:8000/v1").rstrip("/")
MARGINALIA_UI_BASE = os.environ.get("YUSU_MARGINALIA_UI", "http://127.0.0.1:5173").rstrip("/")
HTTP_TIMEOUT_SECONDS = 12

SEARCH_ROOTS = [
    ROOT / "01_Projects",
    ROOT / "02_GlobalMemory",
    ROOT / "03_CrossProject",
    ROOT / "04_Runbooks",
    ROOT / "06_Maps",
    ROOT / "07_PersonalSite",
    ROOT / "INDEX.md",
    ROOT / "README.md"
]


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
            files.extend(p for p in root.rglob("*.md") if p.is_file())
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
    if target not in allowed:
        return None
    return target


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
    query = query.strip()
    if not query:
        return []

    terms = [term.lower() for term in re.split(r"\s+", query) if term.strip()]
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
        hit_index = 0
        for index, line in enumerate(lines):
            line_l = line.lower()
            if any(term in line_l for term in matched_terms):
                hit_index = index
                break

        rel = path.relative_to(ROOT).as_posix()
        raw_score = sum(lowered.count(term) for term in matched_terms)
        results.append({
            "title": _first_heading(text, path.stem),
            "path": rel,
            "line": hit_index + 1,
            "snippet": _snippet(lines, hit_index),
            "score": len(matched_terms) * 1000 + raw_score
        })

    results.sort(key=lambda item: (-item["score"], item["path"]))
    return results[:limit]


def _marginalia_json(path: str, *, method: str = "GET", payload: dict | None = None) -> dict:
    data = None
    headers = {"Accept": "application/json"}
    if payload is not None:
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(
        f"{MARGINALIA_API_BASE}{path}",
        data=data,
        method=method,
        headers=headers,
    )
    with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT_SECONDS) as response:
        raw = response.read()
    return json.loads(raw.decode("utf-8")) if raw else {}


class PersonalSiteHandler(SimpleHTTPRequestHandler):
    server_version = "YusuPersonalSite/0.3"

    def translate_path(self, path: str) -> str:
        parsed = urlparse(path)
        clean_path = unquote(parsed.path)
        if clean_path in ("", "/"):
            return str(WEB_ROOT / "index.html")
        target = (WEB_ROOT / clean_path.lstrip("/")).resolve()
        if not _is_relative_to(target, WEB_ROOT):
            return str(WEB_ROOT / "index.html")
        return str(target)

    def end_headers(self) -> None:
        path = urlparse(self.path).path
        if not path.startswith("/api/") and not path.startswith("/media/raw/"):
            self.send_header("Cache-Control", "no-store, max-age=0")
        super().end_headers()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/api/showcase":
            self._send_json(json.loads(DATA_FILE.read_text(encoding="utf-8")))
            return

        if path == "/api/status":
            self._send_json({
                "vaultRoot": str(ROOT),
                "markdownFiles": len(_iter_markdown_files()),
                "projectDirectories": len([p for p in (ROOT / "01_Projects").iterdir() if p.is_dir()]),
                "rawMediaFiles": len([p for p in RAW_MEDIA_ROOT.iterdir() if p.is_file()]) if RAW_MEDIA_ROOT.exists() else 0,
                "searchMode": "live markdown scan",
                "semanticIndex": "Marginalia is embedded through /api/marginalia/* when its local API is running"
            })
            return

        if path == "/api/marginalia/status":
            self._send_json(self._marginalia_status())
            return

        if path == "/api/search":
            params = parse_qs(parsed.query)
            query = params.get("q", [""])[0]
            self._send_json({"query": query, "results": search_markdown(query)})
            return

        if path == "/api/doc":
            params = parse_qs(parsed.query)
            rel_path = params.get("path", [""])[0]
            target = _resolve_markdown_doc(rel_path)
            if target is None:
                self.send_error(HTTPStatus.NOT_FOUND, "markdown document not found")
                return
            text = _read_text(target)
            rel = target.relative_to(ROOT).as_posix()
            self._send_json({
                "title": _first_heading(text, target.stem),
                "path": rel,
                "content": text,
                "lines": len(text.splitlines()),
            })
            return

        if path.startswith("/media/raw/"):
            self._send_raw_media(path.removeprefix("/media/raw/"))
            return

        super().do_GET()

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/api/agent/session":
            try:
                body = self._read_json_body()
                init = str(body.get("initiatingUserMessage", "") or "")
                session = _marginalia_json(
                    "/sessions",
                    method="POST",
                    payload={"initiating_user_message": init},
                )
                self._send_json(session)
            except Exception as exc:
                self._send_json({"error": str(exc), "online": False}, status=HTTPStatus.BAD_GATEWAY)
            return

        if path == "/api/agent/chat":
            try:
                body = self._read_json_body(max_bytes=96 * 1024)
                session_id = str(body.get("sessionId", "") or "").strip()
                query = str(body.get("query", "") or "").strip()
                mode = str(body.get("mode", "deep") or "deep").strip()
                if mode not in {"deep", "quick"}:
                    mode = "deep"
                if not session_id or not query:
                    self.send_error(HTTPStatus.BAD_REQUEST, "sessionId and query are required")
                    return
                self._proxy_agent_chat(session_id=session_id, query=query, mode=mode)
            except Exception as exc:
                self._send_sse_error(str(exc))
            return

        self.send_error(HTTPStatus.NOT_FOUND, "api endpoint not found")

    def _read_json_body(self, max_bytes: int = 64 * 1024) -> dict:
        try:
            length = int(self.headers.get("Content-Length", "0") or "0")
        except ValueError as exc:
            raise ValueError("invalid Content-Length") from exc
        if length > max_bytes:
            raise ValueError("request body too large")
        if length <= 0:
            return {}
        raw = self.rfile.read(length)
        return json.loads(raw.decode("utf-8"))

    def _send_json(self, payload: dict | list, *, status: HTTPStatus = HTTPStatus.OK) -> None:
        data = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def _marginalia_status(self) -> dict:
        try:
            server = _marginalia_json("/settings/server")
            llm = _marginalia_json("/settings/llm")
            defaults = llm.get("defaults", {})
            return {
                "online": True,
                "apiBase": MARGINALIA_API_BASE,
                "uiBase": MARGINALIA_UI_BASE,
                "semanticRecall": bool(server.get("semantic_recall_enabled")),
                "semanticConfigured": bool(server.get("semantic_recall_configured")),
                "embeddingModel": server.get("embedding_model"),
                "llmProvider": defaults.get("provider"),
                "llmModel": defaults.get("model"),
                "llmBaseUrl": defaults.get("base_url"),
                "llmKeySet": bool(defaults.get("api_key_set")),
            }
        except Exception as exc:
            return {
                "online": False,
                "apiBase": MARGINALIA_API_BASE,
                "uiBase": MARGINALIA_UI_BASE,
                "error": str(exc),
            }

    def _proxy_agent_chat(self, *, session_id: str, query: str, mode: str) -> None:
        payload = json.dumps({"query": query, "mode": mode}, ensure_ascii=False).encode("utf-8")
        request = urllib.request.Request(
            f"{MARGINALIA_API_BASE}/chat/{session_id}",
            data=payload,
            method="POST",
            headers={
                "Accept": "text/event-stream",
                "Content-Type": "application/json",
            },
        )
        try:
            upstream = urllib.request.urlopen(request, timeout=300)
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", errors="replace")
            self._send_sse_error(f"Marginalia HTTP {exc.code}: {detail}")
            return

        with upstream:
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "text/event-stream; charset=utf-8")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("X-Accel-Buffering", "no")
            self.end_headers()
            while True:
                chunk = upstream.read(4096)
                if not chunk:
                    break
                self.wfile.write(chunk)
                self.wfile.flush()

    def _send_sse_error(self, message: str) -> None:
        data = f"event: error\ndata: {message}\n\n".encode("utf-8", errors="replace")
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "text/event-stream; charset=utf-8")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_raw_media(self, encoded_name: str) -> None:
        name = unquote(encoded_name)
        target = (RAW_MEDIA_ROOT / name).resolve()
        raw_root = RAW_MEDIA_ROOT.resolve()
        if not _is_relative_to(target, raw_root) or not target.is_file():
            self.send_error(HTTPStatus.NOT_FOUND, "media file not found")
            return

        content_type = mimetypes.guess_type(str(target))[0] or "application/octet-stream"
        data = target.read_bytes()
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "public, max-age=3600")
        self.end_headers()
        self.wfile.write(data)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the local YUSU personal site.")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8787)
    args = parser.parse_args()

    address = (args.host, args.port)
    httpd = ThreadingHTTPServer(address, PersonalSiteHandler)
    print(f"YUSU personal site: http://{args.host}:{args.port}/")
    print(f"Vault root: {ROOT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        httpd.server_close()


if __name__ == "__main__":
    main()
