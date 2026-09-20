# Onboarding From Zero

## First 30 Minutes

1. 先确认你在`F:\Project\stm32G474VETx\TI`，这是Git根目录。
2. 阅读项目仓库`G_Periodic_Signal_Analyzer/README.md`。
3. 阅读`docs/00_overview/FINAL_COMPETITION_SOURCE.md`，记住最终真源是`teammate/24`。
4. 阅读本知识库`00_project_brief.md`、`01_architecture.md`和`10_project_summary.md`。
5. 运行`git status --short --branch`，不要把当前脏工作树误认为已发布版本。
6. 只读查看`teammate/24/Core/Src/main.c`、`analyzer_bridge.c`和`display.c`。
7. 如果只是复盘，不运行构建、不烧录、不修改冻结目录。

## First Day

上午先沿数据链阅读：

- `main.c`双ADC/DMA；
- `fft()/Goertzel/getup()/Vpp_R()`；
- `AnalyzerBridge`；
- `Display_Task`；
- USART3/HMI。

下午再读历史：

- `07_development_history.md`了解九个阶段；
- `03_decisions.md`了解为什么废弃普通/Huber和双模式；
- `05_known_issues.md`了解栈、UART、HMI、采样和标定坑点；
- `docs/04_releases/`按标签追踪演进；
- `docs/05_report/final/`查看正式对外表述。

如果要继续研究，先新建Git分支和独立工作目录。不要直接修改`teammate/24`，也
不要把`firmware`或`teammate/current`覆盖到最终真源。

## Minimal Working Loop

最小可运行闭环不是“编译成功”，而是：

1. 复制冻结工程到临时目录。
2. Keil clean rebuild，要求0 error / 0 warning。
3. 核对新HEX时间、长度和SHA-256。
4. 明确连接的是允许测试的G474板。
5. CubeProgrammer写入、verify、reset。
6. 检查CPU、ADC、桥接序号和dashboard握手。
7. 用已知安全信号验证无信号与单频。
8. 再验证双频/三频、1T/3T和KEY1。
9. 保存输入条件、固件哈希和屏幕/示波器证据。

没有硬件授权或接线确认时，只做复制构建和静态审计，不自动烧录。

## Common Newcomer Traps

### 把`firmware/`当最终现场版本

它是赛前重构主线，`main.c`与最终`24`不同。复现实赛必须从`teammate/24`开始。

### 把最新Git标签当最终比赛包

远端最新标签是`v2.6.0`，但现场最终`24`形成得更晚。标签和最终包是两条证据线。

### 从`teammate/current`继续融合

`current`与`last`一致，但相对最终`24`有16处差异。它只用于理解队友原始底座。

### 看到屏幕无图就改显示算法

应先查CPU、DMA、VO、桥接序号、dashboard曲线ID和UART错误，再查绘图。

### 在中断里发送整帧

EXTI和UART ISR只置事件/收短帧；阻塞式HMI发送放主循环，否则容易超时或ORE。

### 把平滑当测量修正

显示滤波不会修正前端增益、偏置、抗混叠、采样率、双ADC失配或单位错误。

### 无信号时不发布结果

拒绝一帧会让屏幕保留旧正弦。无有效输入必须发布全零有效快照。

### 直接全量提交脏工作树

赛末有大量未提交报告、交接包和目录变化。必须分主题审计，不能`git add -A`。

## If Rebuilding From Scratch

1. 先冻结赛题输入范围、模拟前端和ADC安全边界。
2. 独立跑通双ADC DMA，测出真实采样率和通道时序。
3. 保存可复现的无信号、单频、双频、三频原始数组。
4. 在PC验证FFT、亚bin频率、Goertzel相位和双ADC校准。
5. 定义一个带单位的算法结果结构，不让显示访问FFT全局缓冲。
6. 先做无信号门控和模型残差，再做解析波形复原。
7. 用静态双缓冲或原子快照连接显示，避免半更新结果。
8. 单独跑通HMI初始化、真实曲线ID、FE/FD和定点文本。
9. 再把KEY1和触摸事件汇入同一业务命令入口。
10. 用固定数据集做PC—MCU一致性，再进行实物扫频和幅相标定。
11. 最后写报告，公式通式与固件参数分层，所有结论回链实测证据。

## 新任务选择入口

| 任务 | 第一份文件 |
|---|---|
| 复现最终工程 | `docs/00_overview/FINAL_COMPETITION_SOURCE.md` |
| 查构建烧录 | 本知识库`02_runbook.md` |
| 查显示协议 | `docs/01_architecture/HMI_PROTOCOL.md` |
| 查ADC/算法融合 | `docs/02_integration/TEAMMATE_4096_2_CODE_CHAIN_AND_IMPLEMENTATION_NOTES.md` |
| 查历史故障 | 本知识库`05_known_issues.md` |
| 查正式报告 | `docs/05_report/final/README.md` |
| 查获奖结果 | 本知识库`12_final_result_and_code_locations_2026-09-20.md` |
