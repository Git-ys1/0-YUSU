# Cross-Project Pitfalls

## Active Pitfalls

### Pitfall: PowerShell profile noise is not target command failure
**Status**: active
**Seen In**: Windows local tooling, legacy Codex memory

### Symptom

命令输出里出现 PowerShell profile 解析错误、语言模式噪声，但目标命令可能已经成功。

### Root Cause

Windows PowerShell 启动时加载用户 profile；profile 本身可能有语法或语言模式问题。

### Better Approach

优先使用 `powershell.exe -NoProfile ...`。判断结果时先看目标命令 exit code 和有效输出。

### Pitfall: Local generated memories fragment across systems
**Status**: active
**Seen In**: Windows/Ubuntu Codex memory setup

### Symptom

Windows 和 Ubuntu 各自的 `~/.codex/memories` 不同步，导致一个系统知道的经验另一个系统不知道。

### Root Cause

Codex generated memories 是本机状态，不是跨系统共享档案。

### Better Approach

手工主记忆写入本 GitHub-backed vault；各端本地 memories 只作为召回缓存和导入来源。

### Pitfall: UI automation can be over-engineered
**Status**: active
**Seen In**: legacy Codex memory

### Symptom

用户只需要固定流程回放，代理却交付复杂图像识别或状态机，增加调试成本。

### Root Cause

没有先判断流程是固定轨迹、低分支状态机，还是高分支智能体控制。

### Better Approach

先问/观察流程稳定度。固定流程优先宏录制器；高分支流程再考虑截图识别、状态机或本地 HTTP bridge。

### Pitfall: 坐标宏回放没有恢复起点
**Status**: active
**Seen In**: auto-play

### Symptom

录制回放看起来走了同样的轨迹，但因为从当前鼠标位置开始，最终点击到错误位置。

### Root Cause

宏没有持久化并恢复第一个全屏绝对坐标，就直接回放录制事件流。

### Better Approach

记录显式 origin/首个鼠标事件，开始延迟后先移动到该位置，再回放。Windows DPI 缩放场景要开启 DPI awareness，并使用绝对光标 API。

### Evidence

- Project/path: `F:\Project\auto play`
- Date: 2026-06-04
- Source: `autogame/macro_engine.py`、`autogame/windows_platform.py`、当前 Codex 会话中的用户确认。V0.2 route audit confirms this as reusable beyond Auto Play.


### Pitfall: 覆盖用户设置和用户宏文件
**Status**: active
**Seen In**: auto-play

### Symptom

工具更新后，用户原本能用的快捷键、宏文件、配置或录制资产消失、被重置，或者行为突然变了。

### Root Cause

Codex 把 `profiles/`、settings、macros 等用户状态当成普通工程文件处理，没有区分代码资产和用户数据。

### Better Approach

默认读取并兼容用户设置；除非用户明确要求，不要覆盖 `profiles/macro_settings.json`、`profiles/macros/` 或类似用户生成文件。需要迁移时，先备份、写迁移规则，并在总结里说明。

### Evidence

- Project/path: `F:\Project\auto play`
- Date: 2026-06-04
- Source: `01_Projects/auto-play/08_onboarding_from_zero.md`, `profiles/macro_settings.json`, `profiles/macros/`.

## Template

```md
## Pitfall: title
**Status**: candidate | active | resolved
**Seen In**: project-slug

### Symptom

...

### Root Cause

...

### Better Approach

...

### Evidence

- Project/path:
- Date:
- Source:
```

### Pitfall: Instrument UI readouts placed in data coordinates
**Status**: active
**Seen In**: simple-oscilloscope

### Symptom

An oscilloscope or instrument UI looks correct until the user drags or zooms the plot; labels and state readouts move with the data, making the screen feel broken.

### Root Cause

The app used plot/data-coordinate text annotations for fixed chrome such as channel scale and trigger status.

### Better Approach

Use viewport-fixed QWidget/QLabel overlays or an equivalent screen-space overlay layer for instrument chrome. Keep data-coordinate annotations only for data markers.

### Evidence

