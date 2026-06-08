# Session Evidence

## Current Engineer Session File

- Session ID: `019ce0df-b2bc-76d0-9e0e-fd78073132a1`
- JSONL: `C:\Users\yusu\.codex\sessions\2026\03\12\rollout-2026-03-12T15-08-02-019ce0df-b2bc-76d0-9e0e-fd78073132a1.jsonl`
- Verified cwd in first line: `f:\Project\CleanScout_rover`
- Source: `vscode`
- File size observed during retrospective: about `79 MB`
- Raw JSONL lines observed during retrospective: `28289`
- Extracted user-message count during retrospective: `416`

这份会话覆盖了当前工程师在本项目里从最早 Tyler/UNO 导入，一直到 2026-06-07 机械臂官方基线冻结
与 YUSU 入库要求的完整连续开发轨迹。本条目没有使用其他工程师的 JSONL。

## Why This Session Matters More Than Git Alone

Git 历史能告诉我们：

- 什么时候出现了某个提交
- 哪个文档进入了仓库
- 哪些目录后来被正式化

但 Git 历史看不到很多决定下位机真相的细节，例如：

- 用户什么时候亲手挡住了 `CN4`，导致一次误判随后被撤回
- 用户什么时候把 `CN1`、`CN3` 物理反接线
- 用户什么时候换成 `12V` 电池，又换回 `7.4V`
- 用户什么时候把可疑白线换成彩虹线
- 用户什么时候强行指定 `39c481f` 为绝对保险基线
- 用户什么时候直接指出“原来只是忘了重新编译烧录”

对硬件联调项目来说，这些信息决定了哪条文档是“实测收敛结果”，哪条只是“当时的软件怀疑”。

## How Session References Work In This KB

本条目使用 `session [NNNN]` 形式引用会话中的用户消息索引，例如：

- `session [0228]`
- `session [0358]`

含义是：

- 从当前工程师这份 JSONL 中，按用户消息顺序抽取后的第 `NNNN` 条用户消息
- 每条索引都保留时间戳，便于回到原始 JSONL 检查上下文

这些索引不是 Git commit，也不是文档编号，而是这轮 retrospective 为了做阶段回溯额外建立的会话锚点。

## Retrospective Extraction Method Used This Round

本轮不是只读最近上下文，而是做了显式回溯：

1. 核对 JSONL 第一行 `session_meta`，确认 `cwd` 就是 `f:\Project\CleanScout_rover`。
2. 抽取全部用户消息，形成时序列表。
3. 针对以下关键词做重点筛查：
   - `C-3.0`, `C-3.1`, `C-3.3`, `C-3.6`, `C-3.7`
   - `CN1`, `CN3`, `2000-raw`, `同步`
   - `checkpoint`, `回退`, `39c481f`, `f826b3d`, `167c3f8`
   - `机械臂`, `YUSU`, `入库`
4. 再用当前仓库 Git 历史和现存 `docs/SOFTWARE`, `docs/VERIFY`, `README`, `firmware/README.md` 做交叉核对。

这意味着当前 KB 里的阶段叙述不是“只凭印象概括”，而是会话原文、Git 历史和仓库文件三者对齐后的结果。

## Phase Evidence Table

| Phase | Representative Session Evidence | What It Proves | Cross-Checked Repo Evidence |
|---|---|---|---|
| 仓库立项与纪律冻结 | `[0002]` | 项目一开始就把 `C/J` 双线、checkpoint、回退、最小交付要求写进总纲 | `docs/before_all.md`, early commits `930c224`, `09b1e0d` |
| OpenRF1 bringup 前奏 | `[0221]`-`[0227]` | 用户要的不是空谈方案，而是 ST-Link、TTL、根目录命令、串口和电机能转起来的最小闭环 | commits `2498606`, `70b8602` |
| 四路驱动真值重写 | `[0228]`-`[0233]` | 用户明确否定参考 `_work_2` 成功片段，要求真值表先行；8 小时后四路双向可控 | `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`, commits `3090997`, `b108d43`, `4dc2700` |
| 编码器危机与“先不改脚” | `[0249]`, `[0250]`, `[0252]` | 说明项目曾认真怀疑 TIM/remap/JTAG，但随后被用户拉回“先做板级、电气、模式矩阵排查” | `C-3.0.8*`, `C-3.1.0*` 文档与对应 commits |
| 好电机 / 白线 / 彩虹线最终证伪 | `[0283]`-`[0288]` | 真实收敛来自换电机、换电池、换线簇，不是单靠代码推理 | `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md` |
| 语义纠偏与六方向闭环 | `[0302]`, `[0303]`, `[0307]` | 用户明确指出 `[CN1,CN2]` 和 `[CN3,CN4]` 是左右分组，不是前后分组；增益不能制造左右转 | `docs/VERIFY/C-3.1.4C*`, `C-3.3.1A*`, commits `0a49938`, `e664d99` |
| 同步战争、`2000-raw` 争议与多次回退 | `[0339]`-`[0365]` | 这是 RF1 最漫长的“同步 vs 真实真值”阶段，出现物理改线、多个 checkpoint 和 `39c481f` 绝对基线 | checkpoints `f826b3d`, `167c3f8`, `39c481f`, commit `38991e5` |
| 仓库正规化与机械臂转场 | `[0397]`-`[0412]` | 用户先要求把 `_local` 正式收口，再要求冻结机械臂官方基线并建立独立开发入口 | `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`, `C-3.7.0_mechanical_arm_baseline_freeze.md`, commit `19b33ad` |
| 本轮对 KB 的纠偏要求 | `[0413]`, `[0414]`, `[0415]` | 用户明确指出：YUSU 不得私自提交；当前重点不是代码，而是用自己的 JSONL 把开发历程写厚、写实、写有用 | 本条目与本项目 KB 全部相关重写 |

