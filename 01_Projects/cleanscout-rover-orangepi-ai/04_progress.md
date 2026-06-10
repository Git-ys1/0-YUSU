# Progress

## Current Status

**State**: active baseline published
**Current phase**: RK3588 YOLO11 perception baseline ready for future mechanical-arm vision work

## Stable Today

- RKNN Runtime 2.3.2 repaired and validated.
- C API and RKNNLite Python both prove NPU access.
- YOLO11 image detection runs without torch/LD_PRELOAD dependency.
- YOLO11 USB camera window and headless video mode both run.
- CleanScout main has published the lightweight OrangePi baseline in commit `b78f372`.

## Not Finished

- No ROS topic publishing yet.
- No mechanical-arm command integration yet.
- No multithreaded camera/inference pipeline yet.
- No model management or conversion pipeline formalized in repo.

## Latest Milestones

| Date | Milestone | Evidence |
| --- | --- | --- |
| 2026-06-09 | RKNN Runtime corruption found and fixed | `RK3588_RKNN_NPU_DIAGNOSIS_REPORT.md` |
| 2026-06-09 | YOLO11 NumPy DFL fix validated | `YOLO11_VISUAL_DEMO_FIX_REPORT.md` |
| 2026-06-09 | USB camera YOLO11 real-time demo validated | `YOLO11_CAMERA_DEMO_REPORT.md` |
| 2026-06-10 | OrangePi baseline published to CleanScout main | commit `b78f372` |

