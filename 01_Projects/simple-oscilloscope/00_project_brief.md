# Project Brief

## One Sentence

Simple Oscilloscope is a compact STM32F103C8T6 oscilloscope/signal-source project: the MCU generates or streams sample data, the PC app receives CH340/TCP/fake data, and the release workflow ships a Windows GUI plus firmware hex.

## Current Goal

The current stable goal is V0.9.5: a hand-in-ready oscilloscope demo where the PC screen behaves like an instrument, the waveform uses hysteresis plus interpolated trigger timing to reduce horizontal jitter, the local board is flashed through the Keil/STM32CubeProgrammer path, and README/Release evidence uses a real COM14 screenshot.

## Core Constraints

- Firmware workflow is Keil-first. Build with `tools\build_keil.bat`; do not invent a parallel firmware build path without evidence.
- Flashing endpoint is `Objects\SimpleOscilloscope.hex` through local STM32CubeProgrammer/ST-Link, currently `F:\AcademicHub\STMicroelectronics\stm32cubeprogrammer\bin\STM32_Programmer_CLI.exe`.
- Preserve Keil project and generated state unless the task explicitly requires cleanup: `.uvprojx`, `.uvoptx`, `.uvguix.*`, `DebugConfig/`, `Objects/`, `Listings/`.
- PC app is Python/PySide6/PyQtGraph/NumPy/pySerial, packaged via PyInstaller onedir, portable zip, and Inno Setup installer.
- Safe ADC assumption is 0-3.3 V only. This project has no analog front-end for mains, negative voltage, high voltage, or un-biased AC input.

## Current Stage

V0.9.5 is published and locally verified on 2026-06-04:

- Git commit: `38dc09e`
- Tag: `v0.9.5`
- Remote: `https://github.com/Git-ys1/SimpleOscilloscope.git`
- Release: https://github.com/Git-ys1/SimpleOscilloscope/releases/tag/v0.9.5
- Firmware version returned by COM14: `0.9.5`
- Sample rate returned by COM14 status: `20000`

## Maturity Assessment

- Project age: active intensive development from 2026-06-01 to 2026-06-04.
- Approx commit count at ingestion: 16 commits on `main`.
- Major releases/checkpoints: `v0.1.0`, `v0.2.1`, `v0.3.0`, `v0.4.0`, `v0.5.0`, `v0.6.0`, `v0.7.0`, `v0.8.0`, `v0.9.1`, `v0.9.2`, `v0.9.3`, `v0.9.4`, `v0.9.5`.
- Evidence quality: high for current state and V0.9.x; medium for earliest intent because the repo history is short but enough commit evidence exists.
- Ingestion mode: mature full-cycle.

## From-Zero Summary

- What this project is: a firmware + PC upper-computer oscilloscope demo centered on STM32F103C8T6.
- Why it exists: to deliver a practical embedded/PC oscilloscope workflow with a visible waveform, release packages, and local flashing.
- The smallest useful thing to understand first: data flows from transport to protocol decoder to acquisition controller to ring buffer to processing to UI; UI should not read serial or parse binary directly.
- The mistake a newcomer is most likely to make: run the GUI without flashing matching firmware, or treat `Run` as `Connect`, then think the blank screen is a drawing bug.

## Source Evidence

- Project path: `F:\Project\Simple Oscilloscope`
- Remote: `https://github.com/Git-ys1/SimpleOscilloscope.git`
- Current commit: `38dc09e`
- Last verified: 2026-06-04
- Evidence files/logs: `README.md`, `docs/protocol.md`, `docs/pc_app_architecture.md`, `docs/user_guide_pc.md`, `tools\*.bat`, `user\src\*.c`, `pc_app\scope_app\*`, releases `v0.9.4` and `v0.9.5`, Codex JSONL `rollout-2026-06-01T16-48-42-019e825e-e5eb-7bb0-8af4-fe84f1579c21.jsonl`.
