# ADR: Layered PC application architecture

**Status**: accepted
**Date**: 2026-06-01
**Project Phase**: Qt refactor through V0.9.3

## Context

The upper-computer had to support fake data, TCP simulator, CH340 serial, binary frames, trigger, measurements, panels, and packaging.

## Decision

Adopt explicit layers: transport, protocol, acquisition, core buffer/models, processing, UI, storage.

## Options Considered

| Option | Pros | Cons | Outcome |
|---|---|---|---|
| Single plotting script | Fast prototype | Hard to test, hard to package, fragile UI | rejected |
| UI owns serial/protocol | Fewer files | Blocks UI and tangles responsibilities | rejected |
| Layered app | Testable and extensible | More structure | accepted |

## Consequences

- Positive: one UI can connect fake/TCP/serial; protocol tests are independent.
- Negative: changes often touch model, panel, processing, and UI signals together.
- Follow-up: keep tests for cross-layer contracts.

## Revisit Signals

Only revisit if the project is rewritten in another framework; do not collapse layers for quick fixes.

## Evidence

- Files: `docs/pc_app_architecture.md`, `pc_app/scope_app/**`.
- Commits: `2202e51`, `04b7ce7`, `6637f91`, `4a793c2`, `ed7bbe0`.
