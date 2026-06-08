# Project Summary

## One-Page Summary

CleanScout_rover 下位机这条线的价值，不在于今天终于有一个整洁的 `firmware/` 目录，而在于团队已经为这份整洁付过真实的硬件联调成本。

早期项目从 UNO / Tyler 旧线进入 OpenRF1 时，并没有一个可靠的“板级真值”。`_local/openrf1_keil_work_2`、`_local/openrf1_keil_work_3`、vendor 示例、手工烧录产物、串口现象、实车反馈同时存在，导致很多问题看起来像软件 bug，其实可能是没有烧进去、线簇接触不良、电机编码器链异常、轮位语义错、物理方向和代码方向没有分层，或者只是当前板上跑的不是仓库里那份代码。

项目真正成熟的分水岭有三次。第一次是 `C-3.0.5` 真值表阶段：用户明确否定“照抄 work2 成功语义”，要求在当前 RF1 板上重建四通道双向 raw 事实，最后经历约 8 小时把四路双向驱动打通。第二次是 `C-3.1.4B` 编码器收敛阶段：CN1/CN3 危机没有被软编码器绕行带偏，最终靠新旧电机、12V/7.4V、白线/彩虹线等硬件对照保住了原生 TIM 主线。第三次是 `C-3.6.0` 正式工程收口：RF1 底盘固件从 `_local` 多副本迁到 `firmware/openrf1_motion_controller/`，机械臂也在 `C-3.7.0` 被拆成官方冻结基线和自研入口。

所以这个项目不是“以前文档乱、现在把乱的删掉”。更准确地说：历史文档里很多是阶段性断言，是在当时证据不足、硬件不稳定、工具链不清时留下的排查坐标。后续机械臂开发要继承的不是那些旧参数，而是这种纪律：先冻结真值，再小步改；先证明板上跑的是哪份代码，再解释现象；先区分官方基线和自研入口，再扩展功能。

## Most Important Things

| Rank | Thing | Why It Matters | Evidence |
|---|---|---|---|
| 1 | `_local/work2/work3` 混乱不是审美问题，而是下位机事实污染源 | 很多“代码不对”的争执，本质是工程入口、烧录产物、板上固件三者没有闭环 | session `[0397]`; `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md` |
| 2 | `C-3.0.5` 真值表是 RF1 自证能力的起点 | 用户在 `[0228]` 直接要求抛开 work2 旧语义，在当前板上重新测 raw H 桥真值；`[0233]` 记录了 8 小时后四路双向终于打通 | `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`; session `[0228]`-`[0233]` |
| 3 | CN1/CN3 编码器危机最后靠硬件证伪收敛，不是靠“再改一层软件” | 软编码器分支能止损，但最终保住原生 TIM 主线靠的是电机、供电、线簇、线序对照 | `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`; session `[0249]`, `[0252]`, `[0283]`-`[0288]` |
| 4 | raw 驱动、编码器符号、`W` 车体语义、物理改线必须分层 | 把这四层混改会制造“方向修一次乱一次”的循环；LR/LF/RR/RF 显式命名就是为了解除口头解释依赖 | `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`; session `[0302]`, `[0303]`, `[0358]` |
| 5 | “同步”不是一句调参口号，它曾经逼出了 `2000-raw` 与物理改线的真实边界 | 用户反复要求四轮同 raw、同起步、同节奏；最终必须承认代码符号、H 桥有效电平和物理接线之间有硬边界 | session `[0339]`-`[0365]`; checkpoints `f826b3d`, `167c3f8`, `39c481f` |
| 6 | `39c481f` 这种被用户指定为绝对基线的点，不能继续当普通开发点揉搓 | 下位机实车调试里，checkpoint 是可回退证据，不是“看起来差不多”的 Git 位置 | session `[0356]`, `[0362]`, `[0363]`, `[0364]` |
| 7 | 机械臂必须从第一天就拆成官方冻结基线和自研控制入口 | 这是从 RF1 入口混乱史里提炼出来的结构规则；否则新机械臂线会重演 work2/work3 的历史 | session `[0410]`-`[0412]`; `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md` |

