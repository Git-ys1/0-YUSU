# ADR: Lock the oscilloscope screen and use fixed overlays

**Status**: accepted
**Date**: 2026-06-04
**Project Phase**: V0.9.3 hand-in stabilization

## Context

The user reported that the waveform moved like a left-to-right stream, mouse dragging created a severe pulling feeling, and corner labels moved with the canvas. The sine trace also looked angular.

## Decision

Disable PyQtGraph mouse pan/zoom/wheel interactions for the main scope screen, use QWidget overlays for readouts, select trigger points with available post-trigger samples, default to 20 kSa/s, and smooth SINE display/firmware generation.

## Options Considered

| Option | Pros | Cons | Outcome |
|---|---|---|---|
| Keep generic chart behavior | Useful exploration | Bad hand-in scope UX | rejected |
| Keep TextItem labels | Easy implementation | Moves with data coordinates | rejected |
| Fixed overlays and locked plot | Scope-like UX | Less freeform chart interaction | accepted |

## Consequences

- Positive: screen behaves like an instrument.
- Negative: users must use controls rather than mouse drag to adjust view.
- Follow-up: improve explicit controls if users need more navigation.

## Revisit Signals

Revisit only if a separate analysis mode is added; keep acquisition screen locked.

## Evidence

- Files: `pc_app/scope_app/ui/waveform_view.py`, `processing/trigger.py`, `user/src/signal.c`.
- Commit: `ed7bbe0`.
- User feedback: V0.9.3 screenshot and complaint.
