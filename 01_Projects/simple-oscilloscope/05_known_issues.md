# Known Issues and Pitfalls

## Issue: GUI blank because source is not connected
**Status**: active
**Severity**: medium
**Last Seen**: 2026-06-04

### Symptom

The window opens but the center says to select a data source; right panel shows `设备: --`; bottom shows `点数 0`.

### Likely Cause

The user clicked `运行` before actually connecting a source. `Run` only starts/continues acquisition after connection; it is not the same as `Connect`.

### Verified Fix or Workaround

Click `演示` for `fake://sine`, or choose COM/TCP in the `连接` tab and click the green `连接` button first.

### Failed Attempts

- Treating the blank screen as a drawing bug.
- Assuming COM14 hardware is live before flashing matching firmware.

### Codex Rule

When diagnosing a blank scope screen, first check connection identity and sample count before editing drawing code.

### Evidence

- Files: `docs/user_guide_pc.md`, `pc_app/scope_app/ui/waveform_view.py`.
- Session: user screenshot before V0.9.3.

## Issue: Old firmware makes new PC app appear unresponsive
**Status**: active
**Severity**: high
**Last Seen**: 2026-06-04

### Symptom

COM14 exists but the V0.9.x PC app receives no useful frames or wrong capability/status.

### Likely Cause

The board still runs old firmware. V0.9.2/V0.9.3 expect `921600`, `CAP?`, binary blocks, and 64-point samples.

### Verified Fix or Workaround

Run `tools\flash_stlink.bat`, then decode `ID?`, `CAP?`, `STATUS` at COM14/921600. V0.9.3 verification returned `DeviceIdentity.version == 0.9.3` and status sample rate `20000`.

### Failed Attempts

- Publishing app/hex without flashing local board, then testing COM14 immediately.

### Codex Rule

If the user is testing real hardware after a firmware-affecting release, flash the board or clearly say it has not been flashed.

### Evidence

- Commands: `tools\flash_stlink.bat`; pySerial + `ProtocolStreamDecoder` COM14 check.
- Release: `v0.9.3`.

## Issue: Millisecond polling cannot support 10/20 kSa/s
**Status**: resolved
**Severity**: high
**Last Seen**: 2026-06-04

### Symptom

1 kHz signal cannot be displayed credibly; sample timing is too coarse and rate caps are too low.

### Likely Cause

Earlier firmware used `board_millis()`-style timing and old limits such as 100/1000 Sa/s or 10 kSa/s defaults.

### Verified Fix or Workaround

V0.9.2 added TIM2 sampling timer and ISR queue. V0.9.3 defaults to 20 kSa/s.

### Failed Attempts

- Merely increasing constants without moving sampling off millisecond polling.

### Codex Rule

For high-rate embedded behavior, verify actual timing source, not just UI ranges or macros.

### Evidence

- Files: `user/src/board.c`, `user/src/main.c`, `user/inc/osc_config.h`.
- Commit: `4a793c2`.

## Issue: Generic chart interaction makes oscilloscope screen look broken
**Status**: resolved
**Severity**: high
**Last Seen**: 2026-06-04

### Symptom

User drags the screen and sees severe pulling; CH1/status labels move because they were placed in data coordinates.

### Likely Cause

PyQtGraph default pan/zoom behavior remained enabled and text labels were `TextItem`s tied to the plot coordinate system.

### Verified Fix or Workaround

V0.9.3 disables pan/zoom/wheel interaction and uses fixed QWidget/QLabel overlays on the viewport.

### Failed Attempts

- Treating fixed instrument labels as ordinary plot annotations.

### Codex Rule

For instrument-like UI, do not rely on data-coordinate annotations for chrome/readouts. Use fixed overlay widgets.

### Evidence

- Files: `pc_app/scope_app/ui/waveform_view.py`.
- Commit: `ed7bbe0`.

## Issue: 1 kHz sine looks too angular at low display/sample density
**Status**: resolved
**Severity**: medium
**Last Seen**: 2026-06-04

### Symptom

The sine appears pointy and not like a real sine wave.

### Likely Cause

1 kHz with too few points per cycle, plus firmware lookup-table quantization, plus straight-line display between sparse points.

### Verified Fix or Workaround

V0.9.3 defaults fake/sim/firmware to 20 kSa/s, adds sine table phase interpolation in firmware, and uses display smoothing for SINE in PC view.

### Failed Attempts

- Relying on 10 kSa/s as "enough" for the demo screenshot.

### Codex Rule

