# Known Issues

## External Vision Providers Can Be Blocked

Observed on 2026-06-20:

- Local CLI proxy route reached provider but returned a forbidden backend response.
- Shared chat route returned a blocked request.
- Local Ollama was running but only had a text model installed, not a vision model.

Rule:

- Do not treat `mock` as final visual understanding.
- If provider calls fail, export frames/OCR/ASR, inspect keyframes directly, write `manual_visual_review.json`, and merge with `apply-manual-review`.

## OCR Can Stall On Full 1080p Keyframes

RapidOCR works but full-video 1080p OCR can be slow.

Mitigation:

- The pipeline resizes OCR inputs.
- Use `--ocr-max-frames` for long videos.
- Use `--ocr-max-frames 0` only when full OCR is truly needed.

## Default Python Was Too Old

The system default `python` was Anaconda Python 3.7 and lacked `cv2`.

Rule:

- Use target repo `.venv` with Python 3.12.
- Put `PIP_CACHE_DIR`, `HF_HOME`, and `HF_HUB_CACHE` under the repo `.tools/` to avoid C drive pressure.

