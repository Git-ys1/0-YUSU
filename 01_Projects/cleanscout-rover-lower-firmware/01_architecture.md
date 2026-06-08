# Architecture

## Current Shape

CleanScout_rover 下位机当前不是一套单工程，而是三个层级：

1. 正式底盘固件主线
2. 机械臂官方冻结基线
3. 历史/证据型副本

## Directory Truth Table

| Path | Role | Status | Why It Matters |
|---|---|---|---|
| `firmware/openrf1_motion_controller/` | RF1 底盘正式固件 | authoritative | 当前唯一允许继续维护、编译、烧录、发布的底盘 STM32 工程 |
| `firmware/mechanical_arm_official_baseline/` | 机械臂官方例程冻结基线 | authoritative baseline | 当前机械臂 STM32 官方起点，用于对照、回退、重新烧录 |
| `firmware/mechanical_arm_controller/` | 机械臂后续自研目录 | placeholder | C-3.7.0 起先隔离推进机械臂控制，再考虑与底盘融合 |
| `firmware/archive/openrf1_keil_overlay/` | 旧 RF1 overlay | archive | 历史归档，不再做当前入口 |
| `_local/` | 本地实验与历史工作副本 | evidence only | 保留排障证据，但不是发布/编译真值 |
| `jixiebi/` | 旧机械臂视觉/抓取实验线 | historical experiment | 不再代表当前 STM32 机械臂基线 |

## RF1 Data Flow

当前 RF1 主线的数据流是：

```text
上位机串口命令 / 本地串口探测脚本
-> csr_proto.c 解析 W / M / E / D / STOP
-> main.c 控制循环
-> csr_motor_drv.c 输出 TIM8 PWM 与方向线
-> csr_encoder_drv.c 读取 TIM2 / TIM3 / TIM4 / TIM5 编码器
-> VEL / PWM / NAVDBG / ENC / DBG 遥测回传
```

关键语义：

- `W,a,b,c,d`：四轮目标速度锁存，持续闭环
- `M,ch,pwm`：原始 PWM 调试入口
- `E/D`：编码器和底层诊断
- `STOP`：清状态并停车

## Mechanical-Arm Data Flow

当前机械臂官方基线的数据流是：

```text
UART / PS2 输入
-> parse_cmd / parse_action
-> 舵机目标 / 动作组调度
-> y_servo / y_timer
-> W25Q64 参数与动作存储
-> 简单运动学接口
```

它当前不是 RF1 四轮底盘闭环的一部分，而是独立的机械臂控制板逻辑。

## Hardware Scope

### OpenRF1

- MCU：STM32F103RCT6（Keil Device 使用 `STM32F103RC`）
- 4 路编码电机
- TIM8 PWM + TIM2/3/4/5 编码器
- USART2 / COM14 串口联调
- SWD 下载调试

### 机械臂控制板官方基线

- MCU：STM32F103RC 高密度配置
- 多路舵机
- PS2
- W25Q64
- 动作组 / 运动学

## Architecture Evolution

| Date/Phase | Shape | Why It Changed | Evidence |
|---|---|---|---|
| 2026-03-12 to 2026-04-08 | UNO / Tyler 基线 + 文档归档 | 先把旧资料、UNO 调试、协议和接线现实收入口径 | commits `930c224` to `4b2d6dc` |
| 2026-04-14 to 2026-04-16 | OpenRF1 真值重建 + 最小自写底层 | 旧底层语义混乱，需要直接掌握电机、编码器、协议真值 | commits `7d355b1`, `70b8602`, `9a1009d` |
| 2026-04-16 to 2026-04-19 | 原生 TIM 编码器主线恢复 | CN1/CN3 编码器危机迫使项目在硬件、线束、软件映射之间做证伪 | commits `346f6a8` through `725e161` |
| 2026-04-19 to 2026-04-22 | 方向表/闭环平顺性热修 | 从“能数到”推进到“车能按车体语义持续走” | commits `0a49938`, `e664d99`, `38991e5` |
| 2026-05-19 to 2026-06-07 | 仓库总述 + 正式固件收口 | 项目从实验态进入交接态，必须消除 `_local` 跨目录工程幻觉 | commits `e13732c` to `2f37c82` |
| 2026-06-07 onward | 机械臂官方基线冻结 + 独立开发起点 | 下位机主线终于赶上来，可以把机械臂单独拉成新阶段 | `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md` |

## What Must Not Be Casually Changed

1. RF1 正式路径：`firmware/openrf1_motion_controller/`
2. RF1 协议语义：`W/M/E/D/STOP`
3. 轮序真值：`CN1/LR、CN2/LF、CN3/RR、CN4/RF`
4. 机械臂官方冻结基线与后续自研目录的边界
5. `_local/` 只是历史证据，不得再被当成正式入口