## User Corrections That Changed The Rules

这份 JSONL 最大的价值之一，是能看到用户在哪些地方直接纠正了错误前提，并把这些纠正变成长期规则。

| Session Evidence | User Correction | Lasting Rule |
|---|---|---|
| `[0228]` | 不能继续拿 `_work_2` 的“成功语义”修 `_work_3` | 当前板子的真值必须用当前板子的实测重建 |
| `[0252]` | CN1/CN3 这轮不该先改脚，先查板级关联、电气模式、编码器模式矩阵 | 先做硬件证伪，后做架构回退 |
| `[0302]`, `[0303]` | `[CN1,CN2]` / `[CN3,CN4]` 不是前后轮分组，而是左右侧分组 | 后续所有语义、参数、注释都必须显式写 LR/LF/RR/RF |
| `[0358]` | 之前关于 `SET/RESET` 的解释不成立，真正问题是 `CN1/CN3` 长期以 `-1` 语义运行，导致总要走 `2000-raw` | 不要脱离当前物理改线和方向表状态去复述旧推断 |
| `[0365]` | 一轮严重怀疑后发现只是忘记编译/烧录 | 板上行为必须靠 build+flash+串口确认，不靠记忆 |
| `[0397]` | `_local` 命名和 work2/work3 烧录方式太不规范，必须正式收口 | 正式固件入口必须仓库内唯一化 |
| `[0412]` | 机械臂官方例程要放进正式位置，后续自研要独立目录 | 官方基线与自研入口从第一天就分开 |
| `[0415]` | 之前 KB 写得太水，必须回溯整份 JSONL 和所有上下文 | 成熟项目入库必须以自身 JSONL 为主要证据，不可只写当前状态快照 |

## Facts Visible Only In The Session, Not In Git Messages

下列事实若只看 Git 历史，基本会丢失，但它们对理解项目成熟过程至关重要：

1. RF1 最初驱动双向可控是“搞了 8 个小时”才打通，且用户明确要求先冻结再继续修 `CN3/CN4`。
2. `C-3.1.3` 软编码器不是一个优雅方案，而是 CN1/CN3 没数时的止损分支。
3. `CN1/CN3` 的根因收敛依赖新电机、旧电机、`12V/7.4V`、白线/彩虹线的组合对照，不是单次代码修正。
4. 用户对“同步”的要求不是抽象偏好，而是亲自改线后的明确机械目标。
5. `39c481f` 不是普通 checkpoint，而是被口头指定为“绝对基线”的保险绳。
6. 用户后期已经把“README/目录/忽略规则/主线发布纪律”视为和控制参数同等重要的工作。
7. 从 RF1 转向机械臂不是因为 RF1 完全没问题了，而是因为用户认为“下位机的进度终于赶上来了”，可以开始独立冻结机械臂官方基线。

## Repo / Git Evidence Used Alongside The Session

### Git History

- `git log --reverse --date=short --pretty=format:"%ad %h %s" -- firmware/openrf1_motion_controller _local/openrf1_keil_work_3 docs/SOFTWARE docs/VERIFY README.md firmware/README.md`
- `git log --oneline -n 5 --decorate`
- current main HEAD observed during this retrospective: `19b33ad37fda65b4a3a379ed22556a0a7c803af5`

### Current-State Source Evidence

- `docs/VERIFY/C-3.0.5_openrf1_truth_table.md`
- `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`
- `docs/VERIFY/C-3.1.4C_openrf1_rear_wheel_direction_hotfix.md`
- `docs/VERIFY/C-3.1.4D_openrf1_closed_loop_smoothing.md`
- `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`
- `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
- `firmware/openrf1_motion_controller/README.md`
- `firmware/mechanical_arm_official_baseline/README.md`
- `firmware/README.md`
- `README.md`

## What This Session Proves About The Current Project Shape

1. 当前 RF1 正式主线的成熟，不是一次性设计产物，而是多轮真值表、软硬件证伪、物理改线、回退与文档冻结共同作用的结果。
2. 当前 `firmware/openrf1_motion_controller/` 之所以必须唯一化，不只是出于“好看”，而是因为历史上确实长期存在 work2/work3/`_local` 多入口导致的事实混乱。
3. 机械臂必须走“官方冻结基线 + 独立开发目录”，不是形式主义，而是从 RF1 入口混乱史中提炼出的直接教训。
4. 任何未来下位机工程师若只看当前代码、不看开发史与用户纠正，很容易把已经付过学费的坑再次踩一遍。

## Important Notes About Evidence Limits

1. 会话能证明“当时看到了什么、试了什么、被用户如何纠正”，但不能替代当前代码、当前板子和当前工具链的真实状态。
2. 机械臂当前被本条目记录为“官方基线已冻结并可烧录验证”，不是“自研机械臂控制已跑通”。
3. 2026-05 期间关于导航低速平滑、anti-windup、下位机连续性改造的讨论出现在本会话中，但当前主仓正式形态仍以现存 `firmware/openrf1_motion_controller/` 与已合入文档为准；若后续工程师要专门整理那条线，应再结合对应分支与提交补写。
4. 本轮 KB 重写已经使用自己的完整 JSONL 做阶段回溯，但未来若有新的长期开发会话，后续工程师仍应按“单工程师单 JSONL”原则继续补充，而不是覆盖本条目。
