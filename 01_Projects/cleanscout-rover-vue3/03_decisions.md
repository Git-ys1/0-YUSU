# 03 Decisions

## Decision: keep frontend behind backend

**Status**: accepted
**Date**: 2026-04-17 onward

Frontend never directly connects to Raspberry Pi, ROS master, OpenClaw Gateway, or ESP32-CAM. Auth, CORS, device identity and audit stay centralized in backend.

## Decision: preserve rosbridge but add edge-relay

**Status**: accepted
**Date**: 2026-04-19

`ROS_TRANSPORT=rosbridge` remains valid for local LAN. Public/cloud testing uses `ROS_TRANSPORT=edge-relay` because Pi/ROS often lives behind hotspot/NAT.

ADR: [[adr/2026-04-19-edge-relay-public-edge]]

## Decision: first deployment requires seed and verification

**Status**: accepted
**Date**: 2026-05-03

`update-backend.sh` remains update-only. First deployment uses `bootstrap-backend.sh` and `check-backend-state.sh` to run migrate, seed, restart and verify `admin/system/csrpi-001`.

ADR: [[adr/2026-05-03-backend-bootstrap-and-deploy-revision]]

## Decision: OpenClaw is a capability, not product UI

**Status**: accepted
**Date**: 2026-05-24

CleanScout owns the user-facing chat UI. OpenClaw Dashboard stays local/dev-only. Cloud backend talks to `pc-openclaw-worker` over `/ws/agents`; worker talks to local Gateway.

ADR: [[adr/2026-05-24-openclaw-pc-worker]]

## Decision: ESP32-CAM uses raw MJPEG tunnel through UbuntuPC

**Status**: accepted
**Date**: 2026-05-26

H5 display consumes backend MJPEG stream. UbuntuPC pulls ESP32-CAM `/stream` in hotspot LAN and pushes raw multipart MJPEG to cloud. Snapshot is fallback only.

ADR: [[adr/2026-05-26-esp32cam-raw-mjpeg-relay]]

## Decision: cloud backend does not run realtime 50Hz robot loops

**Status**: accepted
**Date**: 2026-05-19

Cloud backend sends control intent. Raspberry Pi / ROS side owns local 50Hz publishing, toggle/hold logic, and lower-controller protocol selection (`W` vs `M`).
