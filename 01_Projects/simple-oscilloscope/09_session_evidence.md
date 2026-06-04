# Session Evidence

本文件记录项目入库用过哪些聊天、Git、日志和文档证据。当前工程师只复盘自己的单个 JSONL，不读取其他工程师 JSONL。

## Evidence Inventory

| Source Type | Path / Command / URL | Date Range | Why Relevant | Status |
|---|---|---|---|---|
| Engineer Codex JSONL | `C:\Users\yusu\.codex\sessions\2026\06\01\rollout-2026-06-01T16-48-42-019e825e-e5eb-7bb0-8af4-fe84f1579c21.jsonl` | 2026-06-01 to 2026-06-04 | Main Codex session for this project; includes V0.9.x development, release, flash, user feedback | used |
| Git history | `git log --reverse --date=short --pretty=format:"%ad %h %s"` | 2026-06-01 to 2026-06-04 | Reconstructs version timeline from bootstrap to V0.9.5 | used |
| Tags | `git tag --sort=creatordate` | v0.1.0 to v0.9.5 | Release checkpoints | used |
| Project docs | `README.md`, `docs/protocol.md`, `docs/pc_app_architecture.md`, `docs/user_guide_pc.md` | current | Current architecture, protocol, runbook, and limits | used |
| Source files | `pc_app/scope_app/**`, `user/src/**`, `tools/*.bat` | current | Architecture and toolchain evidence | used |
| Release | `https://github.com/Git-ys1/SimpleOscilloscope/releases/tag/v0.9.5` | 2026-06-04 | Published V0.9.5 assets, hand-in README, and real COM14 screenshot | used |
| Command logs | pytest, Keil build, package build, installer smoke, ST-Link flash, COM14 decode | 2026-06-04 | Proves current operational path | used |

## Engineer Session File

Located with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File F:\AcademicHub\0#YUSU\tools\find-own-codex-session.ps1 -ProjectPath "F:\Project\Simple Oscilloscope"
```

| Session ID | JSONL Path | CWD | Size MB | Date | Evidence Extracted |
|---|---|---|---:|---|---|
| `019e825e-e5eb-7bb0-8af4-fe84f1579c21` | `C:\Users\yusu\.codex\sessions\2026\06\01\rollout-2026-06-01T16-48-42-019e825e-e5eb-7bb0-8af4-fe84f1579c21.jsonl` | `f:\Project\Simple Oscilloscope` | 8.29 | 2026-06-01 start, last write 2026-06-04 | V0.9.2/V0.9.3/V0.9.4/V0.9.5 user feedback, build/package/release/flash verification, COM14 decode |

## Other Engineers

| Engineer / Session Owner | JSONL Path | Status | Notes |
|---|---|---|---|
| Other future Codex sessions | not read by this engineer | pending | They should append their own evidence if they continue the project |

## Extracted Turning Points

| Date | Turning Point | Evidence | Files Updated |
|---|---|---|---|
| 2026-06-01 | Repo initialized and first firmware/PC structure created | commits `b0dc0fb`, `bf48138` | project root, `user/`, `pc_app/` |
| 2026-06-01 | PC app moved to PySide6 layered design | commit `2202e51`, tag `v0.2.1` | `pc_app/scope_app/**` |
| 2026-06-01 | Display controls and measurement features grew | tag `v0.3.0` | `ui/control_panel.py`, `ui/waveform_view.py` |
| 2026-06-01 | Binary DATA frame became core protocol path | tag `v0.7.0` | `protocol/stream_decoder.py`, `user/src/protocol.c` |
| 2026-06-02 | Productized UI and docs stabilized | tag `v0.8.0` | `docs/`, `ui/*` |
| 2026-06-02 | Windows packaging/release chain landed | tag `v0.9.1` | `.github/workflows/release-windows.yml`, `tools/build_portable.bat`, `packaging/windows/SimpleScopePC.iss` |
| 2026-06-04 | Timer sampling/CAP/AutoSet/Chinese panels landed | tag `v0.9.2` | `user/src/board.c`, `processing/autoset.py`, `ui/i18n.py` |
| 2026-06-04 | User rejected drift/pointy sine; V0.9.3 fixed display | tag `v0.9.3` | `waveform_view.py`, `trigger.py`, `signal.c` |
| 2026-06-04 | Local board flashed and verified | ST-Link output, COM14 decode | `Objects\SimpleOscilloscope.hex` |
| 2026-06-04 | V0.9.4 refined trigger lock and was released | commit `e92e895`, tag `v0.9.4`, release assets | `trigger.py`, `pipeline.py`, `scope_workspace.py`, `tests/test_trigger.py` |
| 2026-06-04 | V0.9.5 corrected hand-in README and real hardware screenshot | commits `b9056c0`, `38dc09e`, tag `v0.9.5`, release assets | `README.md`, `docs/images/pc_app_v0_9_5_main.png` |

## Evidence Gaps

- [ ] Early product intent before the first commits is not independently documented outside the git/session record.
- [ ] Installer and zip smoke tests are in session/tool output, not a committed CI log.
- [ ] Real ADC input measurement path remains future work; current evidence mainly proves generated waveform/PWM/sample stream and PC acquisition.
