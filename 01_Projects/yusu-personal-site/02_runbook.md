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

## Start With Marginalia Agent

The personal site can embed both a native Agent console and the full Marginalia UI. Configure the local ignored `.env` first:

```powershell
$env:DEEPSEEK_API_KEY = "<your key>"
.\tools\configure-marginalia-deepseek.ps1
```

Start the supporting services in separate terminals or background processes:

```powershell
.\tools\run-carbonrag-bge-embedding-server.ps1
.\tools\run-marginalia-api-yusu.ps1
.\tools\run-marginalia-ui-yusu.ps1
```

Then start the personal site and open:

```text
http://127.0.0.1:8787/#agent
```

Current default LLM route is DeepSeek official OpenAI-compatible API with `deepseek-v4-flash`. The real key belongs only in `.marginalia-yusu/.env` or `DEEPSEEK_API_KEY`; never commit it.

## Validate

```powershell
python -m py_compile .\07_PersonalSite\server.py
Invoke-RestMethod http://127.0.0.1:8787/api/status
Invoke-RestMethod "http://127.0.0.1:8787/api/search?q=CleanScout"
Invoke-RestMethod "http://127.0.0.1:8787/api/doc?path=01_Projects/cleanscout-rover/README.md"
Invoke-RestMethod http://127.0.0.1:8787/api/marginalia/status
```

Agent end-to-end smoke:

```powershell
$session = Invoke-RestMethod http://127.0.0.1:8787/api/agent/session -Method Post -ContentType application/json -Body '{"initiatingUserMessage":"smoke"}'
$body = @{ sessionId=$session.session_id; query="根据知识库，CleanScout Rover 已有哪些竞赛证据？请只列2条。"; mode="deep" } | ConvertTo-Json
Invoke-WebRequest http://127.0.0.1:8787/api/agent/chat -Method Post -ContentType application/json -Body $body
```

Expected evidence: SSE output contains `event: tool_call`, `event: answer`, and `event: done`.

## Update Content

1. Add or verify raw files under `记得整理/`.
2. Update `07_PersonalSite/notes/materials-inventory.md`.
3. Update `07_PersonalSite/data/showcase.json`.
4. Start the server and visually inspect the page.
5. Update this project memory if the site behavior or structure changes.

## Retrieval Note

The site search uses live Markdown scanning. It can find newly written vault files before Marginalia semantic indexing catches up.
