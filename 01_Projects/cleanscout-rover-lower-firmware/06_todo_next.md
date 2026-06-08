# Todo Next

## Purpose

这份待办不是普通功能清单。它的作用是把 RF1 底盘阶段付过学费的开发纪律，转移到机械臂新阶段。后续每一项都应能回答：正式入口在哪、烧录了什么、板上证明了什么、如果失败怎么回退。

## Immediate Next Steps

### 1. 机械臂官方基线再做一次只读到运行的证据闭环

Status: pending

要做：

1. 用 ST-Link 只读确认芯片身份、容量、连接方式。
2. 记录当前 `firmware/mechanical_arm_official_baseline/` 内可烧录 `hex` 的路径、大小、时间。
3. 烧录官方基线。
4. 记录串口、舵机、电源、动作组是否有可观察现象。
5. 如果只能烧录、不能本机重编译，要明确写成“flash verified, local rebuild not yet verified”。

为什么重要：

RF1 阶段多次证明“仓库里有代码”和“板上正在跑这份代码”不是一回事。机械臂第一步必须先建立官方基线的板上事实。

Evidence to update:

- `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
- 本 YUSU 条目的 `04_progress.md`
- 必要时新增 `docs/VERIFY/C-3.7.x_mechanical_arm_official_flash.md`

### 2. 发现并固定机械臂本机 Keil 构建路径

Status: pending

要做：

1. 查当前机器实际可用的 `UV4.exe` / `UV5.exe`。
2. 不沿用历史 build log 中的旧路径作为事实。
3. 为机械臂官方基线或自研入口补一个最小构建脚本。
4. 构建成功后记录 `0 Error(s)`、输出 hex 路径和时间。

为什么重要：

RF1 已经收口到脚本化 build/flash。机械臂如果继续靠手工 Keil 或旧日志，很快会重演 work2/work3 混乱。

Evidence to update:

- `02_runbook.md`
- `03_CrossProject/tooling.md` 里已有 “historical STM32 build log” 经验，若路径确认后补一条项目证据即可。

### 3. 在 `mechanical_arm_controller/` 建最小自研壳

Status: pending

要做：

1. 不直接修改 `mechanical_arm_official_baseline/`。
2. 在 `firmware/mechanical_arm_controller/` 建 README、工程入口和最小启动说明。
3. 第一版只实现串口回显或 heartbeat。
4. 第二版再接单舵机固定动作。
5. 第三版再接动作组触发。

为什么重要：

RF1 的 `_local` 史说明：没有正式入口，后面每次调试都会先争论哪份代码有效。机械臂要从第一天避免这个问题。

Evidence to update:

- `docs/SOFTWARE/C-3.7.x_mechanical_arm_controller_bringup.md`
- `firmware/mechanical_arm_controller/README.md`
- 本条目 `04_progress.md`

### 4. 为机械臂定义第一版安全协议，而不是直接谈运动学

Status: pending

要做：

1. 定义最小串口命令：查询版本、停机、单舵机动作、动作组触发。
2. 每个命令都必须有回显和错误码。
3. 必须有安全停止或输出失效策略。
4. 所有协议字段先写文档，再写代码。

为什么重要：

RF1 的 `W/M/E/D/STOP` 能保留下来，是因为协议边界最终冻结了。机械臂也要先有可测协议边界，再谈更高层控制。

Evidence to update:

- `02_runbook.md`
- `docs/PROTOCOL/` 或对应机械臂协议文档

### 5. 继承 RF1 的 checkpoint 纪律

Status: pending

机械臂至少需要这些 checkpoint：

| Checkpoint | Minimum Evidence |
|---|---|
| 官方基线可烧录 | ST-Link 身份、hex 路径、烧录成功、板上现象 |
| 本机可重编译 | Keil 路径、构建命令、0 errors、hex 输出 |
| 自研 heartbeat | 自研目录、串口启动标识、源码提交 |
| 单舵机可控 | 命令、舵机编号、角度/动作、停止方式 |
| 动作组可触发 | 动作组编号、触发命令、回显、失败处理 |

为什么重要：

`f826b3d`、`167c3f8`、`39c481f` 这些 RF1 checkpoint 证明：硬件项目的 checkpoint 是排障工具，不是 Git 流程装饰。

## Deferred / Pending

1. 专门整理 2026-05 导航低速平滑、anti-windup、PWM slew、目标轮速斜坡这条控制算法线。当前 `09_session_evidence.md` 已提示它存在，但还没有单独按提交和实车结果写成完整子史。
2. 等树莓派、前后端、上位机工程师各自完成入库后，再补一个总项目级 `cleanscout-rover` 汇总条目。当前本条目只覆盖下位机。
3. 如果后续机械臂真的开始闭环控制，再新增 `known_issues`：舵机供电、电流、动作组阻塞、串口丢包、限位、急停。
4. 若后续 RF1 或机械臂再出现新的硬件排障模式，再评估是否继续补充 `03_CrossProject/patterns.md`。

## Routed Cross-Project Lessons This Round

1. `Hardware falsification before software architecture fallback` 已写入 `03_CrossProject/patterns.md`。
2. `Checkpoints as hardware evidence, not just Git hygiene` 已写入 `03_CrossProject/patterns.md`。
3. CleanScout Rover 下位机已登记到 `06_Maps/project-map.md` 与 `06_Maps/topic-map.md`。

## Do Not Do Next

1. 不要把机械臂新改动直接塞进 `mechanical_arm_official_baseline/`。
2. 不要再从 `_local/` 里挑一份旧工程当正式入口。
3. 不要为了“快点动”跳过 ST-Link 身份、hex 来源和串口回显。
4. 不要把历史 build log 当成本机编译成功证据。
5. 不要在 RF1 已经正规化后继续把 work2/work3 烧录链路写成推荐路径。
6. 不要先设计复杂运动学，再回头补最小串口和单舵机 smoke test。

## Completion Criteria For This KB Ingestion

本次下位机成熟项目入库完成前，应满足：

1. `07_development_history.md` 覆盖从 UNO/Tyler、OpenRF1、真值表、编码器危机、同步争议、正式工程收口到机械臂冻结的主线。
2. `05_known_issues.md` 至少记录 8 个以上真实复发风险，并且包含症状、根因、规则和证据。
3. `03_decisions.md` 记录 RF1 正式入口、机械臂双目录、原生 TIM 主线、历史副本降级等关键决策。
4. `08_onboarding_from_zero.md` 能让新工程师知道第一天读什么、不要碰什么、最小闭环是什么。
5. `09_session_evidence.md` 指向当前工程师自己的 JSONL，并解释 session anchor 的含义。
6. `10_project_summary.md` 提炼最重要 3-7 件事，并包含 Memory Routing Audit。
7. `mature-project-retro-audit.ps1` 运行通过，或未通过项清楚写在本文件。

2026-06-08 管理员验收：已运行 `tools/mature-project-retro-audit.ps1 -Slug cleanscout-rover-lower-firmware -ProjectPath F:\Project\CleanScout_rover -SessionFile C:\Users\yusu\.codex\sessions\2026\03\12\rollout-2026-03-12T15-08-02-019ce0df-b2bc-76d0-9e0e-fd78073132a1.jsonl`，结果 PASS，0 warnings。
