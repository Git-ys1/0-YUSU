# 2026-06-16 纵向数据看板入口

## Trigger

User reviewed the workspace and found the generated reports, CSV files, charts, and source archives too scattered. They asked for a unified local frontend entry where all data can be viewed longitudinally, especially named score tables sorted by year segment and rank.

## Work Completed

- Added a root-level local dashboard:
  - `F:\AcademicHub\000资料相关\000考研\00_打开-北交电气考研数据看板.html`
- Added a repeatable dashboard builder:
  - `F:\AcademicHub\000资料相关\000考研\scripts\build_admission_dashboard.py`
- Dashboard embeds data from:
  - `北京交通大学资料/电气工程学院硕士招生纵向分析/data/major_year_summary.csv`
  - `student_registry_2024_2026.csv`
  - `merged_retest_admit.csv`
  - `special_cases.csv`
  - `score_bins.csv`
  - `logistic_thresholds.csv`
  - `sources/source_manifest.csv`
- Dashboard sections:
  - 080800 KPI summary.
  - Yearly trend charts.
  - Named score roster with filters by year, major, admission status, search, and sort.
  - Default roster order: year segment then within-year initial-score rank.
  - Candidate detail panel.
  - Special cases with clickable rows that jump back into the roster.
  - Score-bin admission-rate heatmap.
  - Local artifact and official source links.

## Verification

- Local static server:
  - `http://127.0.0.1:8765/00_%E6%89%93%E5%BC%80-%E5%8C%97%E4%BA%A4%E7%94%B5%E6%B0%94%E8%80%83%E7%A0%94%E6%95%B0%E6%8D%AE%E7%9C%8B%E6%9D%BF.html`
- Playwright verification:
  - Console errors: 0.
  - Default 080800 roster rows: 182.
  - Default 080800 admitted/not-admitted split: 143 / 39.
  - Search `吴羽鹏`: 1 row.
  - Desktop and mobile screenshots were inspected, then temporary verification artifacts were cleaned from the workspace.

## Key Data Facts

- 2024-2026 combined registry across 080800 and 085801: 595 rows.
- 080800 yearly empirical all-admitted initial-score thresholds:
  - 2024: 359.
  - 2025: 372.
  - 2026: 365.
- Current planning conclusion remains: 380 is the main initial-score target; 385-390+ is the stronger safety range.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| This exam-prep workspace needs a human-first local dashboard entry, not only auditable source/data folders. | project-only | `04_progress.md`, `02_runbook.md` | written | User explicitly said the workspace was too scattered and asked for a unified file/frontend entry. |
| Dashboard data is embedded at generation time, so it must be regenerated after CSV updates. | project-only | `02_runbook.md` | written | `scripts/build_admission_dashboard.py` writes a self-contained HTML file. |
