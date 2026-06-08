# ADR: OpenClaw PC worker instead of dashboard embedding

**Status**: accepted
**Date**: 2026-05-24

## Context

OpenClaw Gateway and Dashboard provide powerful operator/control surfaces. Exposing them directly to users or frontend would bypass CleanScout account, permission, and device-state controls.

## Decision

Use CleanScout frontend for chat UI. Cloud backend exposes `/api/openclaw/chat` and `/api/openclaw/status`, then routes requests to `pc-openclaw-worker` over `/ws/agents`. Worker calls local OpenClaw Gateway.

## Consequences

- Gateway token stays on UbuntuPC.
- Cloud backend needs agent registry, request correlation, timeout handling, and status reporting.
- First phase is chat only; ROS action execution is deferred to a later PC executor.
