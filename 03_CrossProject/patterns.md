# Cross-Project Patterns

## Template

```md
## Pattern: title
**Status**: candidate | active | deprecated
**Seen In**: project-slug, project-slug

### Use When

...

### Avoid When

...

### Notes

...
```

## Pattern: 自动化层级阶梯
**Status**: active
**Seen In**: auto-play

### Use When

用户提出 UI/游戏自动化需求，但真实流程稳定度还没有判断清楚。

### Avoid When

用户已经明确存在高分支视觉流程，且确实需要感知能力或 agent 控制。

### Notes

从能工作的最简单层级开始：

1. 固定轨迹 -> 宏录制器；
2. 少量状态 -> 带预览和日志的显式状态机；
3. 高分支视觉任务 -> 图像识别 / agent bridge。

Auto Play 证明：如果当前目标固定到足以宏回放，直接上图像识别会浪费时间和调试成本。

### Evidence

- Auto Play evidence: fixed workflow pivot from `autogame/vision.py` / `autogame/kitchen_runner.py` to `app.py -> autogame.macro_ui.main` after user confirmed MouseRecorder-style replay was sufficient.

## Pattern: Transport-protocol-acquisition-processing-UI layering
**Status**: active
**Seen In**: simple-oscilloscope

### Use When

A desktop tool needs to talk to hardware, simulators, and fake/demo data while keeping the UI responsive and testable.

### Avoid When

The task is a one-off throwaway script with no simulator, no packaging, no protocol evolution, and no GUI state complexity.

### Notes

Keep hardware/source selection in transport, bytes/frames in protocol, background reading in acquisition, domain logic in processing, and presentation in UI. Simple Oscilloscope used this to share one path across CH340 serial, TCP simulator, and `fake://` sources.

### Evidence

- Simple Oscilloscope: `docs/pc_app_architecture.md`, `pc_app/scope_app/**`, project memory `01_Projects/simple-oscilloscope/10_project_summary.md`.

## Pattern: Hardware release requires artifact plus device verification
**Status**: active
**Seen In**: simple-oscilloscope

### Use When

A release includes firmware or depends on a real board being connected during user acceptance.

### Avoid When

The deliverable is purely software and has no local hardware state.

### Notes

"Built and published hex" is not the same as "the user's board is running it." State explicitly whether flashing happened. When possible, flash and then verify the device's reported version/status through the normal protocol. For submission-facing screenshots or README evidence, prefer real hardware data when connected hardware is available; use fake/demo sources only when clearly labeled as fallback.

### Evidence

- Simple Oscilloscope V0.9.3/V0.9.4: ST-Link flash plus COM14 `ID?`/`CAP?`/`STATUS` verification.
- Simple Oscilloscope V0.9.5: README/Release screenshot was retaken from real COM14 data instead of `fake://sine`.

## Pattern: 可观察自动化 UI
**Status**: active
**Seen In**: auto-play

### Use When

用户侧自动化依赖截图、模板匹配、OCR、状态机或多区域监视，并且用户需要自己配置参照物、监视区域或动作逻辑。

### Avoid When

流程已经稳定为固定轨迹，宏录制器可以直接解决问题；此时不要为了“更智能”而增加视觉 UI 复杂度。

### Notes

可观察自动化 UI 至少要显示：

- 用户框选的区域预览；
- 当前模板或参照图预览；
- 实时或最近一次匹配置信度；
- 当前状态机步骤和下一步动作；
- 每个监视区域的一键调试截图。

Auto Play 的厨房模式暴露出这个需求：三种菜品、独立备菜区、订单识别和中断逻辑都存在时，如果没有预览和状态机可视化，用户无法判断到底是区域、模板还是逻辑错误。

### Evidence

- Project/path: `F:\Project\auto play`
- Files: `autogame/kitchen_runner.py`, `autogame/kitchen_ui.py`, `profiles/kitchen.json`, `01_Projects/auto-play/07_development_history.md`
- Date: 2026-06-04


## Pattern: Outbound relay/worker behind NAT
**Status**: active
**Seen In**: cleanscout-rover-vue3

### Use When

A cloud backend must coordinate devices or local capabilities that live behind phone hotspots, private LANs, or lab networks.

### Avoid When

The backend and device are guaranteed to be on the same trusted LAN and the device exposes a stable inbound service.

### Notes

Have the device/PC side actively connect to cloud over WebSocket, then multiplex registration, heartbeat, requests, and results on that connection. CleanScout uses this for Pi ROS edge-relay, OpenClaw PC worker, and ESP32-CAM camera worker.

### Evidence

- Project: `cleanscout-rover-vue3`
- Source: `Git-ys1/CleanScout_rover/vue3`
- Files: `docs/releases/V-1.7.0/README.md`, `docs/releases/V-2.1.0/README.md`, `docs/camera-mjpeg-stream.md`
