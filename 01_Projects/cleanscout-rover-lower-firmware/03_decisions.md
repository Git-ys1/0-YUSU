# Technical Decisions

## Decision: staged verification docs, failed branches, and checkpoints are first-class project assets

**Status**: accepted  
**Date**: 2026-06-07

### Context

这条下位机线的大部分成熟结论，不是靠一次静态设计得出的，而是靠：

- `docs/PLAN` 先写假设
- `docs/VERIFY` 记录实测
- 失败分支保留证据
- checkpoint 锁住保险回退点

如果只保留“最终对的代码”，很多为什么不能这么改、为什么某条路线已被证伪的结论会丢失。

### Decision

把以下内容视为正式资产，而不是临时噪声：

- 阶段性验证文档
- 真值表
- 失败但可回溯的分支
- 被用户明确指定为保险的 checkpoint

### Consequences

- Positive: 新工程师能知道成熟结论是如何被逼出来的，不会把旧坑重复走一遍。
- Negative: 仓库和知识库看起来不会像“天生干净项目”那样短小，需要维护阅读入口。

### Evidence

- session `[0228]`, `[0233]`, `[0362]`-`[0364]`, `[0415]`
- `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`
- `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`

## Decision: debug/control protocol should be frozen early and kept stable while board truth is still being discovered

**Status**: accepted  
**Date**: 2026-04-16

### Context

在 RF1 bringup 过程中，真正变化最频繁的是板级真值与闭环参数，而不是上位机协议形态。如果在
驱动尚未搞清楚时同时不停改协议，会让上位机、串口工具、验证文档和固件一起漂移。

### Decision

提前冻结并延续使用：

- `W,a,b,c,d`
- `M,<ch>,<pwm>`
- `E,<ch>`
- `D,<ch>`
- `STOP`

在大量 RF1 故障排查阶段，尽量不改协议，只改底层真值与控制实现。

### Consequences

- Positive: 同一套串口工具和验证命令可以横跨多个底层阶段使用。
- Negative: 协议里会保留一些更底层的调试入口，需要纪律地区分 raw 与语义层。

### Evidence

- `docs/SOFTWARE/C-3.0.6_pid_close_loop_and_protocol_update.md`
- session `[0249]`, `[0250]`, `[0303]`

## Decision: raw H-bridge truth, encoder sign, `W` chassis semantic, and physical wiring are separate layers

**Status**: accepted  
**Date**: 2026-04-20

### Context

项目在 4 月中下旬多次因为这四层混在一起而回到混乱：

- raw `+pwm/-pwm`
- encoder `delta` 正负
- `W` 车体前后左右语义
- 物理反接线后的硬件新基线

### Decision

以后所有方向相关改动必须显式说明自己改的是哪一层，且优先顺序固定为：

1. 先保留 raw `M` 真值
2. 再确定 encoder sign
3. 再修 `W` 语义方向表
4. 若物理改线发生，则重新声明当前硬件基线

### Consequences

- Positive: 能把“单轮 raw 调试”和“整车前进语义”拆开，不再相互污染。
- Negative: 文档与代码注释都必须更啰嗦，不能再口头默认“大家都懂前后左右”。

### Evidence

- `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`
- `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`
- session `[0302]`, `[0303]`, `[0358]`

## Decision: RF1 native timer encoder architecture remains the official motion path

**Status**: accepted  
**Date**: 2026-04-19

### Context

CN1/CN3 编码器危机一度逼出 `C-3.1.3` 软编码器止损分支，项目有真实风险被带到“长期绕开原生 TIM”
的路线。

### Decision

正式主线继续使用：

- `CN1 -> TIM5 + PA0/PA1`
- `CN2 -> TIM3 + PA6/PA7`
- `CN3 -> TIM2 full remap + PA15/PB3`
- `CN4 -> TIM4 + PB6/PB7`

软编码器只保留为历史止损和证据，不转正。

### Consequences

- Positive: 保住了更直接、更可维护的硬件编码器链。
- Negative: 以后通道异常时必须先做硬件证伪，不能一出问题就软件绕行。

