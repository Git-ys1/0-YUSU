# video-to-codex-spec

## Project

- Repository: `F:\AcademicHub\video-analysis-with-aoai`
- Upstream: `https://github.com/Azure-Samples/video-analysis-with-aoai.git`
- New purpose: turn tutorial/reference videos into Codex-readable `agent_context/` construction specs.
- Canonical taskbook: `04_Runbooks/video-to-codex-spec-refactor-taskbook.md`

## Current State

The target repo has been refactored from an Azure OpenAI Streamlit demo into a CLI-first system:

- `python -m video_to_codex_spec analyze`
- `python -m video_to_codex_spec batch`
- `python -m video_to_codex_spec apply-manual-review`

The pipeline exports scenes, sampled frames, deduped keyframes, OCR, ASR, segment JSON, timeline, video index, and `agent_context/`.

## Validation

Validated on:

`F:\AcademicHub\0#YUSU\07_PersonalSite\media\raw\reference\个人站.mp4`

Key results:

- 65 segments
- 136 sampled frames
- 60 keyframes
- OCR status `ok` via `rapidocr-onnxruntime`
- ASR status `ok` via `faster-whisper`
- 65 `segment_analysis/*.json`
- full `agent_context/`
- manual keyframe review merged because configured external vision providers were blocked

## Read First

- `02_runbook.md`
- `05_known_issues.md`
- Target repo `VALIDATION_REPORT.md`

