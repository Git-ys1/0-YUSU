# 2026-06-17 Home-student marking from local roster export

## User Request

The user completed a local student roster export and asked to mark which 2026 initial/retest participants are BJTU home students. The user also noted that the selection page excludes the current logged-in user from the export.

## Work Done

- Added workspace script `scripts/mark_home_students_2026.py`.
- Read the exported roster only programmatically for name counts; did not print, summarize, or write the full roster into memory.
- Updated these project data files with minimal fields:
  - `北京交通大学资料/电气工程学院2026复试录取分析/复试名单_clean.csv`
  - `北京交通大学资料/电气工程学院2026复试录取分析/拟录取名单_clean.csv`
  - `北京交通大学资料/电气工程学院2026复试录取分析/复试_拟录取比对.csv`
  - `北京交通大学资料/电气工程学院硕士招生纵向分析/data/retest_all_years.csv`
  - `北京交通大学资料/电气工程学院硕士招生纵向分析/data/admit_all_years.csv`
  - `北京交通大学资料/电气工程学院硕士招生纵向分析/data/merged_retest_admit.csv`
  - `北京交通大学资料/电气工程学院硕士招生纵向分析/data/student_registry_2024_2026.csv`
- Refreshed both analysis workbooks.
- Updated `scripts/build_admission_dashboard.py`:
  - Main score table now includes a `本校` column.
  - Detail panel shows home-student verification status.
  - Home-check workbench seeds verification records from the CSV fields using a new localStorage key `bjtu-ee-home-student-verification-v3`.
- Regenerated `00_打开-北交电气考研数据看板.html`.
- Updated the longitudinal report’s “student background registration” section to reflect that 2026 home-student marking has been performed.
- Follow-up correction: user clarified that 2026 考研 corresponds to BJTU undergraduate student IDs beginning with `22`; marker and dashboard import logic were updated to use same-name + `22` student-ID prefix instead of name-only duplicate review.

## Matching Rules

- Same name and student ID prefix `22` in the local roster -> `是否本校生=是`.
- No same-name `22`-prefix roster row -> `是否本校生=否`, meaning “not found as a 22-prefix same-name row in the current local roster export”.
- Duplicate same-name rows no longer create automatic duplicate-review; the `22` prefix is the decision rule for 2026.

No full roster student IDs are written into project CSVs. Project tables store only status, source, date, note, same-name count, and `22`-prefix same-name count.

## Verification

- Syntax check via Python `compile(...)` passed; direct `py_compile` hit a Windows `__pycache__` permission/file-lock issue.
- `.\.venv\Scripts\python.exe .\scripts\mark_home_students_2026.py` completed.
- Static HTML/data checks passed because Browser file URL access was blocked by the in-app browser policy:
  - Dashboard includes `本校` header.
  - Dashboard includes automatic home-check seeding logic.
  - Embedded 2026 candidate rows: 201.
  - 2026 retest counts: 21 home, 180 non-home, 0 duplicate-review, 0 unknown.
  - 2026 proposed-admission counts: 19 home, 138 non-home.
  - Dashboard JS syntax passed `node --check`.

## Caveat

The final export log reports 103,794 exported raw rows versus webpage total 103,899, so `否` should be interpreted as “not found in the current export” unless the roster export is later repaired. This caveat is recorded because it may affect false negatives.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| Home-student status from roster export should store minimal derived evidence, not raw roster IDs. | project-only | `04_progress.md`, `06_todo_next.md` | written | User asked to mark candidates; local AGENTS forbids exposing full exported roster. |
| Rerunning the longitudinal pipeline will clear derived home-student fields unless the marker script is rerun. | project-only | `04_progress.md`, `06_todo_next.md` | written | `ee_admission_pipeline.py` builds registry fields from scratch. |
| For 2026 home-student marking, use same-name plus student ID prefix `22`; name-only duplicate review is obsolete for this cohort. | project-only | `04_progress.md`, `06_todo_next.md`, dashboard/report text | updated | User clarified the student-ID cohort rule. |
