# Runbook

## Start Locally

Windows:

```powershell
cd F:\AcademicHub\0#YUSU
python .\07_PersonalSite\server.py --host 127.0.0.1 --port 8787
```

Bundled Python fallback:

```powershell
& 'C:\Users\yusu\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' .\07_PersonalSite\server.py --host 127.0.0.1 --port 8787
```

Ubuntu/Linux:

```bash
cd "$YUSU_KB_ROOT"
python3 07_PersonalSite/server.py --host 127.0.0.1 --port 8787
```

Open:

```text
http://127.0.0.1:8787/
```

## Validate

```powershell
python -m py_compile .\07_PersonalSite\server.py
Invoke-RestMethod http://127.0.0.1:8787/api/status
Invoke-RestMethod "http://127.0.0.1:8787/api/search?q=CleanScout"
Invoke-RestMethod "http://127.0.0.1:8787/api/doc?path=01_Projects/cleanscout-rover/README.md"
```

## Update Content

1. Add or verify raw files under `记得整理/`.
2. Update `07_PersonalSite/notes/materials-inventory.md`.
3. Update `07_PersonalSite/data/showcase.json`.
4. Start the server and visually inspect the page.
5. Update this project memory if the site behavior or structure changes.

## Retrieval Note

The site search uses live Markdown scanning. It can find newly written vault files before Marginalia semantic indexing catches up.
