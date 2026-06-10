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

## Remote Access

Use the existing SSH alias from cross-project tooling:

```bash
ssh opi5max
```

Do not store or repeat the device password in the knowledge vault.

