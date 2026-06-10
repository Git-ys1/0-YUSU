# Project Brief

## One Sentence

CleanScout Rover OrangePi AI 是香橙派 5 Max / RK3588 上的视觉感知基线，当前目标是稳定运行 YOLO11 RKNN，并为后续机械臂视觉抓取和 ROS 融合做准备。

## Why This Entry Exists

这条线是在 2026-06-09 从一次高压救火会话里成型的：用户已经多次尝试 NPU 失败，最终交给 Codex 远程排查。会话过程覆盖系统级 Runtime 崩溃、官方 YOLO11 demo 后处理崩溃、USB 摄像头实时显示三段连续问题。

## Current Verified Outputs

- `/usr/lib/librknnrt.so` 损坏已定位并修复，RKNN Runtime 2.3.2 可用。
- C API smoke test 可 `rknn_init ret=0`，API 2.3.2，driver 0.9.6。
- RKNNLite Python 可对 `official_yolo11.rknn` 完成推理。
- `yolo11.py` 已用 NumPy DFL 替换 late torch import，规避 libgomp static TLS。
- `yolo11_camera.py` 可通过 USB 摄像头实时显示 YOLO11 检测画面，GUI 约 17 FPS，保存视频约 12 FPS。
- CleanScout 主仓已在 commit `b78f372` 发布 `OrangePi/` 轻量基线。

## Explicit Boundaries

- 不提交完整 `rknn_model_zoo/`、venv、模型、debug logs 或视频。
- 不在知识库记录设备密码。
- 当前不接 ROS，不接机械臂动作控制，不做多线程优化。
- 官方 RKNN Model Zoo 是上游，CleanScout 只维护 overlay 和验证报告。

