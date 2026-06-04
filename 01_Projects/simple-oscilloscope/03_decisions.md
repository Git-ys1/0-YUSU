# Technical Decisions

## Decision: Keil-first firmware workflow
**Status**: accepted
**Date**: 2026-06-01

### Context

The repo is a Keil STM32F103C8T6 project on a Windows machine. The user explicitly expects command-line Keil build and STM32CubeProgrammer flashing, not a new toolchain.

### Options Considered

- Use existing Keil project and scripts.
- Introduce Make/CMake/OpenOCD or another embedded toolchain.
- Treat firmware as simulator-only and postpone real board workflow.

### Decision

Use existing Keil MDK project and local scripts: `tools\build_keil.bat` for hex, `tools\flash_stlink.bat` for ST-Link flashing.

### Consequences

- Positive: matches user's machine, produces real `Objects\SimpleOscilloscope.hex`, avoids unnecessary toolchain churn.
- Negative: Keil build may require Windows-only tooling and write access to generated directories.
- Follow-up: preserve Keil project and generated state unless explicit cleanup is requested.

### Evidence

- Files: `tools\build_keil.bat`, `tools\flash_stlink.bat`, `Objects\SimpleOscilloscope.hex`.
- Commits: `4a793c2`, `ed7bbe0`.
- User constraint: STM32CubeProgrammer path supplied by user.

## Decision: Layer PC app around transport/protocol/acquisition/processing/UI
**Status**: accepted
**Date**: 2026-06-01

### Context

The PC app had to support fake demo, TCP simulator, CH340 serial, binary protocol, measurements, trigger, GUI panels, and packaging.

### Options Considered

- Keep a single plotting script.
- Put serial parsing directly in UI callbacks.
- Split into explicit layers.

### Decision

Use a layered PySide6 app: transport -> protocol decoder -> acquisition controller -> ring buffer -> processing -> UI.

### Consequences

- Positive: simulator/fake/serial share one path; tests can cover binary protocol and processing; UI remains responsive.
- Negative: more files and state synchronization than a single script.
- Follow-up: keep this boundary; do not let UI parse binary frames.

### Evidence

- Files: `docs/pc_app_architecture.md`, `pc_app/scope_app/acquisition/controller.py`, `protocol/stream_decoder.py`, `processing/*`, `ui/*`.
- Commits: `2202e51`, `04b7ce7`, `6637f91`, `4a793c2`.

## Decision: Binary data blocks with ASCII control lines
**Status**: accepted
**Date**: 2026-06-01

### Context

ASCII per-sample output was simple but too inefficient for 10/20 kSa/s and multi-point frame workflows.

### Options Considered

- Keep pure ASCII.
- Use pure binary for all commands/status/data.
- Mix ASCII commands/status with binary DATA frames.

### Decision

Use ASCII for human-readable control/status and binary DATA frames for sample blocks.

### Consequences

- Positive: serial assistant remains useful; high-rate data is compact; mixed decoder can tolerate both streams.
- Negative: direct text printing of serial data is misleading because binary bytes appear between ASCII lines.
- Follow-up: all PC readers should use `ProtocolStreamDecoder`.

### Evidence

- Files: `docs/protocol.md`, `pc_app/scope_app/protocol/binary_protocol.py`, `stream_decoder.py`, `user/src/protocol.c`.
- Commit: `04b7ce7`.

## Decision: Treat the center display as an instrument, not a generic draggable chart
**Status**: accepted
**Date**: 2026-06-04

### Context

User feedback before V0.9.3 showed that the screen felt wrong: waveform drifted left-to-right, corner readouts moved with dragged data coordinates, and the sine looked angular.

### Options Considered

- Keep PyQtGraph pan/zoom behavior.
- Move labels to pyqtgraph `TextItem` data coordinates.
- Lock plot interaction and use QWidget overlays.

### Decision

Lock pan/zoom, render CH1/status/timebase as fixed QWidget overlays, choose a trigger point with enough post-trigger samples, default to 20 kSa/s, and smooth SINE display.

### Consequences

- Positive: hand-in demo looks like a scope screen and resists accidental dragging.
- Negative: generic plot exploration is intentionally reduced.
- Follow-up: add explicit controls for timebase/offset instead of relying on mouse gestures.

### Evidence

- Files: `pc_app/scope_app/ui/waveform_view.py`, `processing/trigger.py`, `scope_workspace.py`, `user/src/signal.c`.
- Commit: `ed7bbe0`.

## ADR Index

- [[adr/2026-06-01-keil-first-firmware-workflow]]
- [[adr/2026-06-01-layered-pc-app]]
- [[adr/2026-06-04-oscilloscope-screen-locking]]
