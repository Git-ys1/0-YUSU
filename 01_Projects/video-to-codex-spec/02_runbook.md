# Runbook

## Setup

Use a project-local Python 3.12 venv in the target repo:

```powershell
cd F:\AcademicHub\video-analysis-with-aoai
py -3.12 -m venv .venv
$env:PIP_CACHE_DIR = "$PWD\.tools\pip-cache"
$env:HF_HOME = "$PWD\.tools\hf-cache"
$env:HF_HUB_CACHE = "$PWD\.tools\hf-cache\hub"
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

## Full Analysis

```powershell
.\.venv\Scripts\python.exe -m video_to_codex_spec analyze `
  --video "F:\path\to\video.mp4" `
  --output ".tools\analysis\video-name" `
  --fps 0.12 `
  --segment-seconds 60 `
  --scene-detect `
  --ocr `
  --asr `
  --vision-provider openai_compatible `
  --language zh `
  --max-frames-per-segment 6 `
  --ocr-max-frames 24
```

If real visual providers are blocked, do not call the `mock` result final. Use `mock` only to export frames/OCR/ASR, inspect keyframes directly, write `manual_visual_review.json`, then merge:

```powershell
.\.venv\Scripts\python.exe -m video_to_codex_spec apply-manual-review `
  --output ".tools\analysis\video-name" `
  --review ".tools\analysis\video-name\manual_visual_review.json"
```

## Validation Checklist

- `agent_context/goal.md`
- `agent_context/environment.md`
- `agent_context/step_by_step.md`
- `agent_context/commands.sh`
- `agent_context/file_changes.md`
- `agent_context/ui_operations.md`
- `agent_context/checkpoints.md`
- `agent_context/errors_and_fixes.md`
- `agent_context/timeline.json`
- `agent_context/video_index.json`
- `segment_analysis/`
- `ocr.json`
- `transcript.json` or `transcript.srt`
- `keyframes/`

Read `agent_context/` and attempt follow-up work. If the video lacks source code or exact commands, list missing evidence after checking timeline, OCR, ASR, and keyframes.

