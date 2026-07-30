# 2026 电赛 G 题周期信号测量分析装置

## Metadata

- Project Name: 2026 电赛 G 题周期信号测量分析装置
- Project Slug: `stm32g474-tjc-display`
- Primary Path: `F:\Project\stm32G474VETx\TI`
- Formal Workspace: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Display Project: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\tjc_display_demo`
- Signal Processing Reference: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\teammate_adc_reference`
- Latest Teammate Snapshot: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\teammate_adc_newest`
- Repository: `https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer`
- OS/Environment: Windows, STM32CubeIDE 2.1.0, Keil MDK
- Main Languages/Frameworks: C, STM32 HAL, 淘晶驰 X2 HMI, CMSIS
- Last Updated: 2026-07-30
- Maintainer/Source: yusu project work

## Quick Links

- [[03_decisions]]
- [[04_progress]]
- [[05_known_issues]]
- [[06_todo_next]]
- [[10_project_summary]]
- [[../../03_CrossProject/stm32-stlink-runtime-debugging]]

## Maturity Level

- [ ] New/light project snapshot
- [x] Mature project full-cycle ingestion

## Scope

- `tjc_display_demo`与队友信号处理工程是同一赛题下由不同成员维护的两个独立工程。
- `teammate_adc_reference`保留旧参考快照；`teammate_adc_newest`保存2026-07-30收到的最新队友快照。两者均不得直接覆盖已经验证的显示基线。
- `test/`保留原始工程与交接包，仅作为本地历史目录，由TI根仓库忽略。
- 赛题、赛区问答、器件资料和阶段报告仍保存在`F:\AcademicHub\000资料相关\电赛\2026TI杯`，不纳入代码仓库。
- 当前可烧录融合基线为`projects/g474_full_integration_test`；V1.4已完成Keil构建、ST-Link运行态检查和HMI模拟器稳定回归。
