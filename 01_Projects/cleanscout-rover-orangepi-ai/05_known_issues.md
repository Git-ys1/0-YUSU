# Known Issues

## Issue: a passing fixed-view camera matrix is not a calibrated arm

C-5.2.4 accepted `T_base_camera_reference` at the fixed pose with 5.848 mm RMSE and 9.710 mm maximum point error. This validates camera optical points in the arm-base frame only. It does not validate link-axis distances, the gripper TCP, or the physical-angle-to-PWM map.

Before real PRE_GRASP, Servo000--003 still need direction, physical zero, PWM-per-angle scale, and safe-limit evidence; Servo005 needs accepted open/contact/close values. Keep `kinematics.calibrated=false` and `serial.joint_pwm_calibrated=false` until that evidence exists. Do not tune a bottle-location-specific PWM tuple as a substitute.

## Issue: D435 factory extrinsics are not the arm hand-eye transform

The D435 already stores RGB/left-IR/right-IR/depth calibration, and librealsense uses it for `rs.align(rs.stream.color)`. Do not ask the operator to re-measure this internal camera calibration.

The missing transform is external: `T_tool_camera_color_optical`, created by the physical bracket between the RGB optical center and the gripper TCP. It must be calibrated after the final bracket is locked.

## Issue: the camera and TCP are separated by Servo004

The D435 is fixed to the non-rotating Servo004 stator housing, while the TCP is on the Servo004 rotor/Servo005 side. Therefore `T_tool_camera` depends on Servo004 angle. C-5.2.0B permits a constant matrix only with Servo004 fixed at PWM 1500; future wrist rotation requires an explicit `q4` transform chain.

## Issue: official `$KMS` is not a complete grasp controller

Official `$KMS` controls only Servo000--003 and chooses its own deepest valid Alpha. It does not control Servo004/005, define a physical TCP, provide forward kinematics, return structured reachability ACKs, detect collisions, or verify a grasp. Keep 004/005 stages and perception/safety logic outside the firmware IK wrapper.

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

## Resolved: mixed RealSense Python/runtime versions caused false RGB-D failures

The OrangePi RKNN venv previously used `pyrealsense2 2.55.1` while the system
runtime was librealsense 2.56.5. Depth-only operation could work, but aligned
RGB-D frequently timed out or left USB/UVC errors. The validated path is an
isolated 2.56.5 RSUSB build for both `librealsense2` and `pyrealsense2`, enabled
with `source ~/rk3588_ai/scripts/use_realsense_rsusb.sh`.

Do not reintroduce a default 0.17/0.18 m minimum or 4.0 m maximum in depth
extraction. The depth layer rejects only zero, negative, NaN, and Inf. The
hardware near capability of about 0.17 m is a device note; reachability belongs
to coordinate transforms, IK, and safety checks.

Evidence:

- `docs/001-总线舵机资料/1.使用手册/附件1《总线舵机指令表》.docx`
- `firmware/mechanical_arm_official_baseline/User/Components/y_global/y_global.c`
- `firmware/mechanical_arm_official_baseline/User/Components/y_usart/y_usart.c`
- `OrangePi/rk3588_ai/arm_tracking_demo/tools/bus_servo_probe.py`
- User correction on 2026-06-11: always remember the bus-servo command table and A1 visual-to-serial arm example.

## Issue: C-5.2.2 wrist-camera visual approach was not a successful grasp

The 2026-07-14 bottle experiment was stopped without verified grasp success. Do not describe it as a working automatic grasp baseline.

- The real STM32 accepted `$KMS` text but left Servo000--003 unchanged; direct bus-servo PWM generated from the Python official IK did move the axes.
- The first automatic plan followed the full camera-to-target 3D vector while the official IK port discarded `pitch_deg`. This produced a top-down dive instead of placing the open gripper in front of the bottle body.
- Direct PWM PRE_GRASP reduced the central D435 depth from about 0.288 m to 0.172 m, but this was only proof of motion, not proof of a valid grasp pose.
- Manual 001-forward and 003-up tuning produced a more frontal image, but no repeatable calibrated pose or bottle-off-table evidence was obtained.
- 005 read about 1112 after `P0600` and about 1897 after `P2400`; these values are ambiguous until empty endpoints, opening width, bottle diameter, and object-contact readback are calibrated.
- The session ended by sending individual `PDST` commands to Servo000--005.

The repository checkpoint is `226f10b0` and the canonical failure report is `docs/VERIFY/C-5.2.2_arm_grasp_experiment_halted.md`. Before resuming, redesign around a front-of-bottle pre-grasp pose and use an external side view or explicit bottle-bottom-off-table evidence for success verification.
