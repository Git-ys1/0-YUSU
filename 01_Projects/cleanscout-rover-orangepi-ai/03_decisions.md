# Technical Decisions

## Decision: publish RKNN Model Zoo as upstream plus overlay, not as vendored source

**Status**: accepted
**Date**: 2026-06-10

### Context

Local `rknn_model_zoo/` is an upstream Git clone around v2.3.2 and is much larger than the CleanScout-specific changes. It can also contain local board edits, generated files, models, and logs.

### Decision

CleanScout main repository stores:

- task books
- reports
- smoke scripts
- validation images
- `model_zoo_overlay/` containing modified `yolo11.py` and new `yolo11_camera.py`
- `UPSTREAMS.md` and `scripts/apply_model_zoo_overlay.sh`

It ignores the full upstream clone, venvs, models, debug logs, and videos.

### Evidence

- CleanScout commit `b78f372`
- `OrangePi/rk3588_ai/UPSTREAMS.md`
- local upstream `airockchip/rknn_model_zoo`, tag `v2.3.2`, commit `bad6c73`

## Decision: NumPy DFL is the stable YOLO11 board-side postprocess

**Status**: accepted
**Date**: 2026-06-09

### Context

Official `yolo11.py` imports torch inside `dfl()` after OpenCV/RKNNLite are already loaded. On this aarch64 board that triggers libgomp static TLS failures.

### Decision

Replace torch DFL with numerically equivalent NumPy DFL. The validation script reported `max_abs_error: 0.0` and the final JPEG hash matched the torch-first + LD_PRELOAD route.

## Decision: Runtime integrity must be checked before blaming model or system image

**Status**: accepted
**Date**: 2026-06-09

### Context

`/usr/lib/librknnrt.so` reported version 2.3.2 by strings but was truncated/corrupt by 28 bytes. Direct `ctypes.CDLL` segfaulted before meaningful NPU work began.

### Decision

When RKNNLite crashes at `init_runtime()`, first check Runtime binary integrity: size, SHA-256, `readelf`, `ctypes.CDLL`, then C API smoke. Do not jump directly to OS reinstall or model blame.

