# Onboarding From Zero

## Why This Onboarding Is Strict

CleanScout_rover 下位机不是“打开 Keil、改 `main.c`、烧进去看看”这种简单项目。这里已经发生过多次代价很高的误判：旧工程能转但不代表当前板真值正确，串口能回传但不代表 PWM 层正常，编码器有数但不代表轮位语义正确，仓库有 hex 但不代表板上已经烧的是它。

如果你是新来的下位机工程师，第一天最重要的能力不是马上写新功能，而是先判断自己到底站在哪条证据链上。

## First 30 Minutes

先把项目拆成四类，不要混：

| Category | Path | Meaning | First Rule |
|---|---|---|---|
| RF1 底盘正式主线 | `firmware/openrf1_motion_controller/` | 当前 OpenRF1 四轮底盘固件入口 | 只在这里维护 RF1 |
| 机械臂官方冻结基线 | `firmware/mechanical_arm_official_baseline/` | 官方 STM32 机械臂例程对照 | 默认只读、烧录验证、做对照 |
| 机械臂自研入口 | `firmware/mechanical_arm_controller/` | 后续我们自己的机械臂控制开发 | 新功能从这里起步 |
| 历史资料和旧副本 | `_local/`, `jixiebi/`, docs 历史包 | 排障证据、旧实验、vendor 资料 | 不要重新指定为正式入口 |

读完这张表再开文件。这个项目历史上最大的混乱之一，就是 work2/work3、`_local`、正式仓库和板内固件互相混用。

## First Day

按这个顺序读，不要跳过历史：

1. 仓库根 `README.md`
2. `firmware/README.md`
3. `firmware/openrf1_motion_controller/README.md`
4. `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`
5. `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
6. `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`
7. `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`
8. `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`
9. `docs/VERIFY/C-3.1.4D_openrf1_closed_loop_smoothing.md`
10. YUSU 本条目的 `05_known_issues.md`, `07_development_history.md`, `09_session_evidence.md`

前 5 个文件告诉你现在入口在哪。后 5 个文件告诉你为什么这个入口不能再随便改。

## Minimal Working Loop

这一节的核心不是“会敲命令”，而是确认代码、构建产物、烧录对象和板上现象在同一条链路上。

## Before Editing RF1

### Minimum Questions

1. 这次改动是否真的属于 RF1，而不是机械臂或上位机。
2. 现象属于 raw H 桥层、编码器层、`W` 协议层、轮位语义层、机械结构层，还是上位机命令层。
3. 当前板上固件是否已经通过 build+flash+serial 证明是最新产物。
4. 是否触碰了轮序、方向表、PWM 映射、编码器符号、PID 参数、watchdog 或串口协议。
5. 有没有需要先设 checkpoint。

### Minimum RF1 Loop

```powershell
git status --short --branch
.\firmware\openrf1_motion_controller\scripts\build.ps1
.\firmware\openrf1_motion_controller\scripts\flash.ps1
.\tools\openrf1_serial_probe.ps1
```

串口至少确认：

1. 启动有 `CSR_RF1_READY`
2. `STOP` 能停车
3. `M,<ch>,<pwm>` raw 调试仍符合当前文档
4. `W,a,b,c,d` 仍有 `VEL/PWM` 或现有诊断输出
5. 停发 `W` 后 watchdog 仍能停车

如果这条链路不通，不要直接调 PID。先证明当前固件真的跑在板上。

## Before Editing Mechanical Arm

### Understand The Two Mechanical-Arm Directories

`firmware/mechanical_arm_official_baseline/` 是官方例程冻结基线。它的价值是对照和回退，不是给你直接开始改的地方。

`firmware/mechanical_arm_controller/` 是我们后续自研控制入口。第一版应该非常小：串口回显、单舵机动作、动作组触发、基础安全停止。不要一开始就做整车融合、运动学或复杂动作编排。

### Minimum Mechanical-Arm Baseline Check

1. ST-Link 只读确认芯片身份、容量、连接稳定。
2. 核对要烧录的 `hex` 来自哪个目录。
3. 如果只是验证官方基线，烧 `mechanical_arm_official_baseline` 的现有产物。
4. 记录串口、舵机、电源、动作组现象。
5. 只在官方行为可复现后，再开始 `mechanical_arm_controller/` 的最小工程壳。

### First Safe Mechanical-Arm Change

第一处安全改动不应该是“把整个官方工程复制后大改”。更稳的顺序是：

1. 新建或补齐 `mechanical_arm_controller/` 的最小工程说明。
2. 把官方基线里最小启动、时钟、串口、舵机 PWM 或总线初始化拆出来。
3. 只做一个可观察动作，例如单舵机固定角度或动作组编号回显。
4. 写下 build/flash/serial 证据。
5. 再考虑协议抽象。

## Common Newcomer Traps

### Trap 1: 把历史副本当成真值

`_local/openrf1_keil_work_2` 曾经有成功现象，但 session `[0228]` 已经明确证明：不能把它的成功语义直接套到当前 RF1。后续机械臂也一样，官方例程成功只代表官方基线成功，不代表自研控制层正确。

### Trap 2: 看到 CN1/CN3 异常就先改软件架构

CN1/CN3 危机期间，项目试过软编码器止损，但最终证据来自硬件对照。以后看到机械臂某路不动、某舵机不回、某串口没响应，也要先做供电、接线、端口、电平、设备对调。

### Trap 3: 把“同步”理解成单一层面的同值

RF1 四轮同步争议里，用户追求四轮同 raw、同节奏，这个目标是正确的。但历史也证明 raw、编码器、车体语义、物理改线是四层。机械臂里也会出现类似问题：舵机正方向、动作组正方向、机械臂坐标正方向不一定天然一致。

### Trap 4: 忘记重新编译烧录

session `[0365]` 记录过一次重要误判：代码看起来不对，最后发现只是没重新编译烧录。这不是小插曲，它是嵌入式开发的常见根因。以后任何实车现象归因前，先确认板上固件版本。

### Trap 5: 污染 checkpoint

`39c481f` 曾被用户指定为绝对基线。不要把这种点当作普通开发状态继续改。机械臂也要形成类似基线：官方冻结、第一次烧录成功、第一次串口成功、第一次单舵机成功。

## What To Record After Your First Real Change

每一次真正改变下位机行为，都至少记录：

| Field | Required Content |
|---|---|
| Line | RF1 / mechanical-arm official baseline / mechanical-arm controller |
| Source | 改了哪个正式目录 |
| Build | 当前可复现构建命令或明确说明尚不可复现 |
| Flash | 烧录工具、hex 路径、ST-Link 或串口证据 |
| Runtime | 板上启动标识、串口输出、实际动作 |
| Risk | 影响轮序、方向、PWM、编码器、协议、舵机安全中的哪一类 |
| Rollback | 最近可回退 commit 或 checkpoint |

## If Rebuilding From Scratch

正确顺序不是“先写一版驱动”。

1. 建正式目录，不让资料包、官方例程、实验目录混成一个入口。
2. 先做只读硬件身份确认。
3. 再烧官方或最小基线。
4. 建 raw 真值表，不急着封装高级语义。
5. 建传感器/编码器/反馈最小证据。
6. 再定义上层协议。
7. 最后才做 PID、平滑、动作组、运动学或整车融合。

RF1 的历史已经证明，跳过前 5 步会让第 7 步完全不可解释。
