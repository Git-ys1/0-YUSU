# 04 Progress

## Current State At Ingestion

- Latest observed HEAD: `bf9cf82 V-2.2.3`.
- Source scope: `Git-ys1/CleanScout_rover/vue3`.
- Frontend UI underwent V-1.9 product-grade design pass and later OpenClaw/OpenMV refinements.
- Backend supports shared HTTP server with REST plus three long connections:
  - `/edge/ros`
  - `/ws/agents`
  - `/edge/camera`
- Cloud deployment scripts include bootstrap/check/update split and deployed revision recording.

## Capability Status

| Capability | Status | Notes |
|---|---|---|
| Auth/admin/system config | working | Prisma SQLite + JWT + admin pages |
| Local ROS rosbridge | preserved | local-lan path for lab |
| Cloud ROS edge-relay | working | Pi actively connects to backend |
| Manual control | working with responsibility split | backend sends intent, Pi owns loop/protocol |
| Fan control | integrated | two fans, enable/PWM/RPM status |
| OpenClaw PC Worker | integrated, still quality-tuning | chat path works; display/status UX optimized in V-2.2.3 |
| ASR FunASR | shell integrated | non-streaming upload; text backfill |
| ESP32-CAM raw MJPEG | integrated, performance sensitive | raw tunnel chosen after frame parsing was too slow |
| H5/Netlify | deployed path exists | CORS requires backend env update for third-party domains |
| WeChat mini-program | production build path exists | legal request domain configured outside repo |

## Known Incomplete Areas

- OpenClaw response quality and streaming UX need future work; current worker path is not true token streaming.
- ESP32-CAM live stream performance depends on raw tunnel and network; avoid re-parsing/re-encoding unless necessary.
- pc-ros-executor / navigation action execution is intentionally deferred after OpenClaw chat bridge.
- Credential rotation and device management UI are not fully productized.
