# ADR: Use interpolated trigger time and holdoff for display lock

**Status**: accepted
**Date**: 2026-06-04

## Context

V0.9.3 fixed plot dragging, fixed overlays, and sine smoothing, but the waveform could still look like it drifted horizontally. The trigger algorithm still found a crossing by sample index and then centered the display on `time_ms[index]`.

At 20 kSa/s, one sample is 50 us. On a 500 us/div screen that quantization is visible enough for the user to describe the display as still drifting.

## Decision

V0.9.4 keeps the trigger API that returns an index for compatibility, but adds `TriggerPoint` with an interpolated crossing time. The processing pipeline uses `TriggerPoint.time_ms` as the reference time. Trigger hits use default 15 mV hysteresis, and `ScopeWorkspace` keeps a short holdoff/display-hold record.

## Consequences

- Positive: stable periodic waves align to the threshold crossing instead of the following sample.
- Positive: level chatter near the threshold is less likely to retrigger the display.
- Negative: this is still PC-side record alignment; it is not the same as MCU-side ADC DMA triggered capture.

## Evidence

- Files: `pc_app/scope_app/processing/trigger.py`, `pc_app/scope_app/processing/pipeline.py`, `pc_app/scope_app/ui/scope_workspace.py`.
- Tests: `.venv\python.exe -m pytest -q` returned `35 passed`.
- Release: `v0.9.4`, commit `e92e895`.