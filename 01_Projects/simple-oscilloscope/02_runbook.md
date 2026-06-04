# Runbook

## Environment

- OS: Windows.
- Firmware toolchain: Keil MDK ARMCC V5, project files in repo, STM32F103C8T6 target.
- Flashing: STM32CubeProgrammer CLI through ST-Link; configured script path uses `F:\AcademicHub\STMicroelectronics\stm32cubeprogrammer`.
- PC runtime: Python 3.11 venv, PySide6, PyQtGraph, NumPy, pySerial.
- Release packaging: PyInstaller onedir, PowerShell `Compress-Archive`, Inno Setup 6.

## Common Commands

```bat
tools\setup_pc_env.bat
.venv\python.exe -m pip install -e .[dev]
.venv\python.exe -m pytest -q
tools\run_scope.bat --source fake://sine --connect
tools\run_scope.bat --source COM14 --baud 921600 --connect
python simulator\mcu_simulator.py
tools\run_scope.bat --source tcp://127.0.0.1:8765 --connect
tools\build_keil.bat
tools\flash_stlink.bat
tools\build_portable.bat
tools\package_portable_zip.bat
tools\build_installer.bat
```

## Verification

Expected V0.9.5 verification results from 2026-06-04:

- `.venv\python.exe -m pytest -q`: `35 passed`.
- `tools\build_keil.bat`: `0 Error(s), 0 Warning(s)`.
- `tools\build_portable.bat`: creates `dist\SimpleScopePC\SimpleScopePC.exe`.
- `tools\package_portable_zip.bat`: creates `dist\SimpleScopePC-0.9.5-win64-portable.zip`.
- `tools\build_installer.bat`: creates `dist\installer\SimpleScopePC-0.9.5-Setup.exe`.
- `tools\flash_stlink.bat`: connects ST-Link, downloads and verifies `Objects\SimpleOscilloscope.hex`, resets MCU.
- COM14 protocol sanity check: decode `ID?`, `CAP?`, `STATUS`; expect firmware version `0.9.5`, sample rate `20000`, and final run state `RUN`.

## Release Checklist

1. Confirm Simple Oscilloscope repo is clean or only has intended changes: `git status --short --branch`.
2. Run Python tests.
3. Build firmware with Keil.
4. Build portable app, zip, and installer.
5. Smoke test source exe with `fake://sine --connect`.
6. Smoke test zip extraction and installer install/uninstall.
7. If the user is testing the local board, flash the current hex and verify COM14 at `921600`.
8. Commit with version-first message, e.g. `v0.9.3: ...`.
9. Tag and push: `git tag -a vX.Y.Z -m "vX.Y.Z: ..."` then `git push origin main` and `git push origin vX.Y.Z`.
10. Create GitHub Release with setup exe, portable zip, firmware hex, README, and user guide.

## Troubleshooting

- Blank GUI with `设备: --` and `点数 0`: user has not connected a source. `运行` is not `连接`; use `演示` or the right-side `连接` button.
- COM14 no waveform after release: confirm firmware was flashed. Old firmware may still be 115200 or lack `CAP?`.
- Serial output looks like unreadable bytes: binary DATA frames are expected. Use `ProtocolStreamDecoder`, not direct text print.
- PyInstaller `Access is denied` under `dist\SimpleScopePC`: an old `SimpleScopePC.exe` process is still running. Stop that process before rebuild.
- Keil build may need to run outside restricted sandbox because it writes `Objects/` and `Listings/`.
- Offscreen Qt screenshots may show Chinese as boxes because the offscreen font database can be empty; verify normal Windows font database before treating it as a UI regression.

## Source Evidence

- Commands verified: pytest, Keil build, portable build, zip build, installer build, ST-Link flash, COM14 decode.
- Last verified: 2026-06-04.
