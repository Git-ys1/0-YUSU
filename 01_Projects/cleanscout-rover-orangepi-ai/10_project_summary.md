# Project Summary

## Most Important Things

| Rank | Lesson | Why It Matters |
| --- | --- | --- |
| 1 | RKNN Runtime crashes need binary integrity checks first | Version strings can be misleading; the actual root cause was a corrupt `librknnrt.so` |
| 2 | C API smoke test is the clean separator between driver/runtime and Python wrapper | It proved RK3588 driver/runtime/model compatibility before touching YOLO postprocess |
| 3 | Board-side YOLO postprocess should avoid unnecessary torch dependency | NumPy DFL removed the libgomp/static TLS failure path and kept output identical |
| 4 | Camera demos must distinguish video nodes from metadata nodes | `/dev/video1` was not a normal image stream; auto-fallback prevented false camera failures |
| 5 | Vendor upstreams should be rebuilt from official Git plus overlay | CleanScout should own its delta, not silently vendor a large mutable upstream clone |
| 6 | Mechanical-arm integration must start with dry-run and protocol audit | The current frozen arm firmware uses bus-servo ASCII text commands, while the ROS2 reference uses binary frames; mixing them would be unsafe |
| 7 | Real servo output needs a single communication boundary | `ArmDriver` is the only serial writer, so dry-run, limits, stop behavior, and multi-axis command bundles stay auditable |

## Current Deliverable

CleanScout now has a published OrangePi AI baseline and first arm-tracking dry-run demo in the main repo:

```text
F:\Project\CleanScout_rover\OrangePi\rk3588_ai
F:\Project\CleanScout_rover\OrangePi\rk3588_ai\arm_tracking_demo
```

Important commits:

- `b78f372 C-5.0.0：发布 OrangePi RK3588 AI 基线`
- `cc12f95e C-5.0.1：新增 OrangePi 机械臂视觉追踪 dry-run demo`
- `b8009323 C-5.0.5B：实现 bottle yaw-only 机械臂追踪`
- `4fe29bdf C-5.0.6：实现 bottle 001 lift-only 上下追踪`
- `bb81e83f C-5.0.7A：修正 Servo003 pitch 追踪方向`
- `b5b0fb5c C-5.0.8：实现机械臂三轴组合追踪初版`
- `6af4fd8d C-5.0.8A：统一组合追踪停轴缺省值`

The full upstream RKNN Model Zoo is intentionally reconstructed from official Git. The arm demo is a CleanScout-owned layer and does not modify the original `yolo11_camera.py`.

## Memory Routing Audit

| Candidate Lesson | Route | Action |
| --- | --- | --- |
| RKNN Runtime version string is not enough; verify binary integrity | project plus reusable tooling | written here; can later be promoted to cross-project tooling if more RKNN projects appear |
| Official model zoo should be upstream + overlay, not vendored wholesale | project plus cross-project pattern | written here; useful for other vendor-heavy embedded projects |
| Do not store board passwords in KB | global existing rule | obeyed; no password copied into this project memory |
| Camera metadata nodes can masquerade as video devices | project-only for now | written in known issues |
| Reference ROS2 arm frames are not automatically the current STM32 arm protocol | project-only now; maybe lower-firmware cross-link later | written in known issues and runbook |
| Official `$DST!` path may contain a Servo255 out-of-range bug | project and lower-firmware follow-up | written in known issues; next firmware work should verify or patch |

## Completion Status

This entry started as a new-project snapshot. As of C-5.0.8 it also records the staged OrangePi-to-mechanical-arm path: yaw-only, lift-only, pitch-only, pitch direction hotfix, and first yaw+lift+pitch combined tracking. The remaining gap is user-observed combined real tracking with a visible bottle and parameter tuning, not basic serial/camera bringup.
