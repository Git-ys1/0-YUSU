# CleanScout Rover OrangePi AI

## Metadata

- Project Name: CleanScout Rover OrangePi AI
- Project Slug: `cleanscout-rover-orangepi-ai`
- Primary Repo Path: `F:\Project\CleanScout_rover\OrangePi`
- Board Path: `~/rk3588_ai`
- OS/Environment: Orange Pi 5 Max 8GB, RK3588, Ubuntu 20.04.6, Windows repository publishing
- Main Stack: RKNN Runtime, RKNNLite, RKNN Model Zoo, YOLO11, OpenCV, USB camera
- Last Updated: 2026-06-10
- Session Evidence: `F:\!TemPorary_Workshop\rollout-2026-06-09T19-16-43-019eac19-5a6e-7d80-baf1-e63e222842a7.jsonl`

## Scope

这份项目记忆只覆盖 CleanScout_rover 的 OrangePi / RK3588 AI 感知线。它与 `Raspberrypi/` 同属边缘计算开发板，但当前不负责 ROS 导航，也不负责 STM32 下位机烧录。

当前纳入范围：

- RK3588 NPU / RKNN Runtime 2.3.2 修复与验证
- 官方 YOLO11 RKNN 图片检测 demo 修复
- USB 摄像头实时 YOLO11 检测脚本
- 上游 RKNN Model Zoo v2.3.2 + CleanScout overlay 发布纪律

## Quick Links

- [[00_project_brief]]
- [[01_architecture]]
- [[02_runbook]]
- [[03_decisions]]
- [[04_progress]]
- [[05_known_issues]]
- [[06_todo_next]]
- [[07_development_history]]
- [[09_session_evidence]]
- [[10_project_summary]]

## One Sentence

OrangePi AI 线已经完成 RK3588 NPU 基线救火：修复损坏 RKNN Runtime、打通 YOLO11 RKNN 图片检测，并新增 USB 摄像头实时检测窗口，后续可作为机械臂视觉入口继续开发。

