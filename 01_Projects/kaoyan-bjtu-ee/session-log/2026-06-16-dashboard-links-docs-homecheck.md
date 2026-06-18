# 2026-06-16 Dashboard links, docs, and home-student verification

## Trigger

User asked to continue optimizing the local dashboard:

- The old `研招网` button was inaccurate; it should be named `北京交通大学研究生招生网`.
- Keep that link, add the Beijing Jiaotong University Electrical Engineering College admissions site, and add the real China graduate admissions site.
- Add in-page Markdown reading so `.md` files render as readable documents instead of raw browser text.
- Add support for using a BJTU student lookup page to check whether 2026 candidates are BJTU home students, useful because newly admitted 2026 students may not yet be in graduate student systems.

## Work Completed

- Updated `scripts/build_admission_dashboard.py`.
- Regenerated `00_打开-北交电气考研数据看板.html`.
- Top links now include:
  - `北交研究生招生网` -> `https://yzb.bjtu.edu.cn/sszs/index.htm`
  - `电气学院招生` -> `https://ee.bjtu.edu.cn/zsjy/yjszs2/sszs/index.htm`
  - `中国研招网` -> `https://yz.chsi.com.cn/`
- Added a `Markdown 文档` section:
  - Embeds 9 local `.md` files at generation time.
  - Renders headings, lists, code blocks, links, blockquotes, and Markdown tables in the dashboard.
- Added a `本校生核验` section:
  - Default scope: 2026 `080800` proposed-admission candidates, 42 people.
  - Candidate list includes score/rank context and special-case tags.
  - Lookup URL now defaults to official `https://mis.bjtu.edu.cn/`.
  - Added preset buttons for `学生信息系统` and `本科生学籍查询`, based on the official BJTU student services page.
  - User can still paste a deeper BJTU student lookup URL, with optional `{name}` placeholder.
  - User can copy candidate name, open the lookup page, mark status as `本校生` / `非本校` / `重名待核验` / `待复核`, and export CSV.
  - Verification records are stored in browser `localStorage` only and are not written into source CSV, Markdown, or YUSU memory.
- Added browser-local student roster CSV import:
  - Accepts `学号/姓名/专业/学院` or `student_id/name/major/college` columns.
  - Matches candidates by exact normalized name in the browser.
  - Shows `名单命中`, `同名 N`, or `名单无同名` in the candidate list.
  - Lets the user adopt a matched row into the local verification record without Codex reading the roster file.
- Added `本校生优势对比`:
  - Counts verified `本校生` and `非本校` candidates in the current verification scope.
  - Compares average initial score, retest score, and total score.
  - Displays retest/total-score average differences only after at least one home and one non-home candidate are marked.
  - Highlights the verified home-student sample with the lowest initial score and highest retest score tie-breaker.
- Tightened Markdown collection:
  - Only `00_SUPERYUSU考研项目总览.md` and files under `北京交通大学资料/` are embedded.
  - This prevents `.venv` package license Markdown and local tool docs from appearing in the dashboard after tool setup.

## Verification

Playwright checks on local HTML with system Chrome:

- Console errors: 0.
- Official links:
  - BJTU graduate admissions: `https://yzb.bjtu.edu.cn/sszs/index.htm`
  - EE college admissions: `https://ee.bjtu.edu.cn/zsjy/yjszs2/sszs/index.htm`
  - CHSI: `https://yz.chsi.com.cn/`
- Markdown docs count: 9; no `.venv/` or `capture/` Markdown included.
- Default Markdown title: `2024-2026 北京交通大学电气工程学院硕士招生纵向对比报告`.
- Markdown tables rendered: 7.
- Default score table remains 182 rows.
- Home-check nav exists.
- Home-check default list: 42 candidates.
- Sample in-memory roster CSV import: status `sample_roster.csv · 2 条 · 2 个姓名`.
- Sample candidate match: `唯一命中`; adopting the row changed the local panel status to `本校生`.
- Default lookup field: `https://mis.bjtu.edu.cn/`.
- Lookup preset count: 2; `本科生学籍查询` preset switches to `http://bksy.bjtu.edu.cn/jwapp/sys/xsxjcxapp/*default/index.do#/xsxjcx`.
- Sample advantage check: after one sample `本校生` and one sample `非本校`, the panel displayed `1 本校 · 1 非本校`, retest average difference, total-score average difference, and a home-student sample note.
- Mobile/tablet/desktop viewport checks passed with no horizontal overflow in the home-check area.

## Privacy Boundary

Student IDs and home-student status are treated as private or at least sensitive personal data. The dashboard supports manual, local-only verification and CSV export, but Codex should not write unverified or raw private student lookup results into the shared YUSU vault. If exported evidence is later merged into project data, store only the minimum necessary fields and keep source/date.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| BJTU home-student status must remain unverified until checked against the student lookup page. | project-only | `06_todo_next.md`, `04_progress.md` | written | User described the lookup use case; exact URL not provided in current turn. |
| Dashboard localStorage verification should be exported before clearing browser data. | project-only | `02_runbook.md` | written | Home-check workbench stores records locally in browser. |
| Dashboard Markdown collection should avoid workspace-wide `*.md` after tool setup. | project-only | `02_runbook.md` | written | `.venv` package license Markdown polluted the docs list until collection was scoped to exam materials. |
| Public official evidence points to MIS and undergraduate-status service entries, not a confirmed unauthenticated name-search page. | project-only | `02_runbook.md`, `06_todo_next.md` | written | BJTU student services page lists `学生信息系统` and `本科生学籍查询`; MIS redirects to CAS login. |
| Home-student advantage claims should be derived from verified local records, not assumed from anecdotes. | project-only | `02_runbook.md` | written | Dashboard now computes comparisons only from browser-local statuses marked `本校生`/`非本校`. |
