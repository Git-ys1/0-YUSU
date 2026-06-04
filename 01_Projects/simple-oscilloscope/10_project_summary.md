# Project Summary

## One-Page Summary

Simple Oscilloscope matured from a small STM32/PC plotting experiment into a Keil-first embedded project with a packaged Windows upper-computer. The current V0.9.5 release is built around a reliable local workflow: Keil creates `Objects\SimpleOscilloscope.hex`, STM32CubeProgrammer flashes it through ST-Link, and SimpleScope PC connects through fake/TCP/CH340 sources using the same acquisition pipeline. The most important architectural decision is separation of transport, protocol decoding, acquisition, processing, and UI; that separation made it possible to add fake sources, TCP simulator, binary blocks, trigger logic, AutoSet, packaging, trigger interpolation, and real-hardware submission evidence without turning the UI into hardware code. The most expensive late lesson was that "tests pass" is not enough for a hand-in oscilloscope: the visible screen must behave like an instrument, the board must actually be flashed, a 1 kHz sine must look credible, and README/Release screenshots should come from real hardware when the board is available. Future work should preserve the Keil-first firmware workflow, avoid direct UI protocol parsing, and add real analog-front-end/ADC safety only when hardware evidence exists.

## Most Important Things

| Rank | Thing | Why It Matters | Evidence |
|---|---|---|---|
| 1 | Keil-first workflow is project law | It matches the user's machine and produces the real hex used for local flashing | `tools\build_keil.bat`, `tools\flash_stlink.bat`, user STM32CubeProgrammer path, V0.9.3 flash |
| 2 | PC app must stay layered | Transport/protocol/acquisition/processing/UI separation prevents GUI callbacks from becoming serial parsers | `docs/pc_app_architecture.md`, `pc_app/scope_app/**` |
| 3 | Binary DATA frames plus ASCII control are the right protocol split | It keeps human-readable commands while making higher-rate sample blocks possible | `docs/protocol.md`, tag `v0.7.0` |
| 4 | Firmware timing must be real timing, not UI range inflation | 10/20 kSa/s requires TIM2/ISR queue, not just larger macros | tag `v0.9.2`, `user/src/board.c`, `user/src/main.c` |
| 5 | Scope UI is an instrument, not a generic chart | Plot dragging, data-coordinate labels, and sample-index trigger quantization all made the screen look less credible; V0.9.4 refines the trigger lock | tags `v0.9.3`, `v0.9.4`, `waveform_view.py`, `trigger.py` |
| 6 | Release evidence must include real hardware when hardware is available | The user was testing a real board; unflashed firmware and fake-source screenshots made app behavior or submission evidence misleading | V0.9.3/V0.9.5 package smoke, ST-Link flash, COM14 decode, real COM14 screenshot |
| 7 | Safety claims must stay conservative | STM32 ADC without analog front-end is 0-3.3 V only; no mains/high-voltage claims | `README.md`, `docs/user_guide_pc.md` |

## Final Shape

- Current stable architecture: STM32 firmware + binary/ASCII protocol + layered PySide6 upper-computer + TCP/fake simulator + Windows release chain.
- Current working workflow: test PC app, build firmware, package PC app, smoke test fake/zip/installer, flash board, verify COM14, commit/tag/release.
- Current product boundary: a teaching/demo single-channel scope/signal-source workflow, not a certified measurement instrument or high-voltage scope.
- What should not be casually changed: Keil workflow, CH340/USART assumptions, binary protocol framing, UI layering, plot lock, safety warnings, version-first release naming.

## Hard-Won Lessons

- Matching firmware matters as much as matching GUI version.
- A generic plotting widget can undermine oscilloscope credibility if its default interactions remain enabled.
- Binary streams are normal here; do not debug them with plain text assumptions.
- Packaging on Windows is process-sensitive; running exe locks dist files.
- Offscreen smoke tests are useful but not a complete visual QA substitute.
- Sub-sample trigger timing matters for instrument credibility; at 20 kSa/s, one sample is visibly large on a 500 us/div screen.
- Submission-facing screenshots should use real hardware data when hardware is connected and validated; fake sources are only explicit demo/fallback evidence.

## Rules For Future Codex

- Always start firmware tasks with `git status --short --branch`, then use existing Keil and STM32CubeProgrammer scripts.
- Always verify a release with tests, Keil build, package smoke, and matching version numbers.
- Always distinguish `Connect` from `Run` in user-facing diagnosis.
- Never claim real board readiness after firmware changes unless the board was flashed or you explicitly say it was not.
- Never feed binary serial output directly to human text interpretation; use `ProtocolStreamDecoder`.
- Check first: old `SimpleScopePC.exe` processes, COM port, baud, protocol, firmware version, and sample rate.
- Escalate to user when: physical wiring is unknown, analog front-end/high-voltage measurement is requested, or a destructive git/hardware action is ambiguous.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| Keil-first workflow and local flashing are project-specific and must be preserved | project-only | `01_Projects/simple-oscilloscope/02_runbook.md` | kept | User path, `tools\build_keil.bat`, `tools\flash_stlink.bat`, V0.9.3 flash |
| UI source/protocol/acquisition/processing boundaries prevent desktop apps from becoming untestable serial scripts | cross-project pattern | `03_CrossProject/patterns.md` | written | `docs/pc_app_architecture.md`, PC layering commits |
| Instrument-like UI chrome should not be data-coordinate plot annotations | cross-project pitfall | `03_CrossProject/pitfalls.md` | written | User V0.9.3 feedback, `waveform_view.py` |
| Windows packaging can fail when the previous packaged exe is still running | cross-project tooling | `03_CrossProject/tooling.md` | written | V0.9.3 PyInstaller `Access is denied` incident |
| Hardware release is not complete until firmware is flashed or explicitly marked unflashed | cross-project pattern | `03_CrossProject/patterns.md` | written | V0.9.3 user question and flash verification |
| Simple Oscilloscope project should be discoverable from project and tool maps | map only | `06_Maps/project-map.md`, `06_Maps/tool-map.md`, `06_Maps/pitfall-map.md` | written | This ingestion |
| Real ADC/front-end measurement maturity remains unproven | deferred | `01_Projects/simple-oscilloscope/06_todo_next.md` | pending | README safety limits, no analog front-end evidence |
| Sample-index trigger quantization should be routed as a cross-project instrument UI pitfall | cross-project pitfall | `03_CrossProject/pitfalls.md`, `06_Maps/pitfall-map.md` | written | V0.9.4 user task, `trigger.py`, `pipeline.py`, commit `e92e895` |
| Submission screenshots should use real hardware data when connected hardware is available | cross-project pattern | `03_CrossProject/patterns.md` | updated | V0.9.5 user correction, real COM14 screenshot, commits `b9056c0`, `38dc09e` |

## Remaining Risks

| Risk | Why It Remains | Next Check |
|---|---|---|
| Real ADC measurement path is not fully proven | Current demo path focuses on generated waveform/PWM/sample stream | Add hardware ADC acquisition test and analog front-end docs |
| 20 kSa/s is a teaching/demo ceiling | STM32F103C8T6 UART and firmware design are limited | Measure sustained real throughput before raising claims |
| Installer is unsigned | Current hand-in path does not require code signing | Add signing only for wider distribution |
| User wiring may differ from USART1 PA9/PA10 | Some boards expose CH340 differently | Confirm schematic/actual wiring before changing firmware pins |

## Source Links

- Development history: [[07_development_history]]
- Known issues: [[05_known_issues]]
- Decisions/ADR: [[03_decisions]]
- Session evidence: [[09_session_evidence]]