## Final Shape

| Area | Current Formal Path | Status | Rule |
|---|---|---|---|
| RF1 底盘固件 | `firmware/openrf1_motion_controller/` | 正式主线 | 维护、注释、参数、小修都从这里开始 |
| 机械臂官方基线 | `firmware/mechanical_arm_official_baseline/` | 冻结对照 | 可以读、可以烧录验证，不作为自研改动入口 |
| 机械臂自研入口 | `firmware/mechanical_arm_controller/` | 新开发占位 | 后续串口、舵机、动作组、闭环控制都应从这里起步 |
| 历史工作副本 | `_local/`, `jixiebi/`, vendor资料包 | 历史证据 | 只能考古或对照，不能重新指定为正式入口 |

## Hard-Won Lessons

### 1. 先相信“旧工程曾经能转”，会拖慢真值重建

最早 OpenRF1 阶段，直觉上很容易继续从 `_work_2` 的成功片段找答案。但 session `[0228]` 里用户明确打断了这条路：当前板子的方向、PWM、编码器和四路通道必须用当前板实测。这个决定很痛，但它让 `C-3.0.5` 成为后面所有闭环、轮位语义、六方向测试的底座。

以后机械臂也一样。官方例程能跑，只证明官方例程能跑；它不自动证明我们后续自研协议、引脚复用、动作组抽象和整车调度都是对的。

### 2. 遇到 CN1/CN3 没反馈时，差点把主线改成软件绕行

CN1/CN3 编码器危机里，项目确实走过 tracking-port soft-encoder 分支。它有价值，因为它给了止损路径和对照证据；但它不能被误写成最终方案。最终收敛来自硬件证伪：新电机、旧电机、12V、7.4V、线簇替换、白线和彩虹线对照。

这条教训对机械臂尤其重要。舵机、总线、供电、电平、接插件、动作组存储都可能产生“像软件 bug 的硬件问题”。后续第一反应不能只是改代码。

### 3. “四轮同步”曾经被误简化成“所有通道发同一个 raw”

用户对同步的要求是对的，因为车要能走，四轮必须同节奏。但这段历史也证明：同步目标必须建立在分层真值上。H 桥方向、PWM 有效电平、编码器符号、`W` 命令语义、物理改线不是同一个层。`2000-raw` 争议之所以反复，是因为某些轮的物理方向和代码语义长期不一致，导致“前进”在不同通道上不是同一个底层动作。

这不是要为复杂代码辩护，而是要提醒未来工程师：要追统一，先确认统一的是哪一层。机械臂里也会出现类似问题，例如“舵机角度增加”到底是物理顺时针、逻辑正向、动作组正方向，还是上位机坐标正方向。

### 4. 没有 build+flash+serial 闭环，板上现象不能归因

session `[0365]` 的价值很高：一轮严重怀疑后发现只是忘了重新编译烧录。这个事实必须写进长期记忆，因为嵌入式项目最容易把“板上跑旧固件”误判为“刚改的代码有 bug”。

未来 RF1 或机械臂调试都必须先回答三件事：当前构建产物是哪一个？烧进板子的是否就是它？串口或行为有没有证明新固件已启动？

### 5. checkpoint 不是流程装饰，是硬件项目的救命绳

`f826b3d`、`167c3f8`、`39c481f` 不是普通历史点。它们是在实车联调中被用户用作阶段性保险的位置。尤其 `39c481f` 被明确叫做绝对基线，后续就不能在它上面继续模糊修改再声称“已经回去了”。

机械臂新阶段要继承这个习惯：官方基线一个 checkpoint，第一次串口回显一个 checkpoint，第一次单舵机动作一个 checkpoint，第一次动作组闭环一个 checkpoint。每个点都要能说明烧录对象、现象、回退方式。

