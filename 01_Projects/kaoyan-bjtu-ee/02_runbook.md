# Runbook

## Environment

- OS: Windows
- Shell: PowerShell
- Workspace: `F:\AcademicHub\000资料相关\000考研`
- Official source: https://yzb.bjtu.edu.cn/sszs/index.htm

## Common Commands

```powershell
rg --files
rg -n -i "北京交通大学|电气工程|080800|870|07106" .
```

Use bundled Codex Python for XLSX/PDF extraction when needed:

```powershell
& 'C:\Users\yusu\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -c "print('ok')"
```

Rebuild the 2024-2026 longitudinal admissions data from archived source files:

```powershell
& 'C:\Users\yusu\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' '.\scripts\ee_admission_pipeline.py' --workspace 'F:\AcademicHub\000资料相关\000考研' --skip-download
```

Regenerate the root local dashboard entry:

```powershell
& 'C:\Users\yusu\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' '.\scripts\build_admission_dashboard.py' --workspace 'F:\AcademicHub\000资料相关\000考研'
```

If the workspace `.venv` exists, this equivalent command is now verified:

```powershell
.\.venv\Scripts\python.exe .\scripts\build_admission_dashboard.py --workspace 'F:\AcademicHub\000资料相关\000考研'
```

## YUSU Personal Site Integration

The dashboard is mounted into the YUSU personal site at:

```text
http://127.0.0.1:8787/kaoyan/
```

Integration boundary:

- Source of truth remains `F:\AcademicHub\000资料相关\000考研`.
- The personal site serves `00_打开-北交电气考研数据看板.html` from that source workspace in the same `8787` FastAPI process.
- The generated HTML and raw `output/` roster exports are not copied into `F:\AcademicHub\0#YUSU`, because they may contain score/name/verification data that should stay in the exam project.
- After updating analysis CSV/Markdown in this project, rerun `scripts\build_admission_dashboard.py`; the YUSU route reflects the updated file after browser refresh.
- If the workspace path changes on another machine, set `YUSU_KAOYAN_WORKSPACE` before starting `tools\run-yusu-personal-site.ps1`.

## Verification Workflow

1. Open the研招办硕士招生栏目.
2. Search for new 2027 notices, especially:
   - 招生简章
   - 招生专业目录
   - 自命题科目考试范围
   - 复试分数线
   - 各培养单位复试录取工作办法
3. Compare against `北京交通大学资料/2026-北京交通大学电气工程学硕080800要求.md`.
4. Update the project notes only after confirming against official pages or attachments.

## Troubleshooting

- If bundled Python lacks `requests`, use standard library `urllib` or the browser/web tool instead of installing dependencies.
- If a page attachment is binary XLSX/PDF, cite the hosting article and extract locally from the downloaded attachment.
- Treat 2026拟招生人数 as a planning signal only; actual统考名额 depends on final推免录取 and 2027 catalog.
- The preferred human entry point is now `00_打开-北交电气考研数据看板.html`, not the raw CSV/report folders.
- The dashboard embeds data at generation time. Re-run `build_admission_dashboard.py` after changing CSV outputs.
- The dashboard's `本校生核验` workbench stores manual verification results in browser `localStorage`, not in source CSV/Markdown. Use its export CSV button before clearing browser data.
- The dashboard defaults the home-student lookup field to `https://mis.bjtu.edu.cn/`, the official BJTU student information system entry. It also includes a `本科生学籍查询` preset from the official BJTU student services page. If a deeper post-login search URL is known, paste it into the dashboard field; URLs can contain `{name}` as a placeholder for automatic name substitution.
- The dashboard can import a local student roster CSV in the browser and match 2026 candidates by same name plus student ID prefix `22`. Expected columns can be Chinese (`学号`, `姓名`, `专业`, `学院`) or export-tool style (`student_id`, `name`, `major`, `college`).
- The `本校生优势对比` panel is intentionally derived only from browser-local verified records. Do not write a home-student advantage conclusion into source notes until the user has reviewed enough verified home/non-home samples.
- Do not broaden dashboard Markdown collection to all `*.md` files in the workspace; it should stay limited to the root exam overview and `北京交通大学资料/`, otherwise `.venv` package license Markdown and tool docs pollute the reading pane.

## Source Evidence

- Commands verified on 2026-06-15:
  - `rg --files`
  - bundled Python `openpyxl` extraction of `26年招生专业.xlsx`
  - bundled Python `pypdf` extraction of `专业课范围.pdf`
