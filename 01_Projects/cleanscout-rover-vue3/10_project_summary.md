# 10 Project Summary

## One-Page Summary

CleanScout Rover 前后端 is the V-line software interaction system for a robot project. It provides uni-app Vue3 UI, Express/Prisma backend, public-edge ROS relay, OpenClaw PC worker bridge, ESP32-CAM stream relay, ASR adapter, deployment scripts, and release documentation.

Its core stance is consistent: frontend is product UI only; backend is the control/coordination boundary; robot/PC agents actively connect to cloud rather than expecting cloud to reach LAN devices.

## Most Important Things

| Priority | Thing | Why It Matters |
|---|---|---|
| 1 | Do not let frontend directly connect robot/Gateway/camera | Prevents auth leaks, CORS chaos, and NAT failures |
| 2 | public-edge uses outbound device connections | Phone hotspot/lab LAN makes inbound cloud access unreliable |
| 3 | Backend sends intent, local devices run realtime loops | Public internet is not a safe 50Hz control loop |
| 4 | OpenClaw is capability, not product UI | Dashboard is high-privilege management surface |
| 5 | ESP32-CAM stream should preserve raw MJPEG when possible | Parsing/repacking killed practical FPS |
| 6 | Deployment scripts must load env and record revision | Otherwise cloud update claims are unverifiable |
| 7 | Use a logical vue3 root env var | 0-YUSU will return to yusu Windows; `%CLEANSCOUT_VUE3_ROOT%` / `$CLEANSCOUT_VUE3_ROOT` must point to the local checkout |

## Final Shape

- Frontend: CleanScout product UI across H5/mini-program/App.
- Backend: Express REST + shared HTTP WebSocket upgrades.
- Pi: `pi-edge-relay` for ROS/fan/device commands and telemetry.
- UbuntuPC: `pc-openclaw-worker` and `pc-camera-worker`.
- Cloud: public-edge backend with domain/API, deployment scripts, and CORS for H5/frontends.

## Hard-Won Lessons

- NAT is an architecture constraint, not a troubleshooting footnote.
- Seed/migration ordering must be scripted for first deployment.
- Token drift is a full-chain state issue: env, DB hash, whitelist, running service and device launch all matter.
- A single UI click can become two robot commands if press/release semantics are not explicit.
- Long-lived streams cannot be treated as normal fetch requests with short timeout.
- Product UI and developer dashboards must stay separate.

## Rules For Future Codex

1. Before modifying protocol logic, inspect whether responsibility belongs to frontend/backend, Pi edge-relay, UbuntuPC worker, or lower controller.
2. Never write token values into repo or 0-YUSU even if the user shares them during fast development.
3. Treat `docs/deployment.md` as the current operations entry; historical release docs are evidence, not always current instructions.
4. For cloud update questions, verify both repo HEAD and deployed `.deploy-revision`.
5. For video performance, compare native ESP32-CAM page to backend stream before changing frame rate constants.
6. On yusu Windows, clone/locate `Git-ys1/CleanScout_rover\vue3`, set `%CLEANSCOUT_VUE3_ROOT%`, and do not use HDS evidence path as executable path.

## Memory Routing Audit

| Memory | Route | Notes |
|---|---|---|
| CleanScout project architecture/history/runbooks | project-only | Stored under `01_Projects/cleanscout-rover-vue3` |
| Outbound worker/relay behind NAT | cross-project pattern | Added to `03_CrossProject/patterns.md` |
| Backend env before Prisma / deployed revision | cross-project tooling | Added to `03_CrossProject/tooling.md` |
| UI click duplicated as device toggle | cross-project pitfall | Added to `03_CrossProject/pitfalls.md` and pitfall map |
| Raw MJPEG tunnel for smooth display | cross-project architecture/tooling | Added to architecture decisions and tooling |
| HDS/yusu path remapping | project + map note | Added to project README/onboarding/summary |
| Actual secret/token values | rejected | Must not enter vault |

## Remaining Risks

- The lower-machine / ROS memory is maintained separately; future cross-linking should be added when that entry is published.
- OpenClaw response quality and true streaming remain future work.
- Camera worker performance needs real-network validation after each architecture change.
