# Known Issues

## Issue: RKNN Runtime version string can lie if the binary is corrupt

A damaged `/usr/lib/librknnrt.so` still showed version 2.3.2 via `strings`, but was 28 bytes shorter than the official file and segfaulted on `ctypes.CDLL`. Always verify file integrity, not just version strings.

## Issue: `librknn_api.so` is easy to confuse with `librknnrt.so`

A legacy `librknn_api.so` existed, but LD_DEBUG showed the Python Lite2 path loaded `librknnrt.so`. Do not install random RKNPU1 `librknn_api.so` over RK3588 runtime files.

## Issue: torch late import can fail only inside the YOLO script

`import torch` alone may succeed, while `cv2 -> RKNNLite -> torch` fails with static TLS / libgomp. The fix was NumPy DFL, not global `LD_PRELOAD` in `.bashrc`.

## Issue: `/dev/video1` can be metadata, not a camera stream

On this board `/dev/video0` is the real UVC Video Capture node, while `/dev/video1` is metadata. Camera scripts must auto-fallback and print actual node/backend/fourcc.

## Issue: `pyserial` is not installed in the RKNN Lite venv yet

C-5.0.1 dry-run works without pyserial because `ArmDriver` imports `serial` only in real-output mode. Real arm output must first install/confirm pyserial in `~/rk3588_ai/rknn_lite_env` and then use `tools/scan_serial.py`.

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
