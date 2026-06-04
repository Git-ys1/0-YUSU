# ADR: Keil-first firmware workflow

**Status**: accepted
**Date**: 2026-06-01
**Project Phase**: firmware bootstrap and V0.9.x hardening

## Context

The project is a Windows Keil STM32F103C8T6 repository. The user explicitly stated that compilation should use Keil command-line tooling found locally, then flash the produced hex with STM32CubeProgrammer.

## Decision

Keep Keil MDK as the authoritative firmware build path and use `tools\build_keil.bat` / `tools\flash_stlink.bat` for build and flash.

## Options Considered

| Option | Pros | Cons | Outcome |
|---|---|---|---|
| Keil MDK scripts | Matches local machine and user expectation | Windows/Keil dependent | accepted |
| CMake/OpenOCD migration | Portable in theory | Introduces toolchain churn before hand-in | rejected |
| GUI-only/simulator-only | Easier PC app work | Fails real hardware requirement | rejected |

## Consequences

- Positive: reliable local hex/flash path.
- Negative: generated Keil files require careful git discipline.
- Follow-up: do not clean project files casually.

## Revisit Signals

Revisit only if the user requests cross-platform firmware builds or Keil becomes unavailable.

## Evidence

- Files: `tools\build_keil.bat`, `tools\flash_stlink.bat`.
- Commits: `4a793c2`, `ed7bbe0`.
- Commands: V0.9.3 Keil build and ST-Link flash.
