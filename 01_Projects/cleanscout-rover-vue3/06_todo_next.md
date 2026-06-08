# 06 TODO Next

## High Priority

1. On yusu Windows, checkout `Git-ys1/CleanScout_rover` and map this memory's HDS path to the yusu-local `vue3/` path.
2. Verify latest cloud backend revision after any V-line release using `.deploy-revision` and `/api/system/health`.
3. Keep OpenClaw PC worker as background service on UbuntuPC, with explicit status and no operator waiting on a foreground terminal.
4. Improve OpenClaw chat UX toward apparent streaming without changing worker protocol if true streaming is not yet available.
5. Continue optimizing ESP32-CAM raw MJPEG path; treat source stream as authoritative if ESP32-CAM native page is smooth.

## Medium Priority

1. Add pc-ros-executor only after OpenClaw chat bridge is stable.
2. Separate navigation actions from device actions:
   - navigation: UbuntuPC / ROS executor
   - device operations: Pi edge-relay
3. Add explicit worker/systemd runbooks for UbuntuPC OpenClaw and camera workers.
4. Verify small-program MJPEG support; keep snapshot fallback if unsupported.
5. Reconcile local branch naming with current main to reduce confusion during future ingestion.

## Evidence Gaps

- Actual deployed VPS state changes after V-2.2.3 were discussed in chat, but this memory records repo evidence and user-visible commands only.
- Lower-machine/ROS project memory lives elsewhere; this entry intentionally covers V-line frontend/backend only.
