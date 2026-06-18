# 2026-06-15 Initialization

## User Goal

Initialize the `F:\AcademicHub\000资料相关\000考研` project as a long-term 27 考研 workspace targeting 北京交通大学电气工程及其自动化 direction, specifically 电气工程 academic master's rather than professional master's.

## Work Done

- Read global memory and YUSU KB startup rules.
- Searched YUSU KB for existing project entries; none existed for this exam-prep project.
- Inspected local files:
  - `北京交通大学资料/26年招生专业.xlsx`
  - `北京交通大学资料/专业课范围.pdf`
- Browsed 北京交通大学研究生院招生专题硕士招生栏目.
- Extracted 2026 and 2027-related official messages.
- Created local project notes:
  - `00_SUPERYUSU考研项目总览.md`
  - `北京交通大学资料/2026-北交研招网硕士招生消息索引.md`
  - `北京交通大学资料/2026-北京交通大学电气工程学硕080800要求.md`
- Archived official source files after user confirmed source files can be downloaded:
  - `北京交通大学资料/官网源文件/网页快照/`
  - `北京交通大学资料/官网源文件/附件/`
  - `北京交通大学资料/官网源文件/重点源文件/`
  - `北京交通大学资料/官网源文件/SHA256SUMS.txt`

## Key Findings

- Target is `080800 电气工程`, academic master's, full-time.
- 2026 catalog lists initial exams as 101 思想政治理论, 201 英语一, 301 数学一, 870 电路.
- 2026 retake subject is 07106 电气工程综合.
- 2026复试线 for 080800 is 324 / 35 / 53.
- 2027 adjustment notices published by 2026-06-15 do not mention 电气工程学院.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| This exam-prep project must distinguish 080800 学硕 from 085801 专硕. | project-only | `05_known_issues.md` | written | 2026招生专业目录 rows for 电气工程学院 |
| Bundled Python may lack `requests`; use `urllib` for lightweight official-page scraping. | project-only | `05_known_issues.md` | written | 2026-06-15 failed import during page extraction |
| 2026 BJTU admissions data is only a baseline for 27考研. | project-only | `06_todo_next.md` | written | 2027 official documents pending |
| Official articles and binary attachments should be archived locally before long-horizon planning. | project-only | `04_progress.md` | written | User requested source files can be downloaded; local archive created under `官网源文件/` |
