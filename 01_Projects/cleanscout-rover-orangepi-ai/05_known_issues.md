# Known Issues

## Issue: RKNN Runtime version string can lie if the binary is corrupt

A damaged `/usr/lib/librknnrt.so` still showed version 2.3.2 via `strings`, but was 28 bytes shorter than the official file and segfaulted on `ctypes.CDLL`. Always verify file integrity, not just version strings.

## Issue: `librknn_api.so` is easy to confuse with `librknnrt.so`

A legacy `librknn_api.so` existed, but LD_DEBUG showed the Python Lite2 path loaded `librknnrt.so`. Do not install random RKNPU1 `librknn_api.so` over RK3588 runtime files.

## Issue: torch late import can fail only inside the YOLO script

`import torch` alone may succeed, while `cv2 -> RKNNLite -> torch` fails with static TLS / libgomp. The fix was NumPy DFL, not global `LD_PRELOAD` in `.bashrc`.

## Issue: `/dev/video1` can be metadata, not a camera stream

On this board `/dev/video0` is the real UVC Video Capture node, while `/dev/video1` is metadata. Camera scripts must auto-fallback and print actual node/backend/fourcc.

## Issue: videos and debug logs grow fast

Do not commit `debug_logs/` or `.mp4` validation artifacts. Keep reports and selected small screenshots in Git.

## Issue: publishing full RKNN Model Zoo makes ownership blurry

The full upstream repo belongs to `airockchip`. CleanScout owns the overlay and reports. Commit upstream source only if deliberately forking; otherwise clone from official Git and apply overlay.

## Issue: do not store device password in memory

The JSONL includes initial access context, but the KB must not preserve passwords. Use SSH alias and key-based access notes only.

