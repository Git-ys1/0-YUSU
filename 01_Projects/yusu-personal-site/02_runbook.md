# Runbook

## First Setup

```powershell
cd F:\AcademicHub\0#YUSU
.\tools\setup-marginalia-yusu.ps1 -SyncProjection
$env:DEEPSEEK_API_KEY = "<your key>"
.\tools\configure-marginalia-deepseek.ps1
.\tools\build-yusu-integrated-marginalia-ui.ps1
```

Do not commit `.marginalia-yusu/.env` or print its key.

## Start Locally

Normal Windows startup is one application process:

```powershell
.\tools\run-yusu-personal-site.ps1
```

If semantic recall is required, also start the optional local model service:

```powershell
.\tools\run-carbonrag-bge-embedding-server.ps1
```

Ubuntu/Linux:

```bash
bash tools/run-yusu-personal-site.sh
```

Open:

```text
http://127.0.0.1:8787/
http://127.0.0.1:8787/kaoyan/
http://127.0.0.1:8787/marginalia/chat
http://127.0.0.1:8787/marginalia/library
```

Do not start `run-marginalia-api-yusu.*` or `run-marginalia-ui-yusu.*` for the integrated personal site. Those scripts are retained only for isolated upstream debugging.

## Validate

```powershell
& .\.tools\marginalia-venv\Scripts\python.exe -m py_compile .\07_PersonalSite\server.py
Invoke-RestMethod http://127.0.0.1:8787/health
Invoke-RestMethod http://127.0.0.1:8787/api/status
Invoke-RestMethod http://127.0.0.1:8787/api/marginalia/status
Invoke-RestMethod http://127.0.0.1:8787/api/kaoyan/status
Invoke-RestMethod "http://127.0.0.1:8787/api/search?q=CleanScout"
Invoke-WebRequest http://127.0.0.1:8787/marginalia/chat
Invoke-WebRequest http://127.0.0.1:8787/kaoyan/
```

Expected status fields:

- `integration=same-process`
- `backendSource=F:\AcademicHub\0#YUSU\07_PersonalSite\marginalia-backend`
- `apiBase=/v1`
- `uiBase=/marginalia`
- `workerEnabled=true`

For the Kaoyan dashboard, expected status fields:

- `integration=same-process static dashboard from source workspace`
- `uiBase=/kaoyan/`
- `online=true`
- `workspace=F:\AcademicHub\000资料相关\000考研` unless `YUSU_KAOYAN_WORKSPACE` was overridden.

Agent SSE smoke uses native routes:

```powershell
$session = Invoke-RestMethod http://127.0.0.1:8787/v1/sessions -Method Post -ContentType application/json -Body '{"initiating_user_message":"smoke"}'
$body = @{ query="请只回复 OK"; mode="quick" } | ConvertTo-Json
Invoke-WebRequest "http://127.0.0.1:8787/v1/chat/$($session.session_id)" -Method Post -ContentType application/json -Body $body
```

Expected SSE includes `event: answer` and `event: done`.

## Update UI Source

Showcase layer:

1. Edit `07_PersonalSite/web/index.html`, `web/styles.css`, or `web/app.js`.
2. Keep vendored browser libraries under `07_PersonalSite/web/vendor/` with their license files.
3. Run `node --check .\07_PersonalSite\web\app.js`.
4. Verify desktop and mobile with Playwright.

Marginalia layer:

1. Edit `07_PersonalSite/marginalia-ui/`.
2. Run `tools/build-yusu-integrated-marginalia-ui.*`.
3. Verify `marginalia-dist/index.html` references `/marginalia/assets/`.
4. Test desktop `1280x720` and mobile `390x844` with Playwright.
5. Commit both source and built dist.

## Update Personal-Site Media

Formal media lives under:

```text
07_PersonalSite/media/
```

Use:

- `media/raw/awards/` for original certificate images.
- `media/raw/documents/` for original public source PDFs/DOCX.
- `media/raw/reference/` for original reference videos.
- `media/derived/` and `web/assets/` for browser-facing derivatives.

Do not recreate the retired temporary `记得整理/` folder. Update `07_PersonalSite/notes/materials-inventory.md` and `07_PersonalSite/data/showcase.json` whenever new material is added.

## Update Integrated Backend Source

1. Edit `07_PersonalSite/marginalia-backend/marginalia/`, not `vendor/marginalia`, for YUSU runtime patches.
2. Keep patches small and document why they differ from upstream.
3. Run the targeted regression test:

```powershell
& .\.tools\marginalia-venv\Scripts\python.exe .\07_PersonalSite\tests\test_marginalia_ingest_tags.py
```

4. Verify `http://127.0.0.1:8787/api/marginalia/status` reports the local `backendSource`.

`vendor/marginalia` remains the upstream reference/submodule for comparison and isolated debugging.

## Update Knowledge Content

1. Update Markdown in the canonical vault.
2. Run `sync-yusu-kb-to-marginalia.ps1 -Ingest`.
3. Rebuild the semantic index only at a deliberate maintenance checkpoint.

The personal site's `/api/search` scans live Markdown and can see new files before semantic reindexing completes.

## Update External Static Dashboards

The Kaoyan dashboard is served from the original exam-prep workspace rather than copied into this vault:

```text
F:\AcademicHub\000资料相关\000考研\00_打开-北交电气考研数据看板.html
```

If the source workspace path changes:

```powershell
$env:YUSU_KAOYAN_WORKSPACE = "D:\path\to\000考研"
.\tools\run-yusu-personal-site.ps1
```

After the exam project updates CSV/Markdown/source data, rebuild the dashboard in that project and refresh `/kaoyan/`. Do not commit the generated dashboard HTML or raw `output/` roster exports into the YUSU vault.

The `/kaoyan/` route injects a fixed `返回 YUSU` link into the served response. Do not edit the source dashboard HTML just to add the portal return control.
