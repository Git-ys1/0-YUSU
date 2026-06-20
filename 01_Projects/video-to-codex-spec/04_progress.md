# Progress

## 2026-06-20

- Cloned `Azure-Samples/video-analysis-with-aoai` into `F:\AcademicHub\video-analysis-with-aoai`.
- Added `video_to_codex_spec` package with CLI commands:
  - `analyze`
  - `batch`
  - `apply-manual-review`
- Added PySceneDetect/OpenCV scene detection, fixed FPS sampling, timestamp stamping, keyframe dedupe.
- Added OCR fallback chain: PaddleOCR -> RapidOCR -> Tesseract.
- Added ASR fallback chain: WhisperX -> faster-whisper.
- Added provider abstraction:
  - `azure_openai`
  - `openai_compatible`
  - `ollama`
  - `qwen_vl_local`
  - `mock`
- Added `manual_visual_review.json` merge path because this Codex can inspect keyframes directly when external vision APIs are blocked.
- Ran full validation on `个人站.mp4`.
- Added target repo docs and examples.

