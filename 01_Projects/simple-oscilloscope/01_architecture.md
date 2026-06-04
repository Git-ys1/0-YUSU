# Architecture

## System Overview

The project has three cooperating parts:

- Firmware: STM32F103C8T6 C firmware built by Keil. It configures GPIO, USART1, PWM on PA8, TIM2 sample timing, a synthetic waveform generator, ASCII command handling, and binary data blocks.
- PC app: PySide6/PyQtGraph upper-computer that can connect to CH340 serial, TCP simulator, or `fake://` local data sources.
- Simulator/release tooling: a TCP MCU simulator, PyInstaller/Inno Setup packaging scripts, GitHub Actions tag release workflow, and local ST-Link flashing scripts.

## Main Modules

| Module | Responsibility | Notes |
|---|---|---|
| `user/src/board.c` | Board clocks, GPIO, TIM1 PWM, TIM2 sample interrupt | V0.9.2 moved sampling from millis polling to timer ISR |
| `user/src/signal.c` | Waveform state and sample generation | V0.9.3 adds sine phase interpolation |
| `user/src/protocol.c` | ASCII commands, status, CAP, binary/ASCII output | `CAP?` is the capability handshake |
| `pc_app/scope_app/transport` | Serial/TCP/fake source abstraction | Keeps real hardware, simulator, and demo source behind one interface |
| `pc_app/scope_app/protocol` | ASCII and binary mixed-stream decoding | Prevents UI from understanding raw frame bytes |
| `pc_app/scope_app/acquisition` | Background read thread and stats | Keeps Qt UI responsive |
| `pc_app/scope_app/core/ring_buffer.py` | NumPy ring buffer with sub-ms block timing | Critical for 20 kSa/s display |
| `pc_app/scope_app/processing` | Trigger, AutoSet, record view, measurements, decimation | Defines oscilloscope behavior |
| `pc_app/scope_app/ui` | Main window, waveform view, panels, status bar | V0.9.3 locks the plot and uses overlay labels |
| `simulator/mcu_simulator.py` | TCP lower-computer simulator | Uses the same binary protocol as firmware |
| `tools/*.bat` | Setup, run, build, package, flash | User-facing operational path |

## Data Flow

```text
SerialTransport / TcpTransport / FakeTransport
  -> ProtocolStreamDecoder
  -> AcquisitionController background thread
  -> SampleFrame / SampleBlock
  -> WaveformRingBuffer
  -> process_scope_frame / build_record_view / calculate_measurements
  -> WaveformView / MeasurementPanel / StatusBar
```

The UI boundary is deliberate: UI does not call `serial.readline()`, does not unpack binary frames, and does not own hardware timing.

## Architecture Evolution

| Date/Phase | Architecture Shape | Why It Changed | Evidence |
|---|---|---|---|
| 2026-06-01 bootstrap | Keil firmware plus simple PC scope | Need first MCU/PC loop | commits `b0dc0fb`, `bf48138` |
| 2026-06-01 v0.2.1 | PC app refactored to Qt layers | Tkinter/single script was not enough for oscilloscope UI | commit `2202e51`, tag `v0.2.1` |
| 2026-06-01 v0.3.0-v0.6.0 | Display controls, measurements, trigger, pause | Build the basic oscilloscope feature set | commits `90eb72d` through `017fc6c` |
| 2026-06-01 v0.7.0 | Binary data blocks and mixed-stream decoder | ASCII-per-sample could not support higher-rate streaming | commit `04b7ce7`, `docs/protocol.md` |
| 2026-06-02 v0.8.0 | Productized PySide6 workbench | UI needed a real app shell and safer panels | commits `6637f91`, `6f3a0e6`, `54bbc82` |
| 2026-06-02 v0.9.1 | Windows release pipeline | End users should run exe/zip/installer without Python | commit `e10ca5e` |
| 2026-06-04 v0.9.2 | Capability handshake and timer-driven sample queue | 1 kHz/10-20 kSa/s required firmware timing changes | commit `4a793c2` |
| 2026-06-04 v0.9.3 | Locked instrument screen and smoother sine | User saw drifting labels and angular waveform before hand-in | commit `ed7bbe0` |

## Boundaries

- Firmware owns timing and hardware output.
- PC acquisition owns transport and decoding.
- Processing owns scope semantics: trigger, record view, AutoSet, measurement.
- UI owns presentation and user commands only.
- Release scripts own artifacts; they should not mutate source semantics.

## Abandoned or Rejected Approaches

| Approach | Why It Looked Plausible | Why It Was Rejected | Evidence |
|---|---|---|---|
| Tkinter/single script upper-computer | Fast to prototype | Too weak for productized panels, plotting, packaging, and state | v0.2.1 refactor commit `2202e51` |
| ASCII sample stream as primary high-rate data | Easy to debug in serial assistant | Inefficient and unsuitable for binary blocks/20 kSa/s | v0.7.0 commit `04b7ce7` |
| `board_millis()` polling for high sample rates | Simple firmware loop | Millisecond resolution cannot support 10/20 kSa/s | v0.9.2 task and commit `4a793c2` |
| PyQtGraph data-coordinate TextItems for fixed readouts | Easy to place labels near plot corners | They move when the plot is dragged; not instrument-like | v0.9.3 commit `ed7bbe0` |
| Leaving plot mouse pan/zoom enabled | Useful for generic chart exploration | Harmful for an oscilloscope hand-in demo; users can drag screen into a broken-looking state | user feedback before v0.9.3 |

## Source Evidence

- Files: `README.md`, `docs/pc_app_architecture.md`, `docs/protocol.md`, `pc_app/scope_app/**`, `user/src/**`.
- Commands: `git log --reverse --date=short`, `git show --stat v0.9.1`, `git show --stat v0.9.2`, `git show --stat v0.9.3`.
- Last verified: 2026-06-04.
