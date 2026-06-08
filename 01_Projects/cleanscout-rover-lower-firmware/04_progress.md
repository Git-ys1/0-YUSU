# Progress

## Current Status

**State**: active, lower-firmware scope mostly caught up  
**Current phase**: RF1 正式主线稳定维护 + `C-3.7.0` 机械臂独立起步

## What Is Stable Today

### RF1

- `firmware/openrf1_motion_controller/` 已是唯一正式底盘固件入口
- `build.ps1` / `flash.ps1` 工作流已成型
- `W/M/E/D/STOP` 协议语义已经冻结
- 原生 TIM 编码器主线已经从 CN1/CN3 危机里恢复
- 方向表、平顺性热修和后续工程正规化已经有文档闭环

### 机械臂

- 最新官方 STM32 机械臂例程已归位到 `firmware/mechanical_arm_official_baseline/`
- 板级芯片/容量/烧录链路已做实测核验
- `firmware/mechanical_arm_controller/` 已创建为后续独立开发占位

## What Is Explicitly Not Finished

- 机械臂自研控制逻辑还没开始
- 机械臂本机 Keil 重新编译链路还未正式复现
- 机械臂与 RF1 底盘的融合架构还未设计
- 整个 `CleanScout_rover` 的跨工程总知识库还没由其他工程师分别补齐

## Latest Milestones

| Date | Milestone | Evidence |
|---|---|---|
| 2026-04-19 | 原生 TIM 编码器主线完成最终收敛 | `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md` |
| 2026-04-20 to 2026-04-22 | 方向表与四轮平顺性热修形成可运行基线 | `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`, `docs/VERIFY/C-3.1.4D_openrf1_closed_loop_smoothing.md` |
| 2026-06-07 | RF1 正式 Keil 工程收口 | `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md` |
| 2026-06-07 | RF1 固件目录清理并合并到 `main` | commit `2f37c82` |
| 2026-06-07 | 机械臂官方基线冻结并与 RF1 分线 | `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md` |

## Risks That Still Matter

1. 机械臂线如果直接修改官方基线，很快会重复 RF1 早期“正式入口不清”的老问题。
2. RF1 的参数是实车硬件调出来的，工程整理时不能顺手“美化”成新算法。
3. 板内当前运行固件不能默认等于仓库最新 `hex`，烧录前后都要用真实链路核对。
