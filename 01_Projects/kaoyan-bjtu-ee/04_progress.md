# Progress

## Current State

Project initialized as a long-term exam-prep workspace. 2026 BJTU official admissions baseline has been extracted and summarized for 080800 电气工程学硕. The workspace now has a root-level local dashboard as the primary entry point for 2024-2026 longitudinal admissions data.

## Completed

- Created root overview: `00_SUPERYUSU考研项目总览.md`.
- Created official message index: `北京交通大学资料/2026-北交研招网硕士招生消息索引.md`.
- Created target card: `北京交通大学资料/2026-北京交通大学电气工程学硕080800要求.md`.
- Archived official source files under `北京交通大学资料/官网源文件/`:
  - 33 official article HTML snapshots.
  - 47 official binary attachments.
  - Key-source copies under `官网源文件/重点源文件/`.
  - SHA256 manifest at `官网源文件/SHA256SUMS.txt`.
- Confirmed local attachments:
  - `北京交通大学资料/26年招生专业.xlsx`
  - `北京交通大学资料/专业课范围.pdf`
- Confirmed 2026 target facts:
  - 007 电气工程学院
  - 080800 电气工程学硕
  - 全日制拟招 96, 其中推免 60
  - 初试 101/201/301/870
  - 复试 07106
  - 2026 复试线 324 / 35 / 53
- Archived the 电气工程学院硕士招生栏目 2026 source pages:
  - 6 list-page snapshots.
  - 16 2026 article snapshots.
  - 2 downloadable attachments.
- Extracted and analyzed the 2026 full-time retest candidate list and proposed admission list:
  - 201 full-time retest candidates.
  - 157 proposed admissions.
  - 080800 academic master's: 54 retest candidates, 42 proposed admissions, 12 not admitted.
  - Cleaned datasets and workbook written under `北京交通大学资料/电气工程学院2026复试录取分析/`.
- Wrote the target-score report:
  - `北京交通大学资料/2026-电气工程学院复试录取与初试目标分析.md`.
- Built the 2024-2026 longitudinal analysis workspace:
  - `北京交通大学资料/电气工程学院硕士招生纵向分析/`.
  - 595 total retest registry rows across 080800 and 085801.
  - 080800 three-year retest rows: 182; proposed admissions: 143; not admitted: 39.
  - Source archive includes 2024/2025/2026 retest, proposed-admission, and retest-rule pages plus list-page snapshots.
  - Student registry includes placeholder columns for undergraduate school and whether the candidate is a BJTU home student; these remain unverified.
- Built root dashboard entry:
  - `00_打开-北交电气考研数据看板.html`.
  - Shows KPIs, charts, year-segmented named score table, filters, special cases, score-bin heatmap, and source/artifact links.
  - Verified with local server and Playwright on 2026-06-16: console 0 errors, default 080800 table 182 rows, search `吴羽鹏` returns 1 row.
- Extended the dashboard:
  - Renamed the old `研招网` button to `北交研究生招生网`.
  - Added links for `电气学院招生` and `中国研招网`.
  - Added in-page Markdown document reading for 9 local `.md` files, with the longitudinal report rendered as formatted HTML tables/text.
  - Added `本校生核验` workbench for 2026 candidates. Default scope is 2026 `080800` proposed admissions, 42 people.
  - Verification records are browser-local only via `localStorage`; export to CSV is available. No unverified home-student conclusion is written to project source data or YUSU memory.
  - Added browser-local student roster CSV import inside `本校生核验`, so an exported BJTU student list can be matched by name in the dashboard without Codex reading `output/` data.
  - Set the default lookup entry to `https://mis.bjtu.edu.cn/` and added a `本科生学籍查询` preset from the official BJTU student services page.
  - Added a `本校生优势对比` panel that compares verified home/non-home candidates' initial, retest, and total score averages and highlights a low-initial/high-retest home-student sample.
  - Markdown document embedding is scoped to `00_SUPERYUSU考研项目总览.md` and `北京交通大学资料/` to avoid pulling `.venv` or tool README files into the admissions dashboard.
- Added a first-stage local student-list diagnostic tool at workspace root:
  - `inspect_site.py` connects only to existing logged-in Microsoft Edge over `localhost:9222` via Playwright CDP.
  - `README.md`, `requirements.txt`, `.gitignore`, and local `AGENTS.md` document safety boundaries.
  - `.venv` was created and `playwright`, `pandas`, and `openpyxl` installed; `pip check` passed.
  - Syntax and CLI help checks passed.
- Added a conservative DOM-based student-list export script:
  - `export_all.py` connects only to existing logged-in Edge over `localhost:9222`.
  - It does not replay an unverified AJAX endpoint; without `capture/` it reads visible table rows and clicks pagination controls sequentially.
  - It supports `--max-pages 3` testing, UTF-8-SIG CSV, checkpoint resume, raw/dedup CSV, and Excel with raw/dedup/info sheets.
  - `--confirm-full-export` is required when `--max-pages` is omitted.
  - Syntax and CLI help checks passed; live export is not yet verified because `127.0.0.1:9222` still refuses connection.
- Added `check_edge_cdp.py`:
  - Checks whether Edge CDP is listening at `127.0.0.1:9222`.
  - Lists whether the target `loadContestRelationStuList` page is open.
- Resolved the Edge CDP startup issue:
  - The blocker was a background Edge `--no-startup-window` process, which caused later launches with `--remote-debugging-port=9222` to be ignored.
  - Added `start_edge_cdp.ps1` as a safe helper; it refuses to stop Edge unless `-ForceStop` is provided.
  - README now shows the correct PowerShell call operator form for quoted executable paths.
