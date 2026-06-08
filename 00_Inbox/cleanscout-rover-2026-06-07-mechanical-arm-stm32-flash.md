- 日期：2026-06-07
- 项目：`F:\Project\CleanScout_rover`
- 状态：已并入 `01_Projects/cleanscout-rover-lower-firmware/`，保留为原始入库便签

## 机械臂 STM32 控制板源码首次核验与烧录

- 用户提供的新资料目录为 `docs/1.STM32控制板源代码/`，当前仍是仓库未跟踪资料，不属于现有 `firmware/openrf1_motion_controller/` 正式路径。
- 该目录本身是完整的 Keil STM32 工程，工程文件为 `docs/1.STM32控制板源代码/Project/RVMDK（uv5）/BH-STM32.uvprojx`。
- 目标芯片为 `STM32F103RC`，启动文件为 `startup_stm32f10x_hd.s`，输出产物配置为 `docs/1.STM32控制板源代码/Output/template.hex`。
- `Output/template.build_log.htm` 显示历史构建结果为 `0 Error(s), 0 Warning(s)`，但日志中的 Keil 路径 `D:\Keil_v5` 在当前机器不存在，因此本轮未做本机重新编译。
- `STM32CubeProgrammer CLI` 与已连接 STLink 成功识别目标板：
  - `Device name : STM32F101/F103 High-density`
  - `NVM size : 256 KBytes`
  - `Device ID : 0x414`
- 已直接烧录并校验 `docs/1.STM32控制板源代码/Output/template.hex`，命令链路为本机 `STM32_Programmer_CLI.exe` + `ST-LINK` + `-w ... -v -rst`，结果为 `Download verified successfully`。
- 当前源码主功能更接近“串口/PS2/8 路舵机/动作组/运动学”机械臂控制板，而不是 RF1 小车底盘闭环固件。

## 后续规则候选

1. 对新引入的 STM32 厂家/资料包，先区分“正式固件路径”和“参考资料目录”，不要直接和 RF1 正式工程混在一起。
2. 历史 `template.hex` 可用于快速上板验证，但若后续要做正式机械臂开发，应先补齐当前机器的 Keil 编译链，再把源码迁到正式 `firmware/` 路径。

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| 机械臂控制板源码是独立于 RF1 的 STM32F103RC Keil 工程 | project-only | `01_Projects/cleanscout-rover-lower-firmware/` | routed | 已写入机械臂官方基线/自研入口双路径 |
| 历史构建日志里的 Keil 路径不能默认等于当前机器可用路径 | cross-project tooling | `03_CrossProject/tooling.md` | written | `template.build_log.htm` 指向 `D:\\Keil_v5`，当前机器不存在 |
| 可先用 STLink 只读确认芯片与容量，再决定是否直接烧录历史 hex | cross-project tooling | `03_CrossProject/tooling.md` | written | 本轮 `STM32_Programmer_CLI` 只读识别 + 成功烧录 |
