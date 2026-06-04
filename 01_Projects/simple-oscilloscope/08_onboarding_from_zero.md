# Onboarding From Zero

本文件写给完全没有参与过本项目的新 Codex/开发者。不要默认读者知道 Keil、CH340、fake source、simulator、binary frames 之间的关系。

## First 30 Minutes

1. Read `README.md`, `docs/protocol.md`, `docs/pc_app_architecture.md`, and this memory folder.
2. Run `git status --short --branch` in `F:\Project\Simple Oscilloscope`.
3. Run `.venv\python.exe -m pytest -q`.
4. Run `tools\run_scope.bat --source fake://sine --connect` or packaged `dist\SimpleScopePC\SimpleScopePC.exe --source fake://sine --connect`.
5. Do not touch Keil project metadata, generated `Objects/`, `Listings/`, or `.uvoptx` unless the task explicitly requires it.

## First Day

- Build/run goal: prove fake demo, TCP simulator, Keil firmware build, and local ST-Link flash independently.
- Small safe change: add or adjust a processing/UI test such as trigger window selection or display interpolation.
- Required concepts: binary DATA frame format, mixed ASCII/binary decoder, trigger/reference time, ring buffer timing, Keil build scripts.
- Common false assumptions: `Run` means `Connect`; serial bytes should be printable text; increasing sample rate macros alone fixes timing; PyQtGraph default pan/zoom is acceptable for a scope screen.

## Minimal Working Loop

```bat
.venv\python.exe -m pytest -q
tools\build_keil.bat
tools\run_scope.bat --source fake://sine --connect
tools\flash_stlink.bat
tools\run_scope.bat --source COM14 --baud 921600 --connect
```

Expected result:

```text
pytest: all tests pass
Keil: 0 Error(s), 0 Warning(s)
Fake source: visible sine waveform
Flash: Download verified successfully
COM14: DeviceIdentity.version == current APP/FW version, sample_rate_hz == 20000 for V0.9.5
```

## Concepts You Must Understand

| Concept | Why It Matters | Where To Learn It |
|---|---|---|
| Keil-first workflow | Firmware build/hex path is not optional on this machine | `tools\build_keil.bat`, `README.md` |
| Binary + ASCII mixed protocol | Serial output is not plain text after binary mode starts | `docs/protocol.md`, `protocol/stream_decoder.py` |
| `fake://`, TCP simulator, CH340 | These are three transport sources into one app path | `transport/factory.py`, `simulator/mcu_simulator.py` |
| Triggered record view | Scope screen should be centered around trigger, not just right-aligned rolling data | `processing/trigger.py`, `processing/record_view.py` |
| Overlay UI | Instrument readouts should be viewport-fixed, not data-coordinate text | `ui/waveform_view.py` |
| Hardware safety | STM32 ADC is 0-3.3 V only | `README.md`, `docs/user_guide_pc.md` |

## Common Newcomer Traps

| Trap | Symptom | Correct Move | Evidence |
|---|---|---|---|
| Not flashing matching firmware | COM14 connects but no useful waveform/status | Flash `Objects\SimpleOscilloscope.hex` and decode ID/CAP/STATUS | V0.9.3 COM14 check |
| Treating binary as text | Console shows unreadable bytes | Use `ProtocolStreamDecoder` | `docs/protocol.md` |
| Changing UI ranges but not firmware timing | Higher sample rate still not real | Check TIM2/sample queue/actual status | `user/src/board.c`, `user/src/main.c` |
| Letting plot be draggable | User can pull scope screen into broken-looking state | Disable pan/zoom and use explicit controls | `ed7bbe0` |
| Assuming offscreen screenshot text boxes are product bugs | Chinese appears as boxes in offscreen mode | Check normal Windows fonts and app font setting | V0.9.2 notes |
| Rebuilding while app is open | PyInstaller `Access is denied` | Stop `SimpleScopePC.exe` first | V0.9.3 packaging incident |

## If Rebuilding From Scratch

Recommended order:

1. Establish firmware boot/status and one sample source.
2. Add PC transport abstraction and fake source.
3. Add protocol decoder and ring buffer.
4. Add visible waveform and measurement basics.
5. Add binary DATA frames before chasing high sample rates.
6. Add trigger/record-view semantics.
7. Add packaging/release scripts.
8. Polish instrument UI and hardware flashing verification last.

Do not start with:

- Marketing/landing-page UI.
- A new firmware toolchain.
- High-voltage measurement claims.
- Direct UI serial parsing.
- Mouse-drag chart interactions as the primary scope control model.
