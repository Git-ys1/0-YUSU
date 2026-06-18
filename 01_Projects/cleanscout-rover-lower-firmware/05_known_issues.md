# Known Issues

## How To Use This File

这里记录的不是“当前还有哪些 bug 没修”，而是最容易让新工程师重复踩坑的历史问题。
很多坑已经在当前主线上绕过去了，但如果不了解它们是怎么发生的，就会在下一轮机械臂或
RF1 改动里原样重演。

## Issue: `_local` / `work2` / `work3` / `car_move_lihaotian` 容易制造“到底哪份代码在跑”的假象

### Symptom

- 代码已经改了，但板上行为不像改后的样子。
- `work2` 像工程壳，`work3` 像源码，`car_move_lihaotian` 又像更新版真源，谁都像主线。
- 文档里说的是 A 路径，实际 Keil 编进去的是 B 路径。

### Why It Happened

RF1 早期成熟过程是从多个实验工作副本里长出来的，不是一开始就有仓库内单一正式工程。

### What Finally Fixed It

- 明确审计旧 Keil 工程到底真实编了哪些源文件。
- 把实际运行路径收口到 `firmware/openrf1_motion_controller/`。
- 把 `_local/` 降级成历史证据和过渡副本，而不是继续发布的入口。

### Rule

以后凡是讨论“当前固件行为”，先回答两个问题：

1. 当前实际编译入口是不是 `firmware/openrf1_motion_controller/`？
2. 当前烧录到板上的镜像是不是从这条入口出来的？

### Evidence

- `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`
- session `[0397]`
- commit `d3710ed`

## Issue: 板上行为不等于仓库当前代码，很多“代码错了”最后其实是没重新编译或没烧进去

### Symptom

本地代码看起来已经改对，但板上现象仍像旧版本，进而让团队怀疑方向表、PWM 模型甚至驱动逻辑全都坏了。

### Why It Happened

项目早期存在大量手工烧录、跨目录工程、不同工作副本，加上实机联调节奏很快，“我以为已经烧了”
很容易变成错误前提。

### What Finally Proved It

session `[0365]` 中，用户在一轮强怀疑后明确说出：

- “原来是我忘烧录编译了……”

这条证据非常宝贵，因为它说明 Git 与本地源码都不能替代板上真实镜像确认。

### Rule

每次关键判断前都要做最小闭环：

1. 编译
2. 烧录
3. 串口看 `CSR_RF1_READY`
4. 再执行 `M/W/E/D/STOP` 验证

### Evidence

- session `[0365]`
- `docs/000操作指令`

## Issue: 不能把 `_work_2`、vendor 示例或“以前能转的片段”直接当成当前板子的真值来源

### Symptom

某段旧代码或 vendor 例程在历史板子上看起来“成功过”，于是团队倾向把它直接搬到当前运行层，
希望尽快复现成功现象。

### Why It Happened

OpenRF1 bringup 早期，驱动是否真打通本来就不明确，复制看起来最快。

### What Finally Corrected It

session `[0228]` 中，用户直接否定了“继续参考 `_work_2` 成功语义修 `_work_3`”这条路，要求：

- 先冻结失败支线
- 再新开 `C-3.0.5B`
- 只根据当前板子的 `CN1~CN4 +700/-700` 真值表来重写四路驱动

### Rule

以后引用旧片段只能做“对照”，不能直接做“真值”。真值必须来自当前板、当前通道、当前命令下的实测。

### Evidence

- session `[0228]`
- `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`

## Issue: raw H 桥真值、编码器符号、`W` 车体语义、物理改线是四层问题，混着改就会把方向修乱

### Symptom

典型表现包括：

- `M,<ch>,<pwm>` 看着对，`W,a,b,c,d` 却不对
- 四轮同号前进时，部分轮子对抗
- 改了电机方向表后，编码器符号又错
- 物理反接线之后，软件还沿用旧符号解释

### Why It Happened

团队在最痛的阶段同时面对：

