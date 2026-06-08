# 01 Architecture

## Top-Level Shape

```text
H5 / 小程序 / App
  -> backend REST / HTTP stream
  <- backend status / chat / telemetry

backend
  -> SQLite / Prisma / JWT / SystemConfig
  <- WSS /edge/ros from Raspberry Pi edge-relay
  <- WSS /ws/agents from UbuntuPC pc-openclaw-worker
  <- WSS /edge/camera from UbuntuPC pc-camera-worker

Raspberry Pi / ROS
  -> edge-relay outbound WSS
  -> ROS topics / cmd_vel / fans / telemetry

UbuntuPC
  -> OpenClaw Gateway on localhost
  -> ESP32-CAM MJPEG source in phone hotspot LAN
```

## Frontend

- Framework: uni-app Vue3 CLI.
- State: Pinia stores for auth, chat, device, ROS, fans, admin.
- API: `uni.request` against `VITE_API_BASE_URL`.
- Production H5: Netlify custom domain and netlify.app domain; backend CORS must include both if used.
- Mini-program: build target `dist/build/mp-weixin`, legal domain configured in WeChat console.

Key pages: 首页、对话、管理后台、个人中心、OpenMV/ESP32-CAM 前视详情。

## Backend

Backend is Express + shared Node HTTP server:

- `backend/src/app.js`: Express app and REST routes.
- `backend/src/server.js`: runtime env, HTTP server, WebSocket upgrades.
- Prisma + SQLite: user/system config/cache/edge device state.
- Runtime profiles: `mock`, `local-lan`, `public-edge`.

Important namespaces: `/api/auth`, `/api/admin`, `/api/chat`, `/api/ros`, `/api/openclaw`, `/api/asr`, `/api/integrations/openmv`, `/api/system`。

## ROS / edge-relay

Transport choices:

- `mock`: no real ROS.
- `rosbridge`: local LAN direct bridge, preserved for lab testing.
- `edge-relay`: public-edge cloud transport.

Public-edge chain:

```text
frontend -> backend REST
backend <- WSS /edge/ros <- pi-edge-relay
pi-edge-relay -> ROS topics / local nodes
```

Backend sends speed intent (`vx / vy / wz / holdMs`) and fan operations. It does not decide whether RF1 lower controller uses `W` open-loop or `M` closed-loop protocol. That conversion is Raspberry Pi / ROS-side responsibility.

## OpenClaw PC Worker

Decision: do not expose OpenClaw Dashboard or Gateway to frontend.

```text
frontend /api/openclaw/chat
  -> backend
  -> pending request over /ws/agents
  -> pc-openclaw-worker
  -> http://127.0.0.1:18789/v1/chat/completions
  -> result over /ws/agents
  -> frontend message
```

Cloud backend stores only the worker shared secret. OpenClaw Gateway token stays on UbuntuPC `.env`.

## ESP32-CAM MJPEG

V-2.2.2 changed this from frame parse/repack to raw MJPEG tunnel:

```text
ESP32-CAM /stream
  -> pc-camera-worker raw-mjpeg upstream
  -> WSS /edge/camera
  -> backend raw relay
  -> GET /api/integrations/openmv/stream
  -> H5 img
```

Backend must not write frames to disk/database or queue historical frames.

## ASR

ASR is outside OpenClaw:

```text
frontend recording -> /api/asr/transcribe -> FunASR service -> text -> input box
```

User must still click send; ASR does not trigger robot actions.