### 6. 仓库治理是下位机可靠性的一部分

README、快速上手、`.gitignore`、正式目录、脚本化编译烧录，看起来像外围工作，但在这个项目里它们直接决定能不能复现实车状态。`C-3.6.0` 的意义不是“把文件摆好看”，而是结束 work2 烧 work3、`_local` 当主线、Keil 工程和仓库目录互相打架的状态。

### 7. 机械臂不是 RF1 的附属小改动

机械臂的正确起点不是把官方代码揉进 RF1，也不是继续在旧 `jixiebi/` 里随手试。`C-3.7.0` 已经定义了两条线：官方基线冻结、自研控制独立起步。后续所有机械臂任务都应先说明自己在哪条线上。

## Rules For Future Codex

1. 当前任务属于 RF1 底盘、机械臂官方基线、机械臂自研入口，还是只是历史资料考古。
2. 当前板上固件是否已通过 build+flash+serial 或 ST-Link 只读方式确认。
3. 当前现象属于 raw 驱动层、编码器层、车体语义层、物理接线层，还是上位机命令层。
4. 是否存在用户指定的 checkpoint 或阶段基线，尤其不要污染 `39c481f` 这种历史保险点。
5. 新机械臂任务是否先冻结官方行为，再开独立最小 smoke test。

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| RF1 正式固件入口必须唯一化到 `firmware/openrf1_motion_controller/` | project-only | `03_decisions.md`, `05_known_issues.md` | written | `C-3.6.0_openrf1_firmware_normalization.md`; session `[0397]` |
| 当前板子的 raw / 编码器 / 语义真值必须在当前板上重建，不能直接继承旧工程成功片段 | project-only, reusable later | `05_known_issues.md`, `07_development_history.md` | written | `C-3.0.5_openrf1_truth_table.md`; session `[0228]` |
| 原生 TIM 编码器危机需要靠硬件证伪而不是直接改软件架构 | project plus cross-project pattern | `05_known_issues.md`; `03_CrossProject/patterns.md` | written | `C-3.1.4B_openrf1_timer_final_convergence.md`; session `[0283]`-`[0288]` |
| 历史 STM32 build log 的工具链路径不能默认等于当前机器可用路径 | cross-project tooling | `03_CrossProject/tooling.md` | written | `mechanical_arm_official_baseline/Output/template.build_log.htm`; 2026-06-07 tooling note |
| 导入 STM32 baseline 前先用 ST-Link 做只读身份确认 | cross-project tooling | `03_CrossProject/tooling.md` | written | ST-Link identity check recorded in tooling memory |
| 板内运行固件不能默认等于仓库当前工件 | cross-project tooling | `03_CrossProject/tooling.md` | written | 2026-06-07 board-vs-repo audit note; session `[0365]` |
| checkpoint 在实车嵌入式项目里是硬件证据，不只是 Git 习惯 | cross-project pattern | `03_CrossProject/patterns.md` | written | checkpoints `f826b3d`, `167c3f8`, `39c481f`; session `[0356]`-`[0364]` |
| 机械臂必须采用“官方冻结基线 + 独立开发目录”的双路径 | project-only | `03_decisions.md`, `06_todo_next.md` | written | `C-3.7.0_mechanical_arm_baseline_freeze.md`; session `[0410]`-`[0412]` |

## Remaining Risks

1. 本条目证明的是“开发历史、决策依据和当前仓库正式入口”，不能替代下一次实车上电验证。
2. 机械臂官方基线已冻结，不等于自研机械臂控制已完成。
3. RF1 当前参数和方向语义来自当时实车状态；更换轮子、载荷、供电或机械结构后，仍需重新做低风险实测。
4. 2026-05 导航低速平滑与 anti-windup 讨论在会话里存在，但若后续要把它单独作为控制算法史，需要再结合对应正式分支、合入提交和实车验收补一轮专门条目。
