# Runbook

## Rebuild The Model Zoo Baseline

On the OrangePi board or another Linux target:

```bash
cd ~/rk3588_ai
git clone https://github.com/airockchip/rknn_model_zoo.git rknn_model_zoo
cd rknn_model_zoo
git checkout bad6c73
```

From the CleanScout repo overlay:

```bash
cd OrangePi/rk3588_ai
bash scripts/apply_model_zoo_overlay.sh ~/rk3588_ai
```

## Run Image Demo

```bash
cd ~/rk3588_ai/rknn_model_zoo/examples/yolo11/python
source ~/rk3588_ai/rknn_lite_env/bin/activate
python3 yolo11.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --img_save
```

## Run Camera Demo

```bash
cd ~/rk3588_ai/rknn_model_zoo/examples/yolo11/python
source ~/rk3588_ai/rknn_lite_env/bin/activate
python3 yolo11_camera.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --width 640 \
  --height 480 \
  --fps 30 \
  --fourcc MJPG
```

## SSH To NoMachine Desktop Display

```bash
DISPLAY=:0 \
XAUTHORITY=$HOME/.Xauthority \
XDG_RUNTIME_DIR=/run/user/1000 \
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
python3 yolo11_camera.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0
```

## Headless Verification

```bash
python3 yolo11_camera.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --no_show \
  --max_frames 90 \
  --save_path ~/rk3588_ai/debug_logs/yolo11_camera/yolo11_camera_test.mp4 \
  --snapshot_path ~/rk3588_ai/debug_logs/yolo11_camera/yolo11_camera_result.jpg
```

## Run Arm Tracking Dry-Run

```bash
cd ~/rk3588_ai/arm_tracking_demo
~/rk3588_ai/rknn_lite_env/bin/python3 -m py_compile \
  arm_driver.py target_selector.py visual_servo.py yolo_arm_track.py \
  tools/scan_serial.py tools/test_arm_driver_dryrun.py \
  tools/test_one_joint_yaw.py tools/test_one_joint_pitch.py

~/rk3588_ai/rknn_lite_env/bin/python3 tools/scan_serial.py
~/rk3588_ai/rknn_lite_env/bin/python3 tools/test_arm_driver_dryrun.py --print_cmd
```

Dry-run visual pipeline:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 yolo_arm_track.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --track_class bottle \
  --control_axes yaw \
  --dry_run true \
  --enable_arm \
  --prepare_pose false \
  --print_cmd \
  --no_show \
  --max_frames 5 \
  --log_interval 1
```

C-5.0.5 real Servo000 yaw-only smoke:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 yolo_arm_track.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --track_class bottle \
  --control_axes yaw \
  --serial_port /dev/ttyUSB0 \
  --dry_run false \
  --enable_arm \
  --prepare_pose false \
  --print_cmd \
  --no_show \
  --max_frames 20 \
  --log_interval 5
```

Use `--prepare_pose false` for yaw-only tests when the arm is already in the saved safe pose; this prevents a visual tracking smoke from moving Servo001/002/003.
C-5.0.6 real Servo001 lift-only smoke:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 yolo_arm_track.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --track_class bottle \
  --control_axes lift \
  --serial_port /dev/ttyUSB0 \
  --dry_run false \
  --enable_arm \
  --prepare_pose false \
  --print_cmd \
  --no_show \
  --max_frames 20 \
  --log_interval 5
```

Use `--prepare_pose false` for lift-only tests when the arm is already in the saved safe pose. C-5.0.6 deliberately moves only Servo001; Servo002/003/004/005 keep the manually tuned posture so 23 stays near vertical and 34 near horizontal.
C-5.0.7 real Servo003 pitch-only smoke:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 yolo_arm_track.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --track_class bottle \
  --control_axes pitch \
  --serial_port /dev/ttyUSB0 \
  --dry_run false \
  --enable_arm \
  --prepare_pose false \
  --print_cmd \
  --no_show \
  --max_frames 20 \
  --log_interval 5
```

Use `--prepare_pose false` for pitch-only tests when the arm is already in the saved safe pose. C-5.0.7 deliberately moves only Servo003; do not run yaw/lift/pitch smoke tests in parallel because they compete for `/dev/video0`.
C-5.0.9 combined yaw + lift + pitch dry-run:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 yolo_arm_track.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --track_class bottle \
  --control_axes yaw,lift,pitch \
  --dry_run true \
  --enable_arm \
  --prepare_pose false \
  --print_cmd \
  --no_show \
  --max_frames 20 \
  --log_interval 5
```

C-5.0.9 combined real tracking, only when the operator is watching the arm:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 yolo_arm_track.py \
  --model_path ~/rk3588_ai/models/official_yolo11.rknn \
  --target rk3588 \
  --camera 0 \
  --track_class bottle \
  --control_axes yaw,lift,pitch \
  --serial_port /dev/ttyUSB0 \
  --dry_run false \
  --enable_arm \
  --print_cmd
```

C-5.0.9 rule: startup should first move to `0=1500,1=1907,2=1900,3=900,4=1500,5=1500`. Servo003 handles fine vertical tracking every tick; Servo001 only joins on large vertical error (`>=80px`) and at a lower rate (`combined_lift_rate_divider=4`). If the command bundle always includes 001, check `visual_servo.command_axes` handling before doing real motion tests. Keep Servo003 direction at `invert_pitch=false` and `driver.pitch_pwm_sign=-1`.

C-5.0.9 automatic response-score test:

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 tools/arm_tracking_response_test.py \
  --real \
  --no_show \
  --track_class bottle \
  --perturb_pose 0=1540,1=1887,3=930 \
  --max_frames 90 \
  --log_interval 15
```

Reference board results:

- `~/rk3588_ai/debug_logs/arm_tracking_eval/20260706-173340/score.json`: score `347.8311`.
- `~/rk3588_ai/debug_logs/arm_tracking_eval/20260706-173547/score.json`: score `188.4431` after smoother C-5.0.9 parameters.

## Remote Access

Use the existing SSH alias from cross-project tooling:

```bash
ssh opi5max
```

Current fixed portable-WiFi IP for the OrangePi is `192.168.8.148`; the Windows SSH alias `opi5max` / `orangepi5max` should point there.

Do not store or repeat the device password in the knowledge vault.
