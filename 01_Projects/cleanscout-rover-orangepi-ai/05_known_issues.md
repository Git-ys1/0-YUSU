# Known Issues

## Issue: RKNN Runtime version string can lie if the binary is corrupt

A damaged `/usr/lib/librknnrt.so` still showed version 2.3.2 via `strings`, but was 28 bytes shorter than the official file and segfaulted on `ctypes.CDLL`. Always verify file integrity, not just version strings.

## Issue: `librknn_api.so` is easy to confuse with `librknnrt.so`

A legacy `librknn_api.so` existed, but LD_DEBUG showed the Python Lite2 path loaded `librknnrt.so`. Do not install random RKNPU1 `librknn_api.so` over RK3588 runtime files.

## Issue: torch late import can fail only inside the YOLO script

`import torch` alone may succeed, while `cv2 -> RKNNLite -> torch` fails with static TLS / libgomp. The fix was NumPy DFL, not global `LD_PRELOAD` in `.bashrc`.

## Issue: `/dev/video1` can be metadata, not a camera stream

On this board `/dev/video0` is the real UVC Video Capture node, while `/dev/video1` is metadata. Camera scripts must auto-fallback and print actual node/backend/fourcc.

## Resolved: `pyserial` was missing from the RKNN Lite venv

C-5.0.1 initially worked only in dry-run because `pyserial` was absent. On
2026-06-11 the RKNN environment successfully imported `serial`, opened
`/dev/ttyUSB0`, sent real commands, and read bus-servo replies.

## Issue: do not assume ROS2 `0x90` binary frames are the current arm firmware protocol

The reference RaspberryPi ROS2 project has `car_base.cpp` binary frames (`0x80`/`0x90`), but the current frozen STM32 mechanical-arm baseline parses official PWM text commands such as `#000P1500T0200!`. C-5.0.1 therefore defaults to the text protocol and leaves binary frames disabled.

## Issue: official all-stop command path needs firmware review

The official STM32 arm baseline exposes `$DST!`, but its `pwmServo_stop_motion(255)` branch appears to use `pwmServo_angle[index]` while `index == 255`, which is an out-of-range access. C-5.0.1 avoids this by sending single-servo stop commands for Servo0/Servo3 during the demo. Review or patch firmware before relying on global stop.

## Issue: videos and debug logs grow fast

Do not commit `debug_logs/` or `.mp4` validation artifacts. Keep reports and selected small screenshots in Git.

## Issue: publishing full RKNN Model Zoo makes ownership blurry

The full upstream repo belongs to `airockchip`. CleanScout owns the overlay and reports. Commit upstream source only if deliberately forking; otherwise clone from official Git and apply overlay.

## Issue: do not store device password in memory

The JSONL includes initial access context, but the KB must not preserve passwords. Use SSH alias and key-based access notes only.

## Issue: mechanical-arm work must start from the bus-servo table and A1 vision-to-serial reference

For CleanScout C-5.x mechanical-arm work, do not start by describing the arm as a generic PWM-servo-only system, and do not jump first to the ROS2 `0x80/0x90` binary-frame reference.

Default lookup order:

1. Read `F:\Project\CleanScout_rover\docs\001-总线舵机资料\1.使用手册\附件1《总线舵机指令表》.docx`.
2. Read the A1/Yeahbot visual-recognition-to-serial arm example before designing the tracking loop. Even if that reference is ROS2, the useful pattern is still: vision detection -> target error -> serial command -> arm movement.
3. Then inspect the current CleanScout implementation under `OrangePi/rk3588_ai/arm_tracking_demo/` and the frozen STM32 baseline under `firmware/mechanical_arm_official_baseline/`.

Current verified command layer is bus-servo-style ASCII text:

- single motion: `#000P1500T1000!`
- single stop: `#000PDST!`
- multi-servo bundle: `{#000P1500T1000!#001P1500T1000!}`

2026-06-11 live result:

- `/dev/ttyUSB0` is the working CH340 path.
- Servo000/001/002 returned version and position data.
- Servo003/004/005 did not return bus data in the current wiring state.
- The official STM32 firmware simultaneously forwards commands to UART buses
  and drives six local software-PWM outputs.
- Servo003 motion was verified by end-camera image displacement even without
  a `PRAD` response.
- Two processes can otherwise open the same Linux tty and split replies.
  `ArmDriver` and `bus_servo_probe.py` now request exclusive serial ownership.

Do not collapse these facts into either "all six are readable bus servos" or
"the protocol is only PWM". The command layer is the vendor bus-servo ASCII
protocol; the current STM32 baseline adapts it to both bus forwarding and
local PWM execution.

Evidence:

- `docs/001-总线舵机资料/1.使用手册/附件1《总线舵机指令表》.docx`
- `firmware/mechanical_arm_official_baseline/User/Components/y_global/y_global.c`
- `firmware/mechanical_arm_official_baseline/User/Components/y_usart/y_usart.c`
- `OrangePi/rk3588_ai/arm_tracking_demo/tools/bus_servo_probe.py`
- User correction on 2026-06-11: always remember the bus-servo command table and A1 visual-to-serial arm example.
