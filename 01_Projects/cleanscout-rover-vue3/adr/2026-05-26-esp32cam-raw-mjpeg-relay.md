# ADR: ESP32-CAM raw MJPEG relay through UbuntuPC

**Status**: accepted
**Date**: 2026-05-26

## Context

Snapshot refresh was not enough for product display. ESP32-CAM native page streamed smoothly in LAN, but parsed/repacked worker/backend paths reduced practical FPS.

## Decision

Use UbuntuPC camera worker to pull ESP32-CAM MJPEG and push raw stream to backend `/edge/camera`. Backend exposes `/api/integrations/openmv/stream` as MJPEG relay. Snapshot remains fallback.

## Consequences

- H5 can display with a normal image element.
- Backend must treat stream as long-lived and disable buffering/short timeouts.
- Backend should not queue history or write frames to disk.
- Mini-program/App can keep snapshot fallback if multipart MJPEG support is weak.
