# 06 TODO Next

## High Priority

1. Have the frontend/backend maintainer integrate the accepted `vue3/bs/` Agnes Agent/image path with the existing Vue/Express account and chat system when the product integration phase begins; PR #2 is currently a standalone localhost service.
2. On yusu Windows, checkout `Git-ys1/CleanScout_rover` and map this memory's HDS path to the yusu-local `vue3/` path.
3. Verify latest cloud backend revision after any V-line release using `.deploy-revision` and `/api/system/health`.
4. Keep OpenClaw PC worker as background service on UbuntuPC, with explicit status and no operator waiting on a foreground terminal.
5. Improve OpenClaw chat UX toward apparent streaming without changing worker protocol if true streaming is not yet available.
6. Continue optimizing ESP32-CAM raw MJPEG path; treat source stream as authoritative if ESP32-CAM native page is smooth.

## Medium Priority

1. Make `vue3/bs/setup-python.cmd` hash verification robust when launched from PowerShell 7/Codex; retain SHA-256 verification.
2. Add pc-ros-executor only after OpenClaw chat bridge is stable.
3. Separate navigation actions from device actions:
   - navigation: UbuntuPC / ROS executor
   - device operations: Pi edge-relay
4. Add explicit worker/systemd runbooks for UbuntuPC OpenClaw and camera workers.
5. Verify small-program MJPEG support; keep snapshot fallback if unsupported.
6. Reconcile local branch naming with current main to reduce confusion during future ingestion.

## Evidence Gaps

- Actual deployed VPS state changes after V-2.2.3 were discussed in chat, but this memory records repo evidence and user-visible commands only.
- Lower-machine/ROS project memory lives elsewhere; this entry intentionally covers V-line frontend/backend only.
