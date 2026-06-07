# 00 Project Brief

## 项目定位

CleanScout Rover 前后端是 CSR 项目的 V 线软件交互系统，覆盖用户界面、账户权限、后端 REST/WS、云端部署、设备接入与联调文档。它不是纯前端，不应被理解为“vue3 页面仓”。

## 系统目标

- 让 H5 / 小程序 / App 通过统一前端控制 CleanScout。
- 让云端 backend 成为账户、权限、状态缓存、设备指令分发、OpenClaw 对话与图传转发的中心。
- 让车端或 PC 侧主动连接云端，解决热点/局域网/NAT 下云端无法主动访问内网设备的问题。
- 保持业务 UI 自主，不嵌入 OpenClaw Dashboard 或其他高权限控制台。

## 当前主线能力

- uni-app Vue3 前端：登录、首页控制台、对话页、个人中心、管理员页、OpenMV/ESP32-CAM 前视。
- Express backend：auth/admin/chat/ros/openclaw/asr/openmv/system API。
- ROS edge-relay：`frontend -> backend <- /edge/ros <- pi-edge-relay -> ROS`。
- 风机/底盘：backend 发送速度意图和风机命令，树莓派负责本地 50Hz 与底层协议。
- OpenClaw PC worker：`frontend -> backend <- /ws/agents <- pc-openclaw-worker -> local OpenClaw Gateway`。
- ESP32-CAM 图传：`ESP32-CAM -> UbuntuPC pc-camera-worker -> /edge/camera -> backend -> /api/integrations/openmv/stream -> H5`。
- FunASR：整段录音上传识别，结果回填聊天输入框，不自动执行控制。

## 当前证据

- Canonical repo: `Git-ys1/CleanScout_rover`, scope `vue3/`.
- HDS-side evidence path: `F:\Project\CSc——uniapp\vue3`.
- Project README defines V 线 as `前端端 + 后端端 + 设备网关端`.
- `backend/src/server.js` attaches shared HTTP server upgrades for edge-relay, agent WS, and camera ingest.
- `docs/deployment.md` is the unified deployment and operations entry after V-1.8.9.
- Current observed HEAD during ingestion: `bf9cf82 V-2.2.3`.

## Non-Goals

- 不在前端直连 ROS / Gateway / ESP32-CAM。
- 不在云端 backend 持有 OpenClaw Gateway token。
- 不把实时控制循环放在云端 backend。
- 不把单帧 snapshot 当正式图传主链路。
- 不把研发说明文案作为产品 UI。
