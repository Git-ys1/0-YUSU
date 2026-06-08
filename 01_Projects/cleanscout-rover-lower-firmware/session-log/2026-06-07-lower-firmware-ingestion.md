# 2026-06-07 Lower Firmware Ingestion

## Scope

本轮不是继续调 RF1 参数，而是把 `CleanScout_rover` 下位机作为成熟项目子线完整入库，并同时把机械臂官方例程放到正式 `firmware/` 区。

## What Was Done

1. 把机械臂导入资料整理为：
   - `firmware/mechanical_arm_official_baseline/`
   - `firmware/mechanical_arm_controller/`
2. 更新仓库 `README.md`、`firmware/README.md`、`.gitignore`
3. 新增 `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
4. 为 `cleanscout-rover-lower-firmware` 建立完整成熟项目记忆

## Key Evidence

- current repo HEAD `2f37c8229178ce790fdda05cf2fe9fa827ac7905`
- session file `rollout-2026-03-12T15-08-02-019ce0df-b2bc-76d0-9e0e-fd78073132a1.jsonl`
- ST-Link 只读识别 + `template.hex` 烧录验证

## Administrator Verification

- 2026-06-08: yusu vault administrator ran `tools/mature-project-retro-audit.ps1`.
- Result: PASS, 0 warnings.
- Gate evidence: project path exists, engineer JSONL exists and cwd matches `F:\Project\CleanScout_rover`, required 12 project memory files exist, 244 Git commits readable, summary has 7 ranked lessons and Memory Routing Audit coverage.