- Project/path: `F:\Project\Simple Oscilloscope`
- Date: 2026-06-04
- Source: V0.9.3 user feedback, `pc_app/scope_app/ui/waveform_view.py`, commit `ed7bbe0`.

### Pitfall: High-rate firmware claims made by changing constants only
**Status**: active
**Seen In**: simple-oscilloscope

### Symptom

UI and protocol advertise a higher sample rate, but the waveform timing or shape remains wrong.

### Root Cause

The underlying firmware timing source still uses coarse polling or millisecond timestamps. Raising max/min constants does not prove the hardware loop can sustain the rate.

### Better Approach

Verify timer/ISR scheduling, queue behavior, actual status frames, and displayed waveform quality. For demo-grade output, also inspect what the user actually sees.

### Evidence

- Project/path: `F:\Project\Simple Oscilloscope`
- Date: 2026-06-04
- Source: V0.9.2 moved to TIM2 sample timer; V0.9.3 COM14 status returned 20000 Sa/s.

### Pitfall: Sample-index trigger quantization causes visible instrument jitter
**Status**: active
**Seen In**: simple-oscilloscope

### Symptom

An oscilloscope-like UI locks the plot and centers around trigger, but a stable periodic waveform still appears to drift left/right by a noticeable fraction of a grid division.

### Root Cause

The display reference is set to the next sample after a threshold crossing instead of the interpolated threshold-crossing time. At moderate sample rates, that one-sample timing error can be large enough to see.

### Better Approach

Represent triggers as a point with both sample index and interpolated crossing time. Add hysteresis around the trigger level, then align the record view to the interpolated time and apply holdoff/frame holding when needed.

### Evidence

- Project/path: `F:\Project\Simple Oscilloscope`
- Date: 2026-06-04
- Source: V0.9.4 task, `pc_app/scope_app/processing/trigger.py`, `pc_app/scope_app/processing/pipeline.py`, commit `e92e895`.


### Pitfall: UI click duplicated as device toggle
**Status**: active
**Seen In**: cleanscout-rover-vue3

### Symptom

A robot/device starts and immediately stops even though the user thinks they clicked once.

### Root Cause

The frontend/backend emits both press and release as the same command, while the device side interprets identical repeated commands as toggle-stop.

### Better Approach

Define click semantics explicitly: one command per toggle, explicit `stop` for stopping. Keep press-and-hold protocols separate from toggle protocols.

### Evidence

- Project/source: `Git-ys1/CleanScout_rover/vue3`
- HDS evidence path: `F:\Project\CSc——uniapp\vue3`
- Source: V-1.9.8 edge-relay duplicate command fix and `docs/deployment.md` control responsibility notes.

### Pitfall: Long-lived MJPEG stream killed by normal request timeout
**Status**: active
**Seen In**: cleanscout-rover-vue3

### Symptom

Camera stream appears extremely choppy or reconnects every few seconds despite the native camera page being smooth.

### Root Cause

Long-lived stream is handled like a normal short HTTP request with a short timeout, or the worker parses/repackages frames unnecessarily.

### Better Approach

Treat MJPEG as a stream: raw tunnel when possible, no short fetch timeout for source stream, no historical queue, no frame re-encode unless required.

### Evidence

- Project/source: `Git-ys1/CleanScout_rover/vue3`
- HDS evidence path: `F:\Project\CSc——uniapp\vue3`
- Source: V-2.2.2 raw MJPEG tunnel, `docs/camera-mjpeg-stream.md`.

### Pitfall: Embedded newlib-nano silently drops float printf fields
**Status**: active
**Seen In**: stm32g474-tjc-display

### Symptom

An embedded HMI receives text commands, but numeric fields produced by `%.1f` or `%.2f` are blank or unreliable while prefixes and units remain visible.

### Root Cause

The firmware links `--specs=nano.specs` without `_printf_float`. A successful compile does not prove float formatting support is present at runtime.

### Better Approach

For small measurement displays, convert values to scaled integers and format them with integer specifiers. Only enable `_printf_float` deliberately when the flash-size and runtime costs are acceptable, and verify the actual link command.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-07-30
- Source: dashboard V1.3.1 text fix, Clean Build link command, and USART HMI simulator validation.

