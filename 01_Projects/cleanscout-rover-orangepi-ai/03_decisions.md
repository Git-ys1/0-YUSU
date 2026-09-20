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

## Decision: mechanical-arm serial work starts from the bus-servo command table

**Status**: accepted
**Date**: 2026-06-11

### Context

CleanScout C-5.x mechanical-arm work repeatedly risked misreading `#000P1500T1000!` as a generic PWM-servo-only command or as secondary to ROS2 binary frames. The user confirmed the board is flashed with the official `firmware/mechanical_arm_official_baseline` firmware and that the PC upper software can read current angle and control the arm.

### Decision

For any future mechanical-arm protocol, serial, readback, or visual-tracking work:

- Treat `docs/001-总线舵机资料/1.使用手册/附件1《总线舵机指令表》.docx` as the authoritative protocol source.
- Use the Markdown mirror `docs/VERIFY/C-5.0.2_arm_bus_servo_command_table.md` for quick Codex lookup.
- Remember that `#000PRAD!`, `#000PID!`, `#000PVER!`, and `#000PRTV!` are official readback commands.
- If OrangePi receives no bytes, debug port, wiring, bridge path, DTR/RTS, timeout, and tool behavior before claiming protocol absence.
- For visual tracking, consult the A1/Yeahbot vision-to-serial reference before designing the control loop.

### Evidence

- `docs/VERIFY/C-5.0.2_arm_bus_servo_command_table.md`
- `docs/VERIFY/C-5.0.2_arm_bus_servo_protocol_note.md`
- `OrangePi/rk3588_ai/arm_tracking_demo/tools/bus_servo_probe.py`
- User correction on 2026-06-11 that PC upper software can read current angle and control the official-baseline board.

### 2026-06-11 live clarification

The frozen STM32 baseline is a dual-path gateway, not a pure "bus only" or
"PWM only" implementation:

- `parse_action()` forwards the ASCII command to the other UARTs through
  `zx_uart_send_str()`.
- The same command is also parsed locally and drives the six software-PWM
  outputs through `pwmServo_angle_set()`.
- On the current CH340 wiring, Servo000/001/002 returned real bus version and
  position responses; Servo003/004/005 did not return bus data.
- Lack of `PRAD` response does not prove that a local PWM channel did not move.
  Servo003 movement was verified from the end-camera image displacement.
- Every OrangePi arm serial process must request an exclusive lock on
  `/dev/ttyUSB0`; concurrent probe/tracker processes previously consumed each
  other's replies.

The early tracking sketch considered Servo000 yaw plus Servo003 wrist pitch, but live C-5.0.5/C-5.0.6 development deliberately split the work into Servo000 yaw-only first, then Servo001 lift-only. Servo003 remains a future fine pitch axis for the 34 end-effector angle.

## Decision: C-5.0.5 starts with bottle-only Servo000 yaw tracking before pitch

**Status**: accepted
**Date**: 2026-07-03

### Context

By C-5.0.5, YOLO11 can stably recognize the bottle target in the end-camera image. The arm still carries a camera and Servo003/pitch remains mechanically sensitive, so the first closed-loop tracking stage must be smaller than a full yaw+pitch loop.

### Decision

Use `bottle` as the only target class and control only Servo000 yaw:

- `target_selector.track_class = bottle`
- `visual_servo.control_axes = [yaw]`
- `driver.stop_servo_indices = [0]`
- runtime command should include `--control_axes yaw`
- for yaw-only smoke tests, include `--prepare_pose false` when the arm is already in the saved safe pose

Servo003 pitch remains frozen until yaw direction, yaw gain, dead zone, and target-centering behavior are verified.

### Evidence

- CleanScout main commit `b8009323`.
- `docs/VERIFY/C-5.0.5_arm_bottle_yaw_tracking.md`.
- Board-side smoke on 2026-07-03 showed pure bottle detection, yaw-only dry-run frames emitting only `#000P...T0200!`, and a short real yaw-only run ending with `#000PDST!`.

## Decision: C-5.0.6 adds Servo001 lift-only tracking before Servo003 pitch

**Status**: accepted
**Date**: 2026-07-03

### Context

C-5.0.5 proved `bottle` recognition and Servo000 yaw-only tracking. The arm is currently held in a manually tuned posture where Servo001/002 make the 12/23 chain lean back, Servo003 keeps 34 near horizontal, and the camera/center of mass stay closer to the base. Moving Servo003 too early risks pointing the camera upward or overloading the end section again.

### Decision

Add a separate logical axis `lift` mapped only to Servo001. For `--control_axes lift`, the tracker sends only Servo001 commands and stops only Servo001. Servo002/003/004/005 are not re-commanded by the tracking loop, preserving the safe pose. Servo003 `pitch` remains reserved for the next stage, where it should adjust the 34 end-effector angle rather than lift the whole arm.

### Evidence

- CleanScout main commit `4fe29bdf`.
- `docs/VERIFY/C-5.0.6_arm_bottle_lift_tracking.md`.
- Board-side checks on 2026-07-03: py_compile passed, lift dry-run and real-run emitted only `#001...`, synthetic vertical-error tests produced opposite Servo001 PWM outputs, and yaw-only dry-run still emitted only `#000...`.