- Verified the student-list export path on 2026-06-17:
  - `check_edge_cdp.py` found the target page after Edge was restarted with CDP.
  - `export_all.py --max-pages 3 --overwrite` exported 300 raw rows and 297 deduplicated rows.
  - The workbook contains `原始数据`, `去重数据`, and `导出信息` sheets.
  - `export_state.json` now stores the last-page signature as a SHA256 hash, not raw student names/IDs.
- Hardened interrupted-export recovery on 2026-06-17:
  - Fixed Playwright `Execution context was destroyed` during form navigation by retrying while the page is reloading.
  - State is now saved after every completed page, while console progress still prints every 10 pages.
  - Resume now reconciles stale `export_state.json` against `students_raw_partial.csv` row count, so pages already written to partial CSV are not re-exported.
  - A one-page resume test recovered from 31,800 partial rows to page 319 and reached 31,900 raw rows without duplicating pages 311-318.
  - Full completion will write `output/export_complete.json`; later runs stop when that marker exists unless `--overwrite` is explicitly used.
- Marked 2026 home-student status from the local BJTU student roster export:
  - Added `scripts/mark_home_students_2026.py`.
  - Updated the 2026 retest, proposed-admission, merged comparison, longitudinal retest/admit/merged, and `student_registry_2024_2026.csv` tables with minimal home-student fields.
  - Updated matching rule after user correction: for 2026 考研, BJTU undergraduate cohort should have student IDs beginning with `22`; mark home only when the roster has the same name and a `22`-prefix student ID.
  - Counts for 2026 retest rows: 21 home, 180 non-home, 0 automatic duplicate-review.
  - Counts for 2026 proposed-admission rows: 19 home, 138 non-home, 0 automatic duplicate-review.
  - The dashboard now has a main-table `本校` column, seeds the home-check workbench from CSV fields, and uses `22`-prefix matching for browser-local roster import.
  - No full exported roster student IDs are written into project CSVs; only status, source, date, notes, same-name count, and 22-prefix same-name count are stored.
  - Caveat: final export log reported 103,794 exported rows versus webpage total 103,899, so non-home should be read as “not found in current export” unless the roster export is later repaired.

## Milestones

| Date/Phase | Milestone | Evidence | Notes |
|---|---|---|---|
| 2026-06-15 | Initial official-source baseline | Local Markdown files and official yzb.bjtu.edu.cn pages | 2026 baseline only; 2027 official documents still pending |
| 2026-06-15 | Official source archive | `北京交通大学资料/官网源文件/官网源文件清单.md`; `SHA256SUMS.txt` | Full article snapshots plus downloadable attachments saved locally |
| 2026-06-16 | 电气学院复试录取分析 | `北京交通大学资料/2026-电气工程学院复试录取与初试目标分析.md`; `analysis_summary.json` | 080800 target line set to 380, with 385-390+ as strong safety range |
| 2026-06-16 | 2024-2026 longitudinal dashboard | `00_打开-北交电气考研数据看板.html`; `北京交通大学资料/电气工程学院硕士招生纵向分析/data/analysis_summary.json` | Unified local entry for named score table, special cases, source archive, and charts |
| 2026-06-16 | Dashboard official links, Markdown reader, home-student verification | `scripts/build_admission_dashboard.py`; Playwright checks | BJTU grad admissions, EE college admissions, CHSI links present; Markdown report renders; home-check default scope has 42 candidates; local roster CSV import matches by name in browser; official MIS and undergraduate-status presets available; home/non-home score advantage panel updates from verified records |
| 2026-06-16 | Student-list diagnostic tool stage 1 scaffold | `inspect_site.py`; `README.md`; `.venv` pip check | Ready to connect to logged-in Edge CDP; no pagination capture yet because `127.0.0.1:9222` refused connection |
| 2026-06-17 | Student-list DOM export script and CDP preflight | `export_all.py`; `check_edge_cdp.py`; `README.md`; `AGENTS.md`; py_compile/help checks | Conservative sequential export path ready |
| 2026-06-17 | Student-list 3-page export test passed | `start_edge_cdp.ps1`; `export_all.py --max-pages 3 --overwrite`; output row-count checks | Edge CDP startup fixed by clearing background Edge; 300 raw rows and 297 dedup rows generated; full export still requires user confirmation |
| 2026-06-17 | Student-list resume recovery hardened | `export_all.py`; `README.md`; one-page resume test | Recovered stale state from partial CSV row count; continued from page 319; raw rows reached 31,900; full export should resume with `--confirm-full-export` and no `--overwrite` |
| 2026-06-17 | 2026 home-student status marked | `scripts/mark_home_students_2026.py`; updated CSV/XLSX/dashboard; static HTML checks | 201 retest rows and 157 proposed-admission rows marked from local roster same-name + `22` student-ID prefix rule |

## In Progress

- Waiting for 2027 official招生简章、专业目录、自命题范围.
- Next planning step: convert the 380/390 initial-score target into subject-by-subject study plan.
- Student-list export is available, but the current completed file has a row-count mismatch against the webpage total; use `students_dedup.csv` cautiously as a name-matching source.
- If AJAX capture is still desired for speed, run `.\.venv\Scripts\python.exe .\inspect_site.py` and manually click “下一页” once before upgrading `export_all.py`.
- If the longitudinal pipeline is rerun, run `.\.venv\Scripts\python.exe .\scripts\mark_home_students_2026.py` afterward because `ee_admission_pipeline.py` rebuilds registry fields from scratch.

## Blocked

- No current technical blocker for DOM-based student-list export. Full export is intentionally gated on user confirmation.

## Last Meaningful Update

- Date: 2026-06-17
- Source: home-student marking pass; 2026 candidates now have home/non-home status in CSV, workbook, and dashboard using same-name + `22` student-ID prefix
