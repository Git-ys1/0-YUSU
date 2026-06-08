# Project Brief

## One Sentence

CleanScout_rover 下位机是这个大系统里负责 STM32 侧实时控制的子项目，目前包含一条已经正式化的 OpenRF1 底盘运动固件主线，以及一条刚冻结的机械臂 STM32 官方基线。

## Why This Entry Exists

`CleanScout_rover` 已经不是单一工程，而是树莓派 ROS、Vue3 前后端、OpenMV/机械臂实验、RF1 下位机等多线并行系统。为了避免后续知识库把不同工程师的内容混成一份“万能总述”，本条目只服务下位机工程师。

## Current Stable Goal

当前稳定目标分成两部分：

1. 维持 `firmware/openrf1_motion_controller/` 作为唯一底盘正式固件路径，保持当前已收敛的协议、方向表、增量 PI、目标斜坡和编译/烧录链路。
2. 从 `C-3.7.0` 起，把机械臂线明确拆成：
   - `firmware/mechanical_arm_official_baseline/`：当前最新官方 STM32 机械臂例程冻结基线
   - `firmware/mechanical_arm_controller/`：后续自研机械臂控制独立开发入口

## Current Boundaries

- 这是“下位机控制项目”，不是整车全栈项目。
- 当前 RF1 主线不再从 `_local/openrf1_keil_work_2`、`_local/openrf1_keil_work_3` 或 `_local/car_move_lihaotian` 发布。
- 机械臂当前先隔离开发，不直接并入 RF1 底盘工程。
- 旧 `jixiebi/` 保留为历史实验入口，但不再代表当前 STM32 机械臂官方基线。

## Current Verified Outputs

### RF1 正式固件

- 正式目录：`F:\Project\CleanScout_rover\firmware\openrf1_motion_controller`
- 当前主线说明：仓库内自包含 Keil 工程、独立 `build.ps1` / `flash.ps1`
- 最近明确收口文档：`docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`

### 机械臂官方基线

- 正式目录：`F:\Project\CleanScout_rover\firmware\mechanical_arm_official_baseline`
- 工程文件：`Project/RVMDK（uv5）/BH-STM32.uvprojx`
- 可直接烧录产物：`Output/template.hex`
- 最近冻结文档：`docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`

## Source Evidence

- 仓库当前主分支：`main`
- 当前 HEAD：`2f37c8229178ce790fdda05cf2fe9fa827ac7905`
- 关键文档：
  - `README.md`
  - `firmware/README.md`
  - `firmware/openrf1_motion_controller/README.md`
  - `docs/STM32F103RCT6/OpenRF1_开发速查.md`
  - `docs/000操作指令`
  - `docs/SOFTWARE/C-3.0.6_pid_close_loop_and_protocol_update.md`
  - `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`
  - `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`
  - `docs/VERIFY/C-3.1.4D_openrf1_closed_loop_smoothing.md`
  - `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`
  - `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