- raw PWM 正负含义
- 编码器 delta 正负
- 车体 LR/LF/RR/RF 语义
- 实物电机线是否已反接

这些如果不分层记录，就会出现“方向修一次乱一次”。

### What Finally Fixed It

- 用 `C-3.0.5` 真值表先固定 raw 单通道现象。
- 到 `C-3.1.4C` 再明确 `g_csr_motor_dir_sign` / `g_csr_encoder_dir_sign` 只服务 `W` 语义。
- 到 `C-3.3.1A` 再把 `CN1/LR, CN2/LF, CN3/RR, CN4/RF` 写死。

### Rule

讨论方向前，先说清你改的是哪一层：

1. raw H 桥驱动真值
2. 编码器符号
3. `W` 车体语义
4. 物理改线后的新硬件基线

### Evidence

- `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`
- `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`
- session `[0302]`, `[0303]`, `[0358]`

## Issue: CN1/CN3 没反馈时，第一怀疑项不该是“TIM 架构坏了”

### Symptom

`CN2/CN4` 有反馈，`CN1/CN3` 没反馈，很容易让人把问题归因到：

- TIM5 / TIM2 full remap 配错
- JTAG 没释放
- 软件编码器读取链本身失效

### Why It Happened

这类软件解释在表面现象上很合理，而且 `CN3` 的确牵涉 PA15/PB3 与 `SWJ_CFG`。

### What Finally Proved Otherwise

最终真正决定性的证据不是代码 diff，而是交叉硬件测试：

- 新电机与旧电机互换
- `CN1/CN2` 控制组交叉
- `7.4V` 与 `12V` 电池对比
- 把可疑白线线簇换成彩虹线

`C-3.1.4B` 最终写死：原生 TIM 主线成立，问题主要跟着电机编码器链、线簇/线序、接触状态走。

### Rule

以后 `CN1/CN3` 再无数时，排查顺序固定为：

1. 相位/GPIO 原始变化
2. 换控制组好电机
3. 换线簇/接插件
4. 再怀疑 TIM/remap/GPIO 初始化

### Evidence

- session `[0252]`, `[0283]`-`[0288]`
- `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`

## Issue: 软编码器分支能救场，但会遮蔽“原生主线到底有没有真的坏”

### Symptom

当原生编码器链出问题时，循迹口软编码器能很快给出“终于有数了”的正反馈，容易让团队默认它可以直接转正。

### Why It Happened

项目当时需要止损，需要继续推进闭环，不可能一直停在“没数”状态。

### What Finally Fixed It

团队把 `C-3.1.3` 明确降级为：

- 问题定位/止损证据分支
- 不是正式主线

随后又回退到原生 TIM 主线，用好电机、好线簇做复测，把正式链路重新保住。

### Rule

在硬件项目里，止损分支要保留，但必须明确标出：

- 它解决了推进问题
- 它没有自动解决根因问题

### Evidence

- commits `cd1a656` through `3236145`
- `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`
- session `[0277]`, `[0278]`

## Issue: “同步”是正确目标，但如果在真值还没分层前直接追同步，团队会误把同一个 PWM 当成同一个语义

### Symptom

典型表现：

- 强烈要求四轮完全同一个 raw 值
- 抗拒任何 per-wheel 起步补偿、差分最小驱动或 `2000-raw` 映射
- 只要某个轮子速度节奏不同，就倾向认为底层抽象一定写错了

### Why It Happened

用户的目标本身没有错，问题在于它出现在一个真值尚未完全拆清的阶段：

- `CN1/CN3` 的方向与物理线序还在变化
- `2000-raw` 争议尚未定性
- `39c481f` 还没被确认为绝对保险基线

### What Finally Stabilized It

- 用多个 checkpoint 把每一轮危险尝试锁住：`f826b3d`, `167c3f8`, `39c481f`
- 用户亲自做物理反接线，再要求软件统一
- 把 `39c481f` 指定为绝对保险基线，不允许再无纪律地漂移

### Rule

以后遇到“必须同步”的诉求，先问：