### Evidence

- `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`
- session `[0252]`, `[0288]`
- ADR `adr/2026-04-19-rf1-native-timer-encoder-path.md`

## Decision: stable RF1 results should be merged back to main with explicit path control, not by dragging full dirty history

**Status**: accepted  
**Date**: 2026-04-18

### Context

到 `C-3.1.6`，用户已经明确要求：

- RF1 自测继续在 `feature/c-*` 上做
- 合入 `main` 时只发布自己负责路径
- 不要把 Raspberry Pi、前端或无关文档一起拖进主线

### Decision

RF1 发布遵守两层纪律：

1. 自测分支先验证、先推送。
2. 合入 `main` 时按白名单路径补充回灌，必要时新开 main-merge 集成分支。

### Consequences

- Positive: `main` 可以对其他线做参考，而不被某条下位机试验历史污染。
- Negative: 发布步骤更繁琐，不能偷懒直接整分支一把 merge。

### Evidence

- session `[0277]`, `[0278]`
- commit `4867f04`

## Decision: OpenRF1 formal firmware path is `firmware/openrf1_motion_controller/`

**Status**: accepted  
**Date**: 2026-06-07

### Context

RF1 长期依赖 `_local/openrf1_keil_work_2` 工程壳跨目录编译 `_local/openrf1_keil_work_3` 或
`_local/car_move_lihaotian` 的成熟代码。这样做虽然在混乱期帮过忙，但正式维护阶段已经成为阻碍。

### Decision

把 RF1 正式主线收口到仓库内唯一自包含工程：

```text
firmware/openrf1_motion_controller/
```

### Consequences

- Positive: 代码、工程、脚本、文档入口终于统一。
- Negative: `_local` 不能简单删除，只能降级为历史证据和归档来源。

### Evidence

- `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`
- session `[0397]`
- ADR `adr/2026-06-07-openrf1-formal-firmware-path.md`

## Decision: RF1 keeps a Keil-first plus STM32CubeProgrammer release loop

**Status**: accepted  
**Date**: 2026-06-07

### Context

用户环境、现有资产和已验证流程都围绕 Keil 工程、ST-Link 和 STM32CubeProgrammer。重新发明
OpenOCD / CMake / 自定义工具链只会在当前阶段引入新变量。

### Decision

RF1 正式发布链固定为：

```powershell
.\firmware\openrf1_motion_controller\scripts\build.ps1
.\firmware\openrf1_motion_controller\scripts\flash.ps1
```

并且在导入新 baseline 或烧录新 HEX 前，优先做 ST-Link 只读身份核验。

### Consequences

- Positive: 与现有 Windows 本机和嵌入式调试现实完全一致。
- Negative: 换机时必须重新核对 Keil/CubeProgrammer 路径。

### Evidence

- `firmware/openrf1_motion_controller/README.md`
- `docs/000操作指令`
- `03_CrossProject/tooling.md` 中对应条目

## Decision: mechanical-arm official example stays frozen; new work starts in a separate controller folder

**Status**: accepted  
**Date**: 2026-06-07

### Context

当下位机准备进入机械臂阶段时，仓库里同时存在：

- `jixiebi/` 历史实验
- `docs/1.STM32控制板源代码` 资料导入包
- 新整理的 `firmware` 目录

如果直接在官方例程上继续改，很快会重演 RF1 早期的入口混乱。

### Decision

机械臂从第一天就拆成两条目录：

- `firmware/mechanical_arm_official_baseline/`
- `firmware/mechanical_arm_controller/`

### Consequences

- Positive: 官方对照、回退基线和后续自研入口边界清楚。
- Negative: 当前会多一条尚未真正开工的占位目录，需要纪律维护。

### Evidence

- `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
- session `[0410]`-`[0412]`
- ADR `adr/2026-06-07-mechanical-arm-baseline-freeze.md`

## ADR Index

- [[adr/2026-04-19-rf1-native-timer-encoder-path]]
- [[adr/2026-06-07-openrf1-formal-firmware-path]]
- [[adr/2026-06-07-mechanical-arm-baseline-freeze]]