### Pitfall: A local rendering failure suppresses independent telemetry
**Status**: active
**Seen In**: stm32g474-tjc-display

### Symptom

One plot fails, while unrelated measurements and status text remain as placeholders, making the whole dashboard appear dead.

### Root Cause

A sequential dashboard function returns immediately after the failed plot and never executes later text updates.

### Better Approach

Track independent output statuses separately. Continue updating observability and independent telemetry, then expose the failed component's ID and status code in a reserved diagnostic field.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-07-30
- Source: `Display_DrawDashboard()` V1.3.1 repair and successful simulator regression.

### Pitfall: Multiple input devices implement the same UI action twice
**Status**: active
**Seen In**: stm32g474-tjc-display

### Symptom

The original touch or simulator button works, but a newly added physical key briefly
shows a different result, an incorrect curve, or a state that is immediately overwritten.

### Root Cause

The physical key calls a new drawing, refresh, or latching path instead of producing the
same semantic command as the already verified HMI button. Two implementations then
compete over display state and result lifetime.

### Better Approach

Separate input detection from business action. Let each device translate its event into
the same command, then route HMI frames and physical keys through one command handler.
Keep ISR work limited to recording the event; perform state changes and blocking I/O in
the main task.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-07-30
- Source: V1.4.1 KEY1 integration; the accepted fix routes both KEY1 and HMI through
  `Display_ProcessButtonCommand()`.

### Pitfall: Coverage computed from an estimated coordinate model can be false confidence
**Status**: active
**Seen In**: stm32g474-tjc-display

### Symptom

A phase-bin coverage metric reports 80% to 100%, yet the reconstructed waveform is much
worse than at a nominally low-coverage point.

### Root Cause

The same estimated frequency is used both to assign sample phases and to compute coverage.
When the true signal is locked to a low-denominator ratio but the estimate is slightly
wrong, the calculated phases spread across many bins although the ADC only observed a few
true phases.

### Better Approach

Treat geometric coverage as one diagnostic, not proof of reconstruction quality. Gate
adaptive reconstruction with independent checks: cross-frame frequency stability,
residual against original samples, model rank, and condition number. Enumerate exact
rational resonances during offline validation.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-07-31
- Source: exact 256 kHz sensitivity scan; a +100 Hz assumed-frequency error reports
  82.03% coverage while phase-fold display RMSE rises to 27.33 mV.

### Pitfall: Digital filtering is treated as a replacement for the ADC analog boundary
**Status**: active
**Seen In**: stm32g474-tjc-display

### Symptom

A simulated FIR demo looks clean, so a bipolar or wide-band signal is connected directly
to an MCU ADC with the expectation that software will remove every unwanted component.

### Root Cause

Digital filtering runs after sampling. It cannot undo clipping, negative or excessive pin
voltage, sample-and-hold settling error, or out-of-band energy that has already aliased into
the passband. Filter coefficients also represent different physical frequencies when the
actual sample rate changes.

### Better Approach

Prove the acquisition chain first: safe input range and bias, common ground, source drive,
measured sample rate, DMA integrity, and analog anti-aliasing. Only then design the digital
filter from the actual sample rate and required passband/stopband. Keep high-rate raw capture
separate from low-bandwidth UART visualization.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-08-01
- Source: the open-source F103 project contains no ADC/DMA and only filters 64 generated
  sine samples; its 31-tap coefficients reach about -3 dB at 691 kHz and suppress 1 MHz by
  about 75.5 dB when interpreted at 4.096 MS/s.

## Buffer length and engineering unit drift across module boundaries

Status: active

### Symptom

A downstream module receives a pointer to 2048 elements but is told to process 4096, or it
applies ADC-code scaling to samples that upstream has already converted to volts. The code
can compile and appear partly functional while reading unrelated memory or corrupting values.

### Root Cause

The interface exposes only a raw pointer and count while the actual frame shape, element type,
physical unit, mutation ownership, and lifetime remain implicit. When acquisition changes from
one ADC buffer to an interleaved floating-point frame, old call sites remain syntactically valid.

