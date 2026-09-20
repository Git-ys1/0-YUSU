# Project Brief

## 项目身份

| 项目 | 内容 |
|---|---|
| 名称 | 2026 电赛 G 题周期信号测量分析装置 |
| 参赛编号 | `B26244` |
| 学校 | 北京交通大学 |
| 最终结果 | 北京市大学生电子设计竞赛二等奖（省级） |
| MCU | STM32G474VET6 |
| 显示 | 淘晶驰X2 7英寸串口屏，现场为不可触摸屏 |
| 代码仓库 | `F:\Project\stm32G474VETx\TI` |
| 项目工作区 | `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer` |
| 最终比赛源码 | `G_Periodic_Signal_Analyzer\teammate\24` |
| 比赛资料目录 | `F:\AcademicHub\000资料相关\电赛\2026TI杯` |
| 正式报告 | `G_Periodic_Signal_Analyzer\docs\05_report\final` |
| Git远端 | `https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer` |

## 目标与边界

装置对周期信号完成双ADC采集、频率和幅相分析、理论波形复原、峰峰值/有效值
计算，并在淘晶驰屏幕显示时域、频谱和测量文本。显示模块通过桥接层消费算法
结果，不拥有ADC采集和频谱识别算法。

最终工程采用ADC1/PA0与ADC2/PA1各2048点，由TIM3双边沿触发，交错形成
`VO[4096]`。频域链使用4096点FFT和Goertzel相位，`getup()`生成一个周期的
4096点理论波形；桥接层复制为512个显示点，屏幕支持1T/3T和多种触发锚点。

## 赛后源代码真源

2026-09-20全树核验确认：

- 外部资料目录`2026TI杯\24`与仓库`teammate\24`均为346个文件、56,045,062字节；
- 相对路径、文件长度和逐文件SHA-256差异为0；
- `teammate\current`与最终`24`有16个文件差异，是较早队友底座；
- `firmware/`是赛前重构开发工作区，保留历史，但不是最终比赛包的逐字副本。

因此，源码统一从项目仓库查看，资料目录以赛题、名单、HMI资料和原始备份为主。
完整哈希见仓库`docs/00_overview/FINAL_COMPETITION_SOURCE.md`。

## 当前Git状态

- 主分支：`main`。
- 本地HEAD：`b37d124`，比`origin/main`领先1个提交。
- 远端最新正式标签：`v2.6.0 / 4894940`。
- 赛末V2.8.1、报告、交接包和目录整理仍有未提交改动。
- Git标签代表已发布开发阶段，不等同于现场最终`24`工程。

## 已完成能力

- 双ADC交错采样与4096点分析链；
- 基波加至多两种谐波的频率、幅值和相位分析；
- 解析波形复原、Upp和Vr发布；
- 无信号、单频、双频和三频分类；
- 512×256时域、256×256频谱、1T/3T与动态坐标；
- HMI初始化握手、刷新/清除/停止/测试与实体KEY1控制；
- 最终Word/PDF报告及软件流程图、MCU—显示屏时序图；
- 多轮Keil构建、SWD烧录和实屏回归证据。

## 仍需谨慎解释的内容

- 最终比赛工程已冻结，但Git工作树尚未完成赛后清理与正式发布。
- 前端复频响、双ADC增益/偏置/时间偏差并没有形成完整可复现实验数据集。
- 部分赛前文档写着“唯一主线firmware”或“待烧录”，必须服从赛后冻结说明。
- 外部资料目录保留`24`是为了证据完整性，不应继续在其中开发。

## 权威入口

1. 仓库`README.md`；
2. `docs/00_overview/FINAL_COMPETITION_SOURCE.md`；
3. `teammate/24/Core/Src/main.c`；
4. `docs/05_report/final/README.md`；
5. 本知识库`07_development_history.md`与`10_project_summary.md`。