## Decision: C-5.0.7 adds Servo003 pitch-only tracking before multi-axis coordination

**Status**: accepted
**Date**: 2026-07-03

### Context

C-5.0.5 validated Servo000 yaw-only tracking and C-5.0.6 validated Servo001 lift-only tracking. The user then asked how `lift` and `pitch` should combine, because both affect target vertical position. The important distinction is mechanical: Servo001 changes the whole arm posture and load distribution, while Servo003 changes the 34 end-effector/camera angle.

### Decision

Validate Servo003 as a separate `pitch` axis before combining axes. For `--control_axes pitch`, the tracker sends only Servo003 commands and stops only Servo003. Future multi-axis vertical control should not let Servo001 and Servo003 both chase the same `err_y` equally. Servo003 should handle fast/small camera-view corrections; Servo001 should only provide slow/coarse posture correction for sustained vertical bias or Servo003 range limits.

### Evidence

- CleanScout main commit `001e08f9`.
- `docs/VERIFY/C-5.0.7_arm_bottle_pitch_tracking.md`.
- Board-side checks on 2026-07-03: py_compile passed, pitch dry-run and real-run emitted only `#003...`, synthetic vertical-error tests produced opposite Servo003 PWM outputs, yaw-only dry-run still emitted only `#000...`, and lift-only dry-run still emitted only `#001...` when run sequentially. C-5.0.7A then corrected the live pitch direction by changing only `visual_servo.invert_pitch` from `true` to `false`; `driver.pitch_pwm_sign` remains `-1`.

## Decision: C-5.0.8 combines yaw, lift, and pitch with pitch-first vertical control

**Status**: accepted
**Date**: 2026-07-06

### Context

C-5.0.5/C-5.0.6/C-5.0.7 separately proved Servo000 yaw, Servo001 lift, and Servo003 pitch. The user then requested a first combined tracker. The known mechanical risk is that Servo001 and Servo003 both affect the target's vertical image position, but Servo001 moves the whole arm/load while Servo003 only changes the end camera angle.

### Decision

Enable `visual_servo.control_axes = [yaw, lift, pitch]`, but do not let lift and pitch chase `err_y` equally:

- Servo000 yaw always follows horizontal error.
- Servo003 pitch follows vertical error every control tick as the fine/fast axis.
- Servo001 lift only joins when `abs(err_y) >= 90px`.
- Servo001 lift is rate-divided by `combined_lift_rate_divider = 4`, so it is a slow/coarse posture correction.
- `yolo_arm_track.py` uses `command_axes` so the command bundle normally contains 000/003, and includes 001 only on coarse-correction ticks.
- Stop commands cover only the active combined axes: 000/001/003.

### Evidence

- CleanScout main commit `b5b0fb5c`.
- C-5.0.8A follow-up commit `6af4fd8d` keeps the no-config stop fallback aligned with `[0,1,3]`.
- `docs/VERIFY/C-5.0.8_arm_bottle_combined_tracking.md`.
- Board-side checks on 2026-07-06: py_compile passed, YAML readback showed `[yaw, lift, pitch]`, board synthetic test emitted 000/003 on ticks 1-3/5-7 and 000/001/003 on ticks 4/8, `bottle` dry-run opened camera/RKNN but had no target in the short window, and `any` dry-run produced real detection-driven 000/003 command bundles without invoking 001 because vertical error stayed below threshold.

## Decision: C-5.0.9 uses a fixed startup pose and metrics-based response tuning

**Status**: accepted
**Date**: 2026-07-06

### Context

The live three-axis tracker worked, but startup could move the arm to an unexpected posture and the visual servo felt slow, abrupt, and shaky. The user provided a manually verified safe pose:

```text
0=1500,1=1907,2=1900,3=900,4=1500,5=1500
```

### Decision

- Three-axis tracking should prepare the arm with the above pose before real tracking unless explicitly disabled.
- Use `tools/arm_tracking_response_test.py` for repeatable tuning: standard pose -> small 000/001/003 perturbation -> run tracking -> write `metrics.jsonl`, `summary.json`, and `score.json`.
- For scoring, compare final error, mean error, sign changes, and target-frame ratio. Do not rely only on subjective video comments.
- Keep Servo003 direction as `invert_pitch=false` plus `driver.pitch_pwm_sign=-1`; a brief accidental change to `pitch_pwm_sign=1` was reverted after user correction.

### Evidence

- `docs/VERIFY/C-5.0.9_arm_tracking_start_pose_response_tuning.md`.
- Board readback on 2026-07-06: `pitch_pwm_sign=-1`, `invert_pitch=False`, standard pose `{0:1500,1:1907,2:1900,3:900,4:1500,5:1500}`.
- First response run: `~/rk3588_ai/debug_logs/arm_tracking_eval/20260706-173340/score.json`, score `347.8311`, sign changes x/y `6/8`.
- Second response run after conservative smoothing: `~/rk3588_ai/debug_logs/arm_tracking_eval/20260706-173547/score.json`, score `188.4431`, sign changes x/y `1/3`.
