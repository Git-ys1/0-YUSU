# Progress

## Current Status

**State**: active baseline published and first arm-tracking dry-run prototype created
**Current phase**: RK3588 YOLO11 perception baseline plus safe non-ROS mechanical-arm visual-servo skeleton

## Stable Today

- RKNN Runtime 2.3.2 repaired and validated.
- C API and RKNNLite Python both prove NPU access.
- YOLO11 image detection runs without torch/LD_PRELOAD dependency.
- YOLO11 USB camera window and headless video mode both run.
- CleanScout main published the lightweight OrangePi baseline in commit `b78f372`.
- CleanScout main published C-5.0.1 arm-tracking dry-run demo in commit `cc12f95e`.
- Board-side C-5.0.1 files exist at `~/rk3588_ai/arm_tracking_demo`.
- Board-side audit reports exist at `~/rk3588_ai/debug_logs/arm_visual_tracking/`.

## Not Finished

- Real mechanical-arm serial output is not validated yet.
- `~/rk3588_ai/rknn_lite_env` currently lacks `pyserial`.
- Current board scan saw `/dev/ttyS7`, but no `/dev/ttyUSB*` or `/dev/ttyACM*` lower-controller serial device.
- No ROS topic publishing yet.
- No complete IK, grasping, fisheye calibration, or hand-eye calibration.
- No multithreaded camera/inference pipeline yet.
- No model management or conversion pipeline formalized in repo.

## Latest Milestones

| Date | Milestone | Evidence |
| --- | --- | --- |
| 2026-06-09 | RKNN Runtime corruption found and fixed | `RK3588_RKNN_NPU_DIAGNOSIS_REPORT.md` |
| 2026-06-09 | YOLO11 NumPy DFL fix validated | `YOLO11_VISUAL_DEMO_FIX_REPORT.md` |
| 2026-06-09 | USB camera YOLO11 real-time demo validated | `YOLO11_CAMERA_DEMO_REPORT.md` |
| 2026-06-10 | OrangePi baseline published to CleanScout main | commit `b78f372` |
| 2026-06-10 | Non-ROS arm visual-tracking dry-run demo published | commit `cc12f95e`; `OrangePi/rk3588_ai/arm_tracking_demo/` |
