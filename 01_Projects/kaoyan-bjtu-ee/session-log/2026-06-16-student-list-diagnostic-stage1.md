# 2026-06-16 Student-list diagnostic stage 1

## User Request

User asked for a safe local “学生列表本地导出工具” targeting a page that can only be accessed through an already logged-in Microsoft Edge instance on `localhost:9222`. The user explicitly requested a two-stage workflow and asked to complete only stage 1 now: build and run `inspect_site.py`, wait for a manual “下一页” click, capture pagination diagnostics, then defer `export_all.py` until after capture analysis.

## Work Done

- Added workspace-root `inspect_site.py`.
- Added `README.md`, `requirements.txt`, `.gitignore`, and local `AGENTS.md`.
- On 2026-06-17, added workspace-root `export_all.py` as a conservative DOM sequential export path because the user needed a practical way to export the 100k+ roster even before AJAX capture was available.
- On 2026-06-17, added workspace-root `check_edge_cdp.py` to distinguish “CDP port not open” from “target page not open”.
- Created `.venv` using the Codex bundled Python and installed:
  - `playwright`
  - `pandas`
  - `openpyxl`
- Verified:
  - `.\.venv\Scripts\python.exe -m pip check` returned no broken requirements.
  - `.\.venv\Scripts\python.exe -m py_compile .\inspect_site.py` passed.
  - `.\.venv\Scripts\python.exe .\inspect_site.py --help` printed the expected CLI.
  - `.\.venv\Scripts\python.exe -m py_compile .\export_all.py` passed.
  - `.\.venv\Scripts\python.exe .\export_all.py --help` printed the expected CLI.
  - `.\.venv\Scripts\python.exe .\export_all.py --max-pages 3` stopped safely at CDP connection because `127.0.0.1:9222` refused connection.
  - `.\.venv\Scripts\python.exe .\check_edge_cdp.py` correctly reported that `127.0.0.1:9222` refused connection.

## Safety Boundaries Implemented

- The diagnostic tool only allows CDP endpoints starting with `http://127.0.0.1:9222` or `http://localhost:9222`.
- It uses `chromium.connect_over_cdp(...)` and never launches a new browser.
- It never calls `browser.close()`, so it should not close the user's Edge.
- It listens only to XHR/fetch events and records URL, method, POST data, response status, content type, and a capped response excerpt.
- It does not record request headers.
- Sensitive field names containing cookie/session/jsessionid/token/authorization/password/passwd/csrf are masked.
- It saves diagnostics under `capture/` and does not create any full export files.
- `export_all.py` requires `--confirm-full-export` when `--max-pages` is omitted.
- `export_all.py` does not replay an unverified AJAX endpoint; until capture exists, it reads visible table rows and clicks pagination sequentially.
- `export_all.py` writes UTF-8-SIG CSV, checkpoint state, raw/dedup CSV, and an XLSX workbook only under ignored `output/`.

## Current Blocker

Running:

```powershell
.\.venv\Scripts\python.exe .\inspect_site.py --timeout 20
```

failed at connection time:

```text
BrowserType.connect_over_cdp: connect ECONNREFUSED 127.0.0.1:9222
```

The direct probe to `http://127.0.0.1:9222/json/version` also refused connection. This means Edge was not currently listening on the requested CDP port; it was not a sandbox or public-network fallback problem.

The same blocker remained on 2026-06-17 when testing:

```powershell
.\.venv\Scripts\python.exe .\export_all.py --max-pages 3
```

It reached the same CDP connection refusal before reading any student rows.

Additional diagnosis showed:

- `netstat` had no listener on `:9222`.
- The Edge main process command line was only `"msedge.exe" --profile-directory=Default`, with no `--remote-debugging-port=9222`.
- Likely cause: Edge was already running, so a later command with remote debugging flags did not restart the main process with those flags.

## Next Step

The user should start or restart Microsoft Edge with:

```powershell
msedge.exe --remote-debugging-port=9222 --remote-debugging-address=127.0.0.1
```

Then open the target page in that logged-in Edge session and rerun:

```powershell
.\.venv\Scripts\python.exe .\inspect_site.py
```

After the prompt appears, manually click “下一页” once. Only after `capture/` contains a successful pagination candidate should stage 2 (`export_all.py`) be designed.

For immediate DOM export testing, run instead:

```powershell
.\.venv\Scripts\python.exe .\check_edge_cdp.py
.\.venv\Scripts\python.exe .\export_all.py --max-pages 3 --overwrite
```