1. 物理线序是否已稳定？
2. raw 真值、编码器符号、`W` 语义是否已经拆开？
3. 当前保险 checkpoint 是哪个？

如果这三件事没说清，同步调参会重新把项目打回混乱期。

### Evidence

- session `[0339]`-`[0364]`
- checkpoints `f826b3d`, `167c3f8`, `39c481f`

## Issue: 保险 checkpoint 一旦被口头神圣化，就绝不能继续在其上随手改

### Symptom

团队口头上把某个 commit 称为“绝对基线”或“随时可回退保险”，但如果后续又在其工作树上继续叠改，
保险作用就会被破坏。

### Why It Happened

实机联调节奏太快，且每轮都想“顺手再试一下”。

### What Finally Proved The Need

用户在 `[0362]`、`[0363]`、`[0364]` 连续要求回退到 `39c481f`，并质疑“是不是把我的 39c481f 给改了”。

这段话说明在硬件项目里，用户对保险基线的信任本身就是交付物的一部分。

### Rule

被宣布为保险的 checkpoint：

- 只能回退到它
- 不能一边叫它保险，一边继续在其状态上口头漂移

### Evidence

- session `[0356]`, `[0362]`, `[0363]`, `[0364]`

## Issue: 历史 build log 证明不了当前机器有完整工具链

### Symptom

`template.build_log.htm` 显示历史某台机器 `0 Error(s), 0 Warning(s)`，但当前机器并不一定有日志里那条 Keil 路径。

### Why It Happened

vendor baseline 常常带着旧机器生成的日志、HEX 和工程文件一起进入仓库。

### What Finally Fixed It

机械臂官方基线阶段把历史 build log 只当成“曾经成功过”的证据，不把它当成“当前可复现编译”的证据；
当前机器先做 ST-Link 只读核验，再用现成 `template.hex` 烧录。

### Rule

对任何新导入 STM32 baseline，都要区分：

- 历史构建证据
- 当前机器可复现的真实编译链

### Evidence

- `firmware/mechanical_arm_official_baseline/Output/template.build_log.htm`
- `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`

## Issue: 机械臂如果不先冻结官方基线，很快会重演 RF1 入口混乱

### Symptom

机械臂相关内容同时存在于：

- `jixiebi/`
- `docs/1.STM32控制板源代码`
- 新导入的 `firmware` 目录

如果没有正式边界，很快就会再次出现“哪份是官方、哪份是我们改过的、哪份才是当前主线”的混乱。

### Why It Happened

机械臂在线之前更多是资料和实验线，不像 RF1 那样已经逼出了单一入口。

### What Finally Fixed It

`C-3.7.0` 明确冻结：

- `firmware/mechanical_arm_official_baseline/`
- `firmware/mechanical_arm_controller/`

让“官方对照”和“后续自研”从第一天起就分开。

### Rule

机械臂后续开发默认只在 `mechanical_arm_controller/` 起刀，官方基线只做对照和回退。

### Evidence

- session `[0410]`-`[0412]`
- `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`

## Issue: 末端挂载重相机时，主臂前伸会让腕部舵机失去抬升能力

### Symptom

机械臂 `001/002` 向前展开时，末端相机把重心推到离底座很远的位置；`003` 低头后可能因静态力矩过大而无法重新抬起。

### What Proved It

2026-06-11 实机中，原 `001=1350、002=1750` 姿态发生上述故障。随后根据官方运动学方向，分级增大
`001/002`，最终在 `001=1700、002=2150` 命令下读回 `1680/2150`，主臂形成靠近底座上方的反折姿态，
末端相机仍能看到桌面目标。

### Rule

- 有重末端负载时，启动先折回承重关节，再启动腕部视觉俯仰。
- 不要让 `003` 在主臂长距离前伸时独自承担恢复动作。
- 安全预备姿态必须分段慢速进入，视觉追踪只连续微调 `000/003`。

### Evidence

- `docs/VERIFY/C-5.0.3_arm_tracking_strategy.md`
- `OrangePi/rk3588_ai/arm_tracking_demo/config/arm_track_config.yaml`
