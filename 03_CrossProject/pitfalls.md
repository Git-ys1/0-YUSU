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
