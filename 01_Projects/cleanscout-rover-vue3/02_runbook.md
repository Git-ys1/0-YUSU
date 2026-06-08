# 02 Runbook

## Path Rule For YUSU Side

All commands below were verified against the HDS-side checkout `F:\Project\CSc——uniapp\vue3`. On yusu Windows, first checkout `https://github.com/Git-ys1/CleanScout_rover`, then set `%CLEANSCOUT_VUE3_ROOT%` to its `vue3/` subdirectory. On Linux/macOS, use `$CLEANSCOUT_VUE3_ROOT` for the same logical path.

```powershell
git clone https://github.com/Git-ys1/CleanScout_rover.git <yusu-local-path>
$env:CLEANSCOUT_VUE3_ROOT='<yusu-local-path>\vue3'
cd $env:CLEANSCOUT_VUE3_ROOT
```

## Local Frontend / Backend

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT
cmd /c npm.cmd run local:edge
cmd /c npm.cmd run dev:h5
```

Manual backend:

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT\backend
$env:ENV_FILE="$env:TEMP\vline-backend-public-edge-local.env"
cmd /c npm.cmd run start
```

Backend development:

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT\backend
cmd /c npm.cmd install
cmd /c npm.cmd run prisma:generate
cmd /c npm.cmd run prisma:migrate
cmd /c npm.cmd run prisma:seed
cmd /c npm.cmd run dev
```

## Production Builds

```powershell
cd $env:CLEANSCOUT_VUE3_ROOT
cmd /c npm.cmd run build:h5:production
cmd /c npm.cmd run build:mp-weixin:production
cmd /c npm.cmd run build:app:production
```

## Cloud Backend

First deploy:

```bash
cd /opt/cleanscout-src/vue3
sudo bash scripts/bootstrap-backend.sh
sudo bash scripts/check-backend-state.sh
```

Update:

```bash
cd /opt/cleanscout-src/vue3
sudo bash scripts/update-backend.sh
curl -s https://api.hzhhds.top/api/system/health
cat /opt/vline-backend/backend/.deploy-revision
```

If Prisma reports `DATABASE_URL` missing, the update script or shell session did not load `/etc/vline-backend.env` before Prisma.

## Raspberry Pi / ROS Edge

Pi side uses outbound edge-relay. Record only field names in memory:

- `edge_device_id`
- `edge_device_token`
- `edge_url`
- `edge_fallback_url`

## OpenClaw PC Worker

```bash
cd vue3/tools/pc-openclaw-worker
npm ci
cp .env.example .env
npm run start
```

Required env names:

- `DEVICE_ID`
- `AGENT_ID`
- `CLOUD_WS_URL`
- `CLOUD_AGENT_TOKEN`
- `OPENCLAW_BASE_URL`
- `OPENCLAW_GATEWAY_TOKEN`
- `OPENCLAW_MODEL`

Known discrepancy: at ingestion time, worker README mentioned `npm run probe`; verify package scripts before using it.

## ESP32-CAM / pc-camera-worker

```bash
cd vue3/tools/pc-camera-worker
npm install
cp .env.example .env
npm run start
```

Mock:

```bash
npm run mock
```

Backend stream/status:

```text
GET https://api.hzhhds.top/api/integrations/openmv/stream
GET https://api.hzhhds.top/api/integrations/openmv/status
GET https://api.hzhhds.top/api/integrations/openmv/snapshot
```

## Quick Debug

- Login/API fails: check API base URL, CORS, `/api/system/health`.
- Pi relay closes: check EdgeDevice env, DB token hash, whitelist, service restart.
- OpenClaw says mock: check route mode, agent WS, worker online status, SystemConfig.
- Camera stream is slow: compare ESP32-CAM native stream and backend stream; avoid parse/repack if native is smooth.
- Cloud update looks old: inspect repo HEAD and deployed `.deploy-revision`.
