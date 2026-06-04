# Progress

## Current State

As of 2026-06-04, V0.9.5 is the current published state. The main repo is clean and synced to `origin/main`; `v0.9.5` is tagged and released.

## Completed

- Keil firmware project exists for STM32F103C8T6.
- USART1 PA9/PA10 serial protocol supports ASCII commands and binary sample blocks.
- TIM2-driven sampling queue replaced millisecond polling for higher sampling rates.
- PC app is packaged as Windows onedir exe, portable zip, and Inno installer.
- PC app supports fake demo source, TCP simulator, and CH340 serial.
- Scope UI has Chinese panels, AutoSet, measurements, trigger, locked plot, fixed overlay readouts, and smoother SINE display.
- Local ST-Link flashing and COM14 protocol verification were completed for V0.9.5.
- The root README is rewritten for hand-in requirements and uses a real COM14 software screenshot instead of a fake demo source.

## Milestones

| Date/Phase | Milestone | Evidence | Notes |
|---|---|---|---|
| 2026-06-01 | Initial firmware/PC loop | `b0dc0fb`, `bf48138` | Foundation |
| 2026-06-01 | Qt layered app | `2202e51`, tag `v0.2.1` | Replaced simpler UI route |
| 2026-06-01 | Display, trigger, binary protocol | tags `v0.3.0` to `v0.7.0` | Core oscilloscope mechanics |
| 2026-06-02 | Productized UI | tag `v0.8.0` | Workbench-like app |
| 2026-06-02 | Windows release pipeline | tag `v0.9.1` | exe/zip/installer |
| 2026-06-04 | Timer-driven 20 kSa/s path | tag `v0.9.2` | Firmware and protocol capabilities |
| 2026-06-04 | Locked scope screen and smooth sine | tag `v0.9.3` | Stabilized visible screen |
| 2026-06-04 | Interpolated trigger and holdoff | commit `e92e895`, tag `v0.9.4` | Stabilized waveform display |
| 2026-06-04 | Hand-in README and real COM14 screenshot | commits `b9056c0`, `38dc09e`, tag `v0.9.5` | Current hand-in release |

## In Progress

- No active uncommitted work in Simple Oscilloscope after V0.9.5 release.

## Blocked

- None for the V0.9.5 hand-in path.

## Last Meaningful Update

- Date: 2026-06-04
- Source: commits `b9056c0` and `38dc09e`, release `v0.9.5`, local test/build/package/flash/COM14 outputs.
