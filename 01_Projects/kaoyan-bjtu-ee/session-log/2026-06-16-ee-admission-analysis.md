# 2026-06-16 电气工程学院复试录取分析

## User Goal

User pointed out that 北京交通大学电气工程学院硕士招生栏目 has more detailed 2026 admissions information than the central graduate admissions office, especially:

- `电气工程学院2026年全日制硕士研究生复试考生名单`
- `电气工程学院2026年统考硕士研究生招生拟录取名单`

The user asked to download the sources, analyze scores scientifically, distinguish渤海计划, focus on北京本校区/080800学硕, and set a concrete initial-exam target score.

## Work Done

- Archived the 电气工程学院硕士招生栏目 source pages under:
  - `北京交通大学资料/电气工程学院官网源文件/`
- Saved:
  - 6 list-page snapshots.
  - 16 2026 article snapshots.
  - 2 binary attachments.
  - SHA256 manifest.
- Extracted HTML tables from:
  - full-time retest candidate list.
  - proposed admission list.
  - college retest/admission rules.
  -卓越工程师校企联合培养 plan page.
- Created structured outputs under:
  - `北京交通大学资料/电气工程学院2026复试录取分析/`
- Wrote final report:
  - `北京交通大学资料/2026-电气工程学院复试录取与初试目标分析.md`

## Key Findings

- 080800 学硕:
  - 54 candidates entered retest.
  - 42 proposed admissions.
  - 12 candidates entered retest but were not proposed admissions.
  - 2026 empirical all-admitted initial-score threshold: 365.
  - Logistic model: p90 around 362, p95 around 374; bootstrap p95 upper band near 395.
  - Recommended initial target: 380 main target, 385-390+ strong safety range.
- 渤海计划:
  - Only applies to full-time professional master's.
  - For 085801 in 2026: 53 Bohai proposed admissions.
  - Not relevant to 080800 academic master's target.

## Data Integrity

- Retest table subject-score sum mismatches: 0.
- Proposed-admission table initial + retest total mismatches: 0.
- Duplicate candidate IDs: 0 in both tables.
- Initial-score mismatches between the two tables: 0.

## Tool Notes

- Bundled Python did not have `matplotlib`, so charts were generated as direct SVG.
- pandas CSV reload can infer `080800` as integer `80800`; downstream analysis should `zfill(6)`.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| 080800 学硕 target should be separated from 085801 professional/Bohai data. | project-only | `05_known_issues.md`; analysis report | updated | College retest and proposed admission lists |
| pandas may strip leading zero from admissions major code `080800`. | project-only | `05_known_issues.md` | written | CSV reload during chart generation |
| Bundled Python may lack matplotlib. | project-only | `05_known_issues.md` | written | SVG chart fallback on 2026-06-16 |
