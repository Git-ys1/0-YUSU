# ADR: edge-relay public-edge cloud transport

**Status**: accepted
**Date**: 2026-04-19

## Context

rosbridge is acceptable when frontend/backend can reach robot-side ROS on the same LAN. It fails as the cloud architecture when Pi is behind phone hotspot/lab LAN/NAT.

## Decision

Add `/edge/ros` WSS on backend and `ROS_TRANSPORT=edge-relay`. Pi-side edge-relay actively connects to backend, authenticates as an EdgeDevice, sends telemetry, and receives commands on the same long connection.

## Consequences

- Cloud backend does not need inbound access to robot LAN.
- Existing `ROS_TRANSPORT=rosbridge` remains for local LAN.
- Backend becomes shared HTTP server hosting REST + WSS.
- Device identity and token hash become production deployment concerns.
