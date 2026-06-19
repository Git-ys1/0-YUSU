from __future__ import annotations

import argparse
import json
import mimetypes
import re
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse


ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = Path(__file__).resolve().parent
WEB_ROOT = APP_ROOT / "web"
DATA_FILE = APP_ROOT / "data" / "showcase.json"
RAW_MEDIA_ROOT = ROOT / "记得整理"

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
                "semanticIndex": "Marginalia is optional and separate"
            })
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

    def _send_json(self, payload: dict | list) -> None:
        data = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "application/json; charset=utf-8")
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
