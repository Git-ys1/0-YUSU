# 2026 电赛 G 题周期信号测量分析装置

## Metadata

- Project Name: 2026 电赛 G 题周期信号测量分析装置
- Project Slug: `stm32g474-tjc-display`
- Primary Path: `F:\Project\stm32G474VETx\TI`
- Formal Workspace: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Archived Display Demo: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\archive\firmware\tjc_display_demo`
- Signal Processing Reference: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\teammate\archive\adc_reference`
- Final Competition Source: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\teammate\24`
- Historical Teammate Baseline: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\teammate\current`
- Pre-final Development Workspace: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\firmware`
- Repository: `https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer`
- OS/Environment: Windows, STM32CubeIDE 2.1.0, Keil MDK
- Main Languages/Frameworks: C, STM32 HAL, 淘晶驰 X2 HMI, CMSIS
- Last Updated: 2026-09-20
- Maintainer/Source: yusu project work

## Quick Links

- [[00_project_brief]]
- [[01_architecture]]
- [[02_runbook]]
- [[03_decisions]]
- [[04_progress]]
- [[05_known_issues]]
- [[06_todo_next]]
- [[07_development_history]]
- [[08_onboarding_from_zero]]
- [[09_session_evidence]]
- [[10_project_summary]]
- [[11_current_handoff_2026-07-31]]
- [[12_final_result_and_code_locations_2026-09-20]]
- [[adr/2026-07-30-teammate-base-display-bridge]]
- [[adr/2026-08-01-phase-model-only]]
- [[adr/2026-09-20-final-source-and-document-separation]]
- [[../../03_CrossProject/stm32-stlink-runtime-debugging]]

## Maturity Level

- [ ] New/light project snapshot
- [x] Mature project full-cycle ingestion

## 2026-09-20 赛后结论

- 比赛已经结束，参赛编号`B26244`、G题、北京交通大学，获**北京市二等奖（省级）**；官方名单证据见获奖名单`Sheet1`第142行。
- 最终现场代码真源统一为仓库`teammate\24`；外部`F:\AcademicHub\000资料相关\电赛\2026TI杯\24`只保留原始备份。
- `firmware/`仍是整理后的后续开发主线，但不是最终`24`包的逐字副本；下方V2.8描述保留为赛前开发史，不再代表最终比赛代码定位。
- 从比赛资料目录进入时，先读`F:\AcademicHub\000资料相关\电赛\2026TI杯\README.md`。
- 完整版本关系、哈希和恢复方法见[[12_final_result_and_code_locations_2026-09-20]]。

## 赛前开发史（保留证据）

- 2026-08-01当前未发布工作区为V2.8：`teammate/last`已原样提升为
  `teammate/current`取证底座，唯一可修改、可构建主线仍是`firmware/`。
- V2.8只使用队友幅相解析：`getup()`理论值同时计算Upp并提供1T/3T时域图；
  有效值使用队友第二次FFT得到的`Vr`，桥接保存512点并兼容4096/8192点输入。
- 旧普通/Huber折叠、Mpp、`sw_model`、`sw_huber`和0x08/0x09已从源码删除。
- 当前交接包为`deliverables/V2.8更新包.zip`，含桥接/显示四个生产配置覆盖文件，
  并按`teammate/last/main.c`写明`getup()`与主循环发布段两处完整替换代码；不覆盖
  队友持续更新的主程序。当前V2.8未提交、未发布。
- 最新最小增量为`deliverables/V2.8.1无信号与单频增量包.zip`：只覆盖桥接两文件，
  主程序按说明增加0/1/2/3分类；本地零警告构建，尚未烧录或实物验收。
- 当前报告增量为`docs/05_report/显示部分V3.docx`、`docs/05_report/ADC部分V2.docx`
  和`deliverables/V2.8_周期信号时域图像复原方法数学说明.docx`。显示报告统一用
  N/M/P/K区分理论点、桥接点、屏幕像素和有效分量数；ADC报告先用L/B/N/Fs等
  通用符号推导，再在第3章映射`teammate/last`的双ADC 4096点实现。
- 当前竞赛主报告为`docs/05_report/B26244_3.docx`：在原8页版面内原位替换过时
  ADC和软件段落，融合双ADC 4096点、FFT邻域能量估幅、Goertzel相位及V2.8
  显示链路；硬件正文、4幅原图和测试表未改，9个公式均为可编辑Word公式。
- 当前软件总图为`docs/05_report/figures/01_软件总体流程图.vsdx`，按正式运行链路
  用9个黑白高层节点表示双ADC采集、数据复制交错、分析、复原和显示，不包含
  测试阶段功能、历史模式名称或框内函数名。

- `tjc_display_demo`与队友信号处理工程是同一赛题下由不同成员维护的两个独立工程。
- `teammate_adc_reference`保留旧参考快照；`teammate_adc_newest`保存2026-07-30收到的最新队友快照。两者均不得直接覆盖已经验证的显示基线。
- `test/`保留原始工程与交接包，仅作为本地历史目录，由TI根仓库忽略。
- 赛题、赛区问答、器件资料和阶段报告仍保存在`F:\AcademicHub\000资料相关\电赛\2026TI杯`，不纳入代码仓库。
- 当前可烧录融合基线为`firmware/`；发布基线是`v2.4.0 / 554cdcb`，包含
  512×256时域、256×256频谱、动态坐标、周期状态回写和独立模型`Mpp`。
- V2.4固件与HEX已发布，用户手工HMI源文件尚未归档，真实三方幅值证据仍待补齐。
- 新会话恢复必须先读仓库`docs/06_handoff/README.md`及本知识库
  `11_current_handoff_2026-07-31.md`，不得从V1.4/V1.8或旧任务书重新融合。
