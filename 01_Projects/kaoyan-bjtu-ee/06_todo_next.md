# Todo Next

## Next Actions

- [ ] Build a 27 考研 annual timeline once the user confirms daily/weekly supervision style.
- [ ] Create a subject plan for 870 电路, 数学一, 英语一, 政治.
- [ ] When 2027 official招生专业目录 appears, diff it against the 2026 target card.
- [ ] When 2027 self命题范围 appears, diff 870 and 07106 against the 2026 PDF.
- [ ] If the user finds a deeper post-login BJTU student name-search URL inside MIS, replace the dashboard default `studentLookupUrl`; current default is the official MIS entry plus official undergraduate-status preset.
- [x] Merge necessary home-student fields into `student_registry_2024_2026.csv` from the local BJTU student roster export.
- [x] Fully exit current Edge first, then start Microsoft Edge with `--remote-debugging-port=9222 --remote-debugging-address=127.0.0.1`, open the student-list target page, run `.\.venv\Scripts\python.exe .\check_edge_cdp.py`, then run `.\.venv\Scripts\python.exe .\export_all.py --max-pages 3 --overwrite` to verify the first 3 pages.
- [ ] If higher-confidence roster coverage is needed, repair/re-run the student-list export because the current final log reports 103,794 exported rows versus webpage total 103,899.
- [ ] If 3-page DOM export is too slow or unreliable, run `.\.venv\Scripts\python.exe .\inspect_site.py`, manually click “下一页” once, analyze `capture/`, then upgrade `export_all.py` to use the verified AJAX pagination endpoint.
- [x] After a safe student roster export exists, mark 2026 candidates from `students_dedup.csv` and seed the dashboard's `本校生核验` section automatically.
- [x] Replace name-only duplicate-review home-student logic with the 2026 cohort rule: same name plus student ID prefix `22` means BJTU home student.

## Evidence Gaps

- [ ] 2027 招生简章 not yet published as of 2026-06-15.
- [ ] 2027 招生专业目录 not yet published as of 2026-06-15.
- [ ] 2027 自命题科目考试范围 not yet published as of 2026-06-15.

## Needs User Decision

- [ ] Whether to create recurring supervision/reminder automation.
- [ ] Whether to track practice progress in Markdown, spreadsheet, or a small local app.
- [x] Store only minimal home-student evidence in admissions tables: yes/no status, source, date, note, same-name count, and `22`-prefix same-name count; do not store full roster student IDs.
- [ ] Whether the student-list export files should remain at workspace root or move into a dedicated `student_export/` subdirectory after live verification.

## Later

- [ ] Collect 870 电路历年真题/题型 if available from reliable sources.
- [ ] Build a score and复盘 tracker.
- [ ] Add a periodic official-source monitoring workflow.
