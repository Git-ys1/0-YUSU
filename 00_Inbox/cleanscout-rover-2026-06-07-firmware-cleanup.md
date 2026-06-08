# CleanScout Rover 固件清理待入库

- 日期：2026-06-07
- 项目：`F:\Project\CleanScout_rover`
- 状态：已并入 `01_Projects/cleanscout-rover-lower-firmware/`，保留为原始入库便签

## 本轮事实

- OpenRF1 正式固件入口为 `firmware/openrf1_motion_controller/`。
- Keil 工程文件 `OpenRF1_Motion.uvprojx` 在清理前被 IDE 自动改写；本轮已恢复，最终相对清理前基线零差异。
- 删除了不参与运行计算的重复目标数组、未调用 PID/PWM 兼容宏、未调用函数和空诊断字段。
- 实际控制参数与行为保持：增量 PI、`2.5m/s²` 目标斜坡、速度滤波、方向表及 `W/M/E/D/STOP` 语义未变。
- 严格 Keil 构建结果：`0 Error(s), 0 Warning(s)`。
- 提交：`993bc12`；合并到 `main`：`2f37c82`。

## 板内固件只读核验

- 通过 STLink 读取 STM32F103RC 的完整 256KB Flash，全程未擦除、未写入，读取后执行软件复位。
- 板内有效数据延伸到约 `0x080050E3`。
- 当前 `C-3.6.1` HEX 数据范围到 `0x080043F3`，在其 17396 个有效字节中有 16789 字节与板内不同。
- 清理前 `C-3.6.0` 基线也不匹配；差异从中断向量表开始，不能解释为死代码清理导致。
- 本机现存旧 HEX、`C-3.5.0C` 重建产物和安全 stash 重建产物均未与板内镜像精确匹配。
- 结论：板内仍是未纳入当前正式固件历史的旧构建或本地临时构建。后续开发前应明确选择“保留板内旧版”或“烧录当前正式版”，不能默认两者相同。

## 后续规则候选

1. 固件工程整理时，先区分“参与运行的参数”和“历史兼容定义”，只删除有引用证据证明未生效的项。
2. Keil GUI 可能自动改写 `.uvprojx` 的下载器字段和 XML 排版；提交前必须对工程文件单独做零差异检查。
3. 机械臂原始资料等本地参考文件应使用精确目录规则忽略，不应删除本地证据或用宽泛规则误伤正式文档。

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| OpenRF1 固件清理事实 | project-only | `01_Projects/cleanscout-rover-lower-firmware/` | routed | 成熟项目条目已建立，详见 `03_decisions.md`, `04_progress.md`, `07_development_history.md` |
| Keil 工程文件自动改写检查 | cross-project tooling | `03_CrossProject/tooling.md` | written | 本轮 `.uvprojx` 实际差异 |
| 只删除已证明未生效的控制兼容项 | cross-project pattern | `03_CrossProject/patterns.md` | deferred | 项目条目已写清 RF1 清理边界；是否推广为独立 pattern 待更多项目复现 |
| 板内固件不可默认等同仓库 HEX | cross-project tooling | `03_CrossProject/tooling.md` | written | 2026-06-07 STLink 完整 Flash 只读比对 |
