# Progress

## Current Status

**State**: active, combined firmware bench validation in progress
**Current phase**: 双串口双协议合并固件已发布，等待完整方向与 30 分钟双域长稳验收

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
- `C-5.0.3` 已完成只读审计阶段，确认官方基线解析的是总线舵机 ASCII 文本协议，而 `mechanical_arm_controller/` 目前仍为空壳
- `C-5.0.3` 追踪任务书已收敛为“固定前向姿态 + 局部视觉伺服”，完整 IK 暂只作为后续姿态/抓取层

### 合并下位机

- `firmware/cleanscout_combined_controller/` 已成为底盘与机械臂共板运行的正式候选工程
- USART2 专用于 Raspberry Pi 底盘协议，USART3 专用于 Orange Pi 机械臂协议，UART5 专用于总线舵机
- 机械臂旧 TIM7 本地 PWM 后端未进入合并工程，避免 PA8/PA9/PB11 冲突和重复执行
- Keil 构建为 `0 Error(s), 0 Warning(s)`，最终 HEX 已通过 ST-Link 写入、校验和显式启动
- USART3 六轴只读链、USART2 短时架空轮速、协议交叉拒绝、短时双路并发、两端全局急停和两个看门狗均有实机证据

## What Is Explicitly Not Finished

- 合并固件还未完成四轮六方向、RAW 模式和机械臂负载运动回归
- 双路同时在线 30 分钟、物理拔线、overflow 和控制 tick 抖动还未验收
- `ROS_READY=NO`，不得把短时台架成功扩大解释为整车 ROS-ready
- 整个 `CleanScout_rover` 的跨工程总知识库还没由其他工程师分别补齐

## Latest Milestones

| Date | Milestone | Evidence |
|---|---|---|
| 2026-04-19 | 原生 TIM 编码器主线完成最终收敛 | `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md` |
| 2026-04-20 to 2026-04-22 | 方向表与四轮平顺性热修形成可运行基线 | `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`, `docs/VERIFY/C-3.1.4D_openrf1_closed_loop_smoothing.md` |
| 2026-06-07 | RF1 正式 Keil 工程收口 | `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md` |
| 2026-06-07 | RF1 固件目录清理并合并到 `main` | commit `2f37c82` |
| 2026-06-07 | 机械臂官方基线冻结并与 RF1 分线 | `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md` |
| 2026-06-10 | `C-5.0.3` 机械臂专用网关进入只读审计 | `firmware/mechanical_arm_controller/docs/00_CODE_AUDIT.md`, `docs/PLAN/C-5.0.2_arm_bus_servo_protocol_note.md` |
| 2026-07-19 | 双串口双协议合并固件发布到 `main` | commit `5f70f732`, `docs/VERIFY/combined_dual_uart_controller_verification.md` |

## Risks That Still Matter

1. 机械臂线如果直接修改官方基线，很快会重复 RF1 早期“正式入口不清”的老问题。
2. RF1 的参数是实车硬件调出来的，工程整理时不能顺手“美化”成新算法。
3. 板内当前运行固件不能默认等于仓库最新 `hex`，烧录前后都要用真实链路核对。
