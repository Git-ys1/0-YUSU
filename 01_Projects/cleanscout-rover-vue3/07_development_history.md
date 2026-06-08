# 07 Development History

## Timeline Summary

| Stage | Dates | Representative Commits | Result |
|---|---|---|---|
| 1 | 2026-04-17 | `d014d89`, `56eb9fd`, `c409573`, `05829d2` | vue3 became V-line software subsystem, not a page-only scaffold |
| 2 | 2026-04-18 | auth/admin/OpenClaw shell commits | Backend auth, Pinia auth, admin, chat and OpenClaw placeholders became long-term anchors |
| 3 | 2026-04-18 | `40af9c2`, `17a4dfc`, `9bebbda`, `3399011` | ROS adapter and frontend/backend/ROS boundary were frozen |
| 4 | 2026-04-18 | V-1.5/V-1.6 env/profile commits | local-lan and public-cloud profiles replaced ad-hoc edits |
| 5 | 2026-04-19 to 2026-05-02 | `7383783`, `0c4f5fe`, `faa38ec`, `79e9d56`, `459109c` | `/edge/ros` public-edge and fan control converged |
| 6 | 2026-05-03 to 2026-05-19 | `12cac85`, `4e455ee`, `a911095`, `3818fac` | deployment closure, UI productization and duplicate command fix |
| 7 | 2026-05-24 to 2026-05-28 | `5e8f12e`, `8865875`, `5fba220`, `bf9cf82` | OpenClaw PC worker and ESP32-CAM raw MJPEG stream entered the architecture |

## Phase Notes

### Phase 1: 2026-04-17, project bootstrapping and system boundary

The project started as a uni-app Vue3 frontend, then quickly became a software interaction subsystem. V-1.0.1 and early README work froze the idea that V-line owns frontend, backend, and device-gateway integration docs.

The early assumption that a “frontend project” would be enough was wrong. Even the first useful UI needed backend auth, device state, deployment and protocol boundaries.

### Phase 2: 2026-04-18, auth/admin shell and OpenClaw placeholder

Backend auth, Prisma/SQLite, frontend Pinia auth, admin shell, chat shell and OpenClaw adapter appeared in quick succession. This is where backend became a permanent product component rather than a mock server.

The admin page initially carried too much device-control responsibility. Later releases moved control toward the main page and left admin for users/system switches/status.

### Phase 3: 2026-04-18, ROS adapter and deployment baseline

ROS adapter work established that frontend only calls backend `/api/ros/*`; it does not connect ROS directly. ROS/OpenClaw boundaries were documented so fixed motion/telemetry stay in ROS adapter and language/intent stays in OpenClaw adapter.

The first backend deployment/CORS work also proved that H5, mini-program and cloud domains need separate operational thinking.

### Phase 4: 2026-04-18, env-driven local/cloud profiles

V-1.5 and V-1.6 introduced runtime profiles and env templates. This was a direct response to local IP, rosbridge URL, public API and WeChat build drift.

The project learned that changing code constants for every network change was not sustainable. Profile/env became the right boundary.

### Phase 5: 2026-04-19 to 2026-05-02, edge-relay and public-edge convergence

The major architectural transition was from cloud trying to reach robot LAN to Pi actively connecting cloud backend. `/edge/ros` reused the backend HTTP server and added EdgeDevice auth.

This phase also exposed token drift, missing migration, and the difference between local mock/static success and real Pi/ROS joint debugging.

### Phase 6: 2026-05-03 to 2026-05-19, deployment closure and UI productization

First-deploy scripts and check scripts were added because manual seed/migrate verification caused cloud failures. Unified `docs/deployment.md` became the current runbook.

The UI also moved from “engineering explanation panels” to a mobile product surface. Later control-speed and duplicate command fixes showed that UX semantics and robot protocol semantics must be aligned.

### Phase 7: 2026-05-24 to 2026-05-28, OpenClaw PC Worker and ESP32-CAM stream

OpenClaw was integrated as capability through a PC worker, not by embedding Dashboard. ESP32-CAM streaming moved from snapshot and parsed frame pushing to raw MJPEG tunnel.

This phase proved a repeated architectural principle: cloud backend coordinates, while LAN-local PC/Pi agents own local capability access.

## Lessons By Stage

1. Initial frontend scaffolding should not hide backend/protocol needs.
2. Admin UI and operator/device control UI are different products.
3. ROS direct access works locally, but public cloud needs outbound relay.
4. Runtime profile/env beats hardcoded IP and domain edits.
5. Token handoff is operational state, not just a string.
6. First deployment needs seed and verification; update deployment needs revision proof.
7. OpenClaw and ESP32-CAM should be reached through trusted workers, not public frontend URLs.
8. Video stream quality must be diagnosed by comparing native source, worker path and backend path.
9. Paths in this memory are evidence paths unless routed through `$CLEANSCOUT_VUE3_ROOT`.