If this exports around 300 rows, continue only after user confirmation:

```powershell
.\.venv\Scripts\python.exe .\export_all.py --confirm-full-export
```

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| AJAX pagination export must wait for real pagination capture from logged-in Edge CDP. | project-only | `06_todo_next.md` | updated | User explicitly required no un-diagnosed pagination interface; DOM sequential export is the conservative fallback. |
| `127.0.0.1:9222` refusal is an external Edge runtime state, not permission approval. | project-only | `04_progress.md` | written | Both Playwright CDP connect and `/json/version` probe refused connection. |
| Without AJAX capture, only conservative DOM sequential export is allowed. | project-only | `AGENTS.md`, `README.md` | written | User needed an actual export method for 100k+ rows; `export_all.py` avoids unverified AJAX replay. |
| Existing Edge processes must be fully exited before relaunching with CDP flags. | project-only | `README.md`, `06_todo_next.md` | written | Current Edge main process lacks the remote-debugging flag despite prior user belief it had been started that way. |

## 2026-06-17 Follow-up: CDP Startup Fixed And 3-page Export Verified

The user reported repeated `ECONNREFUSED 127.0.0.1:9222` even after trying to restart Edge. Live inspection found an Edge background main process running as `--no-startup-window`; this stale process caused later `--remote-debugging-port=9222` launches to be ignored. After force-stopping all `msedge.exe` processes and starting Edge with `--remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --profile-directory=Default about:blank`, `check_edge_cdp.py` detected Edge CDP and the target page.

Additional fixes:

- `export_all.py` pagination changed from generic “next button” discovery to the page's actual form fields: `LabTeacherInfosForm.tea_p` for page number and `tea_rd` for page size, submitted through the page's `qry()` function.
- Total pages can now be inferred from the page's own pagination hrefs, e.g. the last-page link, instead of hardcoding.
- `export_state.json` now stores the stuck-page signature as a SHA256 hash, not raw student names/IDs.
- Added `start_edge_cdp.ps1`; by default it refuses to stop Edge if it is already running, and only force-stops with `-ForceStop`.
- Updated `check_edge_cdp.py` and `README.md` with the correct PowerShell call-operator form for quoted executable paths.

Verification without exposing student details:

- `.\.venv\Scripts\python.exe -m py_compile .\export_all.py .\check_edge_cdp.py` passed.
- `.\.venv\Scripts\python.exe .\check_edge_cdp.py` detected Edge CDP and the target page.
- `.\.venv\Scripts\python.exe .\export_all.py --max-pages 3 --overwrite` completed successfully.
- Output counts: raw CSV 300 data rows, dedup CSV 297 data rows, partial CSV 300 data rows.
- Excel sheets present: `原始数据`, `去重数据`, `导出信息`.

Next action: full export remains gated by explicit user confirmation and should be run with:

```powershell
.\.venv\Scripts\python.exe .\export_all.py --confirm-full-export
```

## 2026-06-17 Follow-up: Navigation Race And Stale State Recovery

During a full export attempt, the script stopped after requesting a later page with:

```text
Page.evaluate: Execution context was destroyed, most likely because of a navigation
```

The webpage itself was healthy; the failure was a Playwright timing race while the form navigation was replacing the JavaScript execution context. The partial CSV had advanced beyond the last saved state because the earlier script saved `export_state.json` every 10 pages. Row-count-only verification showed partial CSV had 31,800 data rows while `export_state.json` still recorded 31,000 rows. No student details were read or written to memory.

Fixes:

- `wait_after_navigation()` now retries through Playwright navigation-context destruction instead of treating it as a hard failure.
- `export_state.json` is saved after every completed page; console progress remains every 10 pages.
- Resume now reconciles stale state against `students_raw_partial.csv` row count. If partial rows are ahead and align with `page_size`, the script updates state to the completed page implied by the partial CSV.
- Full successful export now writes `output/export_complete.json`; future runs stop when this marker exists unless `--overwrite` is explicitly provided.
- README now warns not to use `--overwrite` when continuing an interrupted export.

Verification:

- `.\.venv\Scripts\python.exe -m py_compile .\export_all.py .\check_edge_cdp.py` passed.
- `.\.venv\Scripts\python.exe .\export_all.py --max-pages 1` recovered stale state from 31,800 rows to completed page 318, exported page 319, and ended with 31,900 raw rows.

Correct resume command after this point:

```powershell
.\.venv\Scripts\python.exe .\export_all.py --confirm-full-export
```