For visible waveform quality, judge the displayed trace, not just Nyquist math. For demo-grade 1 kHz sine, prefer 20 kSa/s and display reconstruction.

### Evidence

- Files: `user/src/signal.c`, `pc_app/scope_app/ui/waveform_view.py`, `tests/test_waveform_display.py`.
- Commit: `ed7bbe0`.

## Issue: PyInstaller rebuild fails when old exe is still running
**Status**: active
**Severity**: medium
**Last Seen**: 2026-06-04

### Symptom

`tools\build_portable.bat` fails with `Access is denied` on `dist\SimpleScopePC\SimpleScopePC.exe` or internal DLLs.

### Likely Cause

An existing packaged `SimpleScopePC.exe` is still running and locks the dist directory.

### Verified Fix or Workaround

Find and stop the old `SimpleScopePC` process, then rerun `tools\build_portable.bat`.

### Failed Attempts

- Re-running PyInstaller while the packaged app is open.

### Codex Rule

Before rebuilding Windows GUI packages, check for running packaged exe processes.

### Evidence

- V0.9.3 package attempt failed with PID `22756` holding `dist\SimpleScopePC\SimpleScopePC.exe`; stopping it allowed rebuild.

## Issue: Offscreen Qt screenshots can falsely show Chinese text as boxes
**Status**: watching
**Severity**: low
**Last Seen**: 2026-06-04

### Symptom

Offscreen screenshot renders Chinese as square boxes.

### Likely Cause

`QT_QPA_PLATFORM=offscreen` may have an empty Qt font database, while normal Windows has `Microsoft YaHei` fonts.

### Verified Fix or Workaround

Set the app font to `Microsoft YaHei UI` for normal Windows runs. Treat offscreen font-box screenshots as a test-platform artifact after checking font database.

### Failed Attempts

- Assuming offscreen screenshot boxes prove normal Windows UI is broken.

### Codex Rule

Use offscreen Qt for smoke tests, but verify font availability before treating text rendering as a product defect.

### Evidence

- Files: `pc_app/scope_app/ui/theme.py`, `pc_app/scope_app/main.py`.
- V0.9.2/V0.9.3 verification notes.

## Issue: Sample-index trigger quantization causes horizontal jitter
**Status**: resolved
**Severity**: high
**Last Seen**: 2026-06-04

### Symptom

At 20 kSa/s and 500 us/div, a stable 1 kHz waveform can still appear to drift left/right even after the plot is locked and overlays are fixed.

### Likely Cause

The trigger detector only returned the next sample index after crossing the trigger level. At 20 kSa/s each sample is 50 us, so the trigger reference was quantized by up to one sample before the record view was centered.

### Verified Fix or Workaround

V0.9.4 added `TriggerPoint.time_ms` with linear crossing interpolation, default 15 mV trigger hysteresis, and ScopeWorkspace holdoff/frame holding.

### Failed Attempts

- Treating the remaining drift as a PyQtGraph drawing issue.
- Locking the plot and smoothing sine display without removing trigger-time quantization.

### Codex Rule

For oscilloscope-like displays, align the record to an interpolated threshold crossing, not merely to the following sample index.

### Evidence

- Files: `pc_app/scope_app/processing/trigger.py`, `pc_app/scope_app/processing/pipeline.py`, `pc_app/scope_app/ui/scope_workspace.py`, `tests/test_trigger.py`.
- Commit: `e92e895`.
- Release: `v0.9.4`.
## Issue: Hand-in screenshots must come from real hardware when hardware is available
**Status**: resolved
**Severity**: medium
**Last Seen**: 2026-06-04

### Symptom

The first V0.9.5 README/Release screenshot used `fake://sine`, which was not acceptable for final hand-in evidence because the board and COM14 path were available.

### Likely Cause

The packaging/screenshot workflow defaulted to the convenient demo source instead of the real CH340 serial source.

### Verified Fix or Workaround

Capture the screenshot from `COM14 @ 921600` after confirming the device panel shows `SimpleOscilloscope 0.9.5 (STM32F103C8T6, USART1_PA9_PA10 / PA8_PWM+BINARY_DATA)` and the status bar shows `RUN`.

### Failed Attempts

- Treating a fake-source screenshot as acceptable submission evidence.

### Codex Rule

For hand-in release README screenshots, use real hardware data when the board is connected and validated; use `fake://` only for explicit demo or no-hardware fallback screenshots.

### Evidence

- File: `docs/images/pc_app_v0_9_5_main.png`.
- Commit: `38dc09e`.
- Release: `v0.9.5`.
