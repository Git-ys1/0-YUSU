# Development History

成熟项目必须写这里。目标不是流水账，而是让新开发者知道项目如何从不确定走到当前 V0.9.5。

## Timeline Summary

| Phase | Dates/Commits | Goal | What Changed | Evidence |
|---|---|---|---|---|
| 0. Bootstrap | 2026-06-01 `b0dc0fb`, `bf48138` | Create first Keil firmware and PC loop | Repo initialized, firmware/upper-computer basics landed | `git log --reverse` |
| 1. Qt layering | 2026-06-01 `2202e51`, tag `v0.2.1` | Move from simple UI to maintainable app | PySide/PyQtGraph layered structure appears | `git show v0.2.1` |
| 2. Scope controls | 2026-06-01 `90eb72d` to `017fc6c` | Add display controls, measurements, trigger, pause | Time/div, volt/div, measurement bar, edge trigger, UI polish | tags `v0.3.0` to `v0.6.0` |
| 3. Protocol throughput | 2026-06-01 `04b7ce7`, tag `v0.7.0` | Make streaming viable | Binary DATA frames and mixed decoder added | `docs/protocol.md`, `tests/test_binary_protocol.py` |
| 4. Product UI | 2026-06-02 `6637f91`, `6f3a0e6`, `54bbc82`, tag `v0.8.0` | Turn tool into a user-facing workbench | Main window, theme, docs, control panel cleanup | `docs/images/pc_app_v0_8_main.png` |
| 5. Windows release | 2026-06-02 `e10ca5e`, tag `v0.9.1` | Ship without Python setup burden | PyInstaller, portable zip, Inno installer, GitHub Actions release | `.github/workflows/release-windows.yml`, `packaging/windows/SimpleScopePC.iss` |
| 6. High-rate scope behavior | 2026-06-04 `4a793c2`, tag `v0.9.2` | Support 1 kHz / 20 kSa/s path | TIM2 timer sampling, ISR queue, CAP handshake, AutoSet/record view | V0.9.2 task notes, `user/src/board.c` |
| 7. Hand-in stabilization | 2026-06-04 `ed7bbe0`, tag `v0.9.3` | Make visible scope screen credible | Plot lock, fixed overlays, trigger window selection, smoother sine, board flash | `pc_app/scope_app/ui/waveform_view.py`, release `v0.9.3` |
| 8. Trigger lock refinement | 2026-06-04 `e92e895`, tag `v0.9.4` | Reduce left/right drift after screen lock | Trigger hysteresis, crossing-time interpolation, pipeline reference update, holdoff frame holding | `pc_app/scope_app/processing/trigger.py`, `tests/test_trigger.py`, release `v0.9.4` |
| 9. Hand-in evidence correction | 2026-06-04 `b9056c0`, `38dc09e`, tag `v0.9.5` | Make submission README/Release evidence match real hardware | README rewritten, real COM14 screenshot captured, package/release assets rebuilt | `docs/images/pc_app_v0_9_5_main.png`, release `v0.9.5` |

## Phase Notes

### Phase 0: Idea / bootstrap

- Initial uncertainty: the project needed both embedded firmware and a PC-side visualization loop.
- First assumptions: a minimal STM32F103C8T6 board plus serial output would be enough for a teaching scope.
- What was learned: keeping firmware, PC app, simulator, and docs in one repo made iteration fast, but also meant release discipline mattered early.
- Evidence: commits `b0dc0fb`, `bf48138`.

### Phase 1: First runnable loop

- First working path: PC app can read a source and display waveform-like data.
- Key blocker: simple UI structure would not scale to trigger, measurements, transport choices, and package release.
- Verified breakthrough: v0.2.1 created a PySide/PyQtGraph layered app.
- Evidence: commit `2202e51`, current `docs/pc_app_architecture.md`.

### Phase 2: Core feature buildout

- Main capabilities added: display controls, measurements, trigger mode, pause/clear, sample blocks and binary protocol planning.
- Important mistakes: treating an oscilloscope too much like a generic scrolling plot delayed the instrument-like interaction model.
- Abandoned paths: pure ASCII sample streaming as the final high-rate path.
- Evidence: tags `v0.3.0`, `v0.4.0`, `v0.5.0`, `v0.6.0`.

### Phase 3: Reliability / refactor

- Why the project changed direction: binary throughput and productized GUI became more important than simply plotting samples.
- Technical debt paid down: transport/protocol/acquisition separation, mixed stream decoder, app settings, package metadata, docs.
- Compatibility constraints: Windows/Keil/STM32CubeProgrammer path and CH340/COM workflows stayed central.
- Evidence: tags `v0.7.0`, `v0.8.0`, `v0.9.1`.

### Phase 4: Current mature state

- What is stable now: V0.9.5 app package, firmware hex, ST-Link flash path, COM14 protocol response, real COM14 screenshot, fake/TCP/serial transport abstraction, tests.
- What is still fragile: no real analog front-end, single channel, 20 kSa/s limit, no signed installer, current GUI still primarily a teaching/demo scope.
- What future Codex should preserve: Keil-first flow, version-first release naming, transport/protocol/UI boundary, explicit hardware flashing verification.
- Evidence: V0.9.5 release, `35 passed`, Keil `0 Error(s), 0 Warning(s)`, COM14 decode and real hardware screenshot.

## Lessons By Stage

- Early-stage lesson: get a visible end-to-end loop quickly, but do not let prototype UI shape final scope semantics.
- Mid-stage lesson: binary protocol and layered decoding are worth the extra complexity once sample rates rise.
- Mature-stage lesson: for hand-in/demo embedded apps, final user-perceived behavior includes flashing the board and looking at the real screen, not just passing tests.

### Phase 8: Trigger lock refinement

- User-visible problem: after V0.9.3 fixed plot dragging and pointy sine, the remaining complaint was that the waveform still looked like it drifted horizontally.
- Root cause: trigger time was still `time_ms[trigger_index]`, so threshold crossings were quantized to a 50 us sample grid at 20 kSa/s.
- Fix: V0.9.4 added hysteresis, interpolated crossing time, pipeline reference alignment to that time, and ScopeWorkspace holdoff.
- Evidence: commit `e92e895`, tag `v0.9.4`, pytest `35 passed`, local ST-Link flash and COM14 `DeviceIdentity.version == 0.9.4`.

### Phase 9: Hand-in evidence correction

- User-visible problem: the first V0.9.5 README/Release screenshot used `fake://sine`, which was weaker evidence when the real board and COM14 path were available.
- Fix: V0.9.5 README/Release was retargeted to a corrected commit with a real COM14 screenshot and rebuilt assets.
- Evidence: commits `b9056c0`, `38dc09e`, tag `v0.9.5`, COM14 `DeviceIdentity.version == 0.9.5`.