### Better Approach

Make the unit and representation explicit in the API, validate the exact sample count at the
boundary, and keep conversion in one owner only. If an upstream routine mutates the shared
buffer, snapshot or prepare downstream state before that call and publish results afterwards.
Review pointer length, element type, unit, mutability, and lifetime together whenever the frame
shape changes.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-08-01
- Source: the old display bridge passed a 2048-element ADC buffer with a count of 4096 and
  converted already-scaled voltage data again; V2.5 replaced it with an explicit
  `const float VO[4096]` prepare/publish boundary.

## Smooth analytical reconstruction is treated as proof that the measurements are correct

Status: active

### Symptom

A sparse frequency/amplitude/phase model produces a visually clean waveform, so the raw-data
reconstruction is deleted and model output is accepted without an independent check.

### Root Cause

Analytical synthesis can only reproduce the components and calibration represented in its
model. Wrong frequency, missing peaks, nonlinear front-end phase, clipping, interleaved ADC
mismatch, and transients may disappear from the displayed curve instead of being detected.

### Better Approach

Use the analytical model as the primary presentation path only behind quality gates: harmonic
relation, component SNR, calibration validity, and residual against the original samples or an
independent reconstruction. Retain a raw-evidence path and fall back when any gate fails.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-08-01
- Source: V2.6 can reconstruct a smooth two/three-component curve from teammate Goertzel phase,
  but `Frontend_PhaseRad()` is still zero and dual-ADC complex calibration is incomplete; the
  existing phase-fold/Huber path remains the residual reference and fallback.

## Direct raw-sample plotting is mistaken for calibrated waveform reconstruction

Status: active

### Symptom

An ADC demo streams consecutive samples to a PC plotter and the curve looks correct, so the
same approach is assumed to replace trigger alignment, one-period normalization, harmonic
phase extraction, front-end calibration, and reconstruction validation.

### Root Cause

Consecutive samples already contain phase implicitly in their time order. Plotting `x[n]`
therefore preserves shape without estimating an explicit phase. A normalized 1T/3T display
or synthesis from only spectral components is a different problem: it needs a reliable
frequency-to-phase coordinate, relative harmonic phase, and correction for the acquisition
and analog transfer path.

### Better Approach

- State whether the output is a raw time record, a triggered record, a folded period, or an
  analytical model; do not call all four "reconstruction".
- Use raw samples as evidence and fallback even when an analytical model is the primary view.
- Validate explicit phase against frequency error, window leakage, arbitrary frame start,
  analog phase response, and interleaved-ADC skew.
- Compare accuracy claims in physical units and synchronized conditions; a visually similar,
  auto-scaled debug plot is not a calibration result.

### Evidence

- STM32L431 reference firmware streams 4096 internal-ADC samples directly, while its FFT path
  uses only magnitudes and rough board-specific scale constants.
- The G474 project needs a fixed 256-slot 1T/3T view and an optional sparse harmonic model,
  so it must preserve the separate phase-fold, calibration, and residual-validation layers.

## An invalid or absent measurement is handled by dropping the frame

Status: active

### Symptom

After an input is disconnected, a dashboard keeps showing the previous waveform or value and
looks as if the old signal were still present.

### Root Cause

The pipeline treats “no valid signal” as an early return. Since no new snapshot is published,
the consumer correctly continues reading the last valid snapshot. “No update” and “measured
absence” are different states but were represented by the same control flow.

### Better Approach

Publish an explicit valid empty-state snapshot that clears waveform, components, frequency,
and measurements. Reserve early return for malformed input or transport failure. If the
measurement can be noisy around the boundary, add calibrated hysteresis before publishing
the empty state, but never retain stale telemetry unintentionally.

### Evidence

- Project/path: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Date: 2026-08-01
- Source: V2.8 `AnalyzerBridge_PrepareReal()` rejected zero frequency/flag and retained the
  previous sine; `AnalyzerBridge_PublishNoSignal()` now emits a valid all-zero snapshot.
