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

The first tracking loop remains Servo000 yaw plus Servo003 wrist pitch.
Servo001/002 caused much larger main-arm motion and are not substitutes for
the fine tracking axis.
