# Cross-Project Patterns

## Template

```md
## Pattern: title
**Status**: candidate | active | deprecated
**Seen In**: project-slug, project-slug

### Use When

...

### Avoid When

...

### Notes

...
```

## Pattern: 自动化层级阶梯
**Status**: active
**Seen In**: auto-play

### Use When

用户提出 UI/游戏自动化需求，但真实流程稳定度还没有判断清楚。

### Avoid When

用户已经明确存在高分支视觉流程，且确实需要感知能力或 agent 控制。

### Notes

从能工作的最简单层级开始：

1. 固定轨迹 -> 宏录制器；
2. 少量状态 -> 带预览和日志的显式状态机；
3. 高分支视觉任务 -> 图像识别 / agent bridge。

Auto Play 证明：如果当前目标固定到足以宏回放，直接上图像识别会浪费时间和调试成本。

### Evidence

- Auto Play evidence: fixed workflow pivot from `autogame/vision.py` / `autogame/kitchen_runner.py` to `app.py -> autogame.macro_ui.main` after user confirmed MouseRecorder-style replay was sufficient.

## Pattern: Transport-protocol-acquisition-processing-UI layering
**Status**: active
**Seen In**: simple-oscilloscope

### Use When

A desktop tool needs to talk to hardware, simulators, and fake/demo data while keeping the UI responsive and testable.

### Avoid When

The task is a one-off throwaway script with no simulator, no packaging, no protocol evolution, and no GUI state complexity.

### Notes

Keep hardware/source selection in transport, bytes/frames in protocol, background reading in acquisition, domain logic in processing, and presentation in UI. Simple Oscilloscope used this to share one path across CH340 serial, TCP simulator, and `fake://` sources.

### Evidence

- Simple Oscilloscope: `docs/pc_app_architecture.md`, `pc_app/scope_app/**`, project memory `01_Projects/simple-oscilloscope/10_project_summary.md`.

## Pattern: Hardware release requires artifact plus device verification
**Status**: active
**Seen In**: simple-oscilloscope

### Use When

A release includes firmware or depends on a real board being connected during user acceptance.

### Avoid When

The deliverable is purely software and has no local hardware state.

### Notes

"Built and published hex" is not the same as "the user's board is running it." State explicitly whether flashing happened. When possible, flash and then verify the device's reported version/status through the normal protocol. For submission-facing screenshots or README evidence, prefer real hardware data when connected hardware is available; use fake/demo sources only when clearly labeled as fallback.

### Evidence

- Simple Oscilloscope V0.9.3/V0.9.4: ST-Link flash plus COM14 `ID?`/`CAP?`/`STATUS` verification.
- Simple Oscilloscope V0.9.5: README/Release screenshot was retaken from real COM14 data instead of `fake://sine`.

## Pattern: Hardware falsification before software architecture fallback
**Status**: active
**Seen In**: cleanscout-rover-lower-firmware, simple-oscilloscope

### Use When

An embedded or hardware-adjacent project shows symptoms that could be explained by either firmware logic or the physical chain: no encoder counts, one channel lagging, inconsistent direction, missing serial data, unstable power, or a board image that may not match the repository.

### Avoid When

The failure is already isolated to a pure software unit test, compiler error, serialization bug, or deterministic simulator-only issue.

### Notes

Before replacing the architecture, prove or disprove the physical path. Use channel swaps, known-good devices, cable swaps, voltage changes, read-only programmer identity checks, board-reported firmware versions, and small raw commands. Treat software fallbacks as temporary evidence generators unless the hardware path has been falsified.

CleanScout RF1 proved this the hard way: CN1/CN3 encoder failures were tempting to solve by moving to a soft-encoder branch, but the final convergence came from new/old motor swaps, 12V/7.4V comparison, and replacing a suspect white cable bundle with rainbow wires. The project kept the native TIM encoder architecture only because the team separated hardware proof from software suspicion.

### Evidence

- CleanScout Rover lower firmware: `01_Projects/cleanscout-rover-lower-firmware/05_known_issues.md`, `07_development_history.md`, session anchors `[0252]`, `[0283]`-`[0288]`.
- Simple Oscilloscope: hardware release verification through ST-Link flash and COM-reported firmware identity.

## Pattern: Checkpoints as hardware evidence, not just Git hygiene
**Status**: active
**Seen In**: cleanscout-rover-lower-firmware

### Use When

An embedded project is being tuned against real hardware and a working state may be lost by a small firmware, wiring, parameter, or build/flash change.

### Avoid When

The project is purely software with strong automated tests and trivial rollback, or the checkpoint cannot be tied to a real observed device state.

### Notes

For hardware projects, a useful checkpoint records more than code. It should capture the observed behavior, flash/build state, serial identity, physical wiring assumptions, and the reason the state is worth protecting. If a user names a checkpoint as an "absolute baseline", do not keep editing that point and then claim the baseline is preserved.

CleanScout RF1 used `f826b3d`, `167c3f8`, and especially `39c481f` as practical recovery points during the four-wheel synchronization fight. Those commits mattered because they were linked to live motor behavior, not because they were tidy commit markers.

### Evidence

- CleanScout Rover lower firmware: `01_Projects/cleanscout-rover-lower-firmware/10_project_summary.md`, `05_known_issues.md`, session anchors `[0356]`, `[0362]`-`[0364]`.

## Pattern: 可观察自动化 UI
**Status**: active
**Seen In**: auto-play

### Use When

用户侧自动化依赖截图、模板匹配、OCR、状态机或多区域监视，并且用户需要自己配置参照物、监视区域或动作逻辑。

### Avoid When

流程已经稳定为固定轨迹，宏录制器可以直接解决问题；此时不要为了“更智能”而增加视觉 UI 复杂度。

### Notes

可观察自动化 UI 至少要显示：

- 用户框选的区域预览；
- 当前模板或参照图预览；
- 实时或最近一次匹配置信度；
- 当前状态机步骤和下一步动作；
- 每个监视区域的一键调试截图。

Auto Play 的厨房模式暴露出这个需求：三种菜品、独立备菜区、订单识别和中断逻辑都存在时，如果没有预览和状态机可视化，用户无法判断到底是区域、模板还是逻辑错误。

### Evidence

- Project/path: `F:\Project\auto play`
- Files: `autogame/kitchen_runner.py`, `autogame/kitchen_ui.py`, `profiles/kitchen.json`, `01_Projects/auto-play/07_development_history.md`
- Date: 2026-06-04

## Pattern: Separate research context from fictionalized profile claims
**Status**: active
**Seen In**: hyperframes

### Use When

A creative video, profile, pitch, founder story, or persona piece uses real public-domain context to make a fictionalized or exaggerated character story feel plausible.

### Avoid When

The deliverable is a factual biography, journalism, due diligence report, legal/financial claim, or any artifact that will be presented as verified real-world record.

### Notes

Keep three layers separate:

1. Verifiable background context, with source notes.
2. User-supplied or fictionalized creative claims.
3. On-screen and README disclosure that the result is a concept/fictionalized portrayal.

This keeps the creative work useful without accidentally laundering invented achievements into authoritative-looking biography.

### Evidence

- HyperFrames production `003-tian-binxian-profile`: `assets/research/research-notes.md` records public energy-sector sources, while `index.html` and `README.md` label the result as `概念人物志 / 虚构演绎`.
