# 08 Onboarding From Zero

## First 30 Minutes

1. Clone or locate the canonical source:

```powershell
git clone https://github.com/Git-ys1/CleanScout_rover.git <yusu-local-path>
$env:CLEANSCOUT_VUE3_ROOT='<yusu-local-path>\vue3'
cd $env:CLEANSCOUT_VUE3_ROOT
```

2. Read these in order:

- `README.md`
- `docs/deployment.md`
- `backend/.env.example`
- `deploy/env/vline-backend.public-edge.env.example`
- `docs/camera-mjpeg-stream.md`
- `docs/releases/V-2.1.0/README.md`

3. Memorize the core boundary:

```text
frontend -> backend -> adapter/worker -> device or local gateway
```

4. Do not use the HDS path as executable path. It is evidence only.

## First Day

1. Start local H5:

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT
cmd /c npm.cmd install
cmd /c npm.cmd run dev:h5
```

2. Start local backend:

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT\backend
cmd /c npm.cmd install
cmd /c npm.cmd run prisma:generate
cmd /c npm.cmd run prisma:migrate
cmd /c npm.cmd run prisma:seed
cmd /c npm.cmd run dev
```

3. Run the public-edge local helper when testing Pi edge-relay:

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT
cmd /c npm.cmd run local:edge
```

4. Verify cloud backend only through health/status endpoints and deployed revision, not assumptions.

## Minimal Working Loop

Use this loop before changing logic:

1. Confirm source path:
   - `%CLEANSCOUT_VUE3_ROOT%` points to local `CleanScout_rover\vue3`.
2. Confirm frontend build:
   - `cmd /c npm.cmd run build:h5:production`
   - `cmd /c npm.cmd run build:mp-weixin:production`
3. Confirm backend health:
   - local `/api/system/health`
   - cloud `https://api.hzhhds.top/api/system/health`
4. Confirm deployed revision:
   - `cat /opt/vline-backend/backend/.deploy-revision`
5. Confirm the relevant worker:
   - Pi: `/edge/ros`
   - OpenClaw: `/ws/agents`
   - Camera: `/edge/camera`

## Common Newcomer Traps

1. Treating vue3 as frontend-only and editing around backend boundaries.
2. Letting frontend directly connect robot/Gateway/camera for quick wins.
3. Assuming HDS path exists on yusu Windows.
4. Treating token env values as enough when DB hash or running service is stale.
5. Running Prisma CLI before loading `DATABASE_URL`.
6. Confusing mini-program legal domains with backend CORS.
7. Adding cloud-side realtime loops instead of local Pi/ROS loops.
8. Optimizing ESP32-CAM FPS constants before verifying raw stream transport.
9. Embedding OpenClaw Dashboard instead of routing capability through backend.

## If Rebuilding From Scratch

1. Clone `Git-ys1/CleanScout_rover`, then set `%CLEANSCOUT_VUE3_ROOT%` / `$CLEANSCOUT_VUE3_ROOT`.
2. Bring up backend auth/admin/system config first.
3. Bring up frontend login/home/chat/admin with backend health checks.
4. Add ROS adapter mock, then local rosbridge.
5. Add public-edge `/edge/ros` only after local-lan is understood.
6. Add deployment bootstrap/check/update before treating VPS as production.
7. Add OpenClaw PC worker as chat-only capability, not dashboard embedding.
8. Add ESP32-CAM camera worker as raw MJPEG tunnel, with snapshot fallback.
9. Only after stable chat/status/stream should navigation executor and structured OpenClaw actions be added.
