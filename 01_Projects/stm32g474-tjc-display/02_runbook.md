# Runbook

## 先判断你的目的

| 目的 | 使用位置 |
|---|---|
| 复现实赛最终源码 | `G_Periodic_Signal_Analyzer\teammate\24` |
| 查看赛前V2.8重构 | `G_Periodic_Signal_Analyzer\firmware` |
| 查看队友较早底座 | `G_Periodic_Signal_Analyzer\teammate\current` |
| 查正式提交报告 | `G_Periodic_Signal_Analyzer\docs\05_report\final` |
| 查赛题、名单和HMI资料 | `F:\AcademicHub\000资料相关\电赛\2026TI杯` |

## 最终工程构建

Keil工程：

```text
F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer
\teammate\24\ADC\MDK-ARM\ADC.uvprojx
```

Keil：

```text
D:\Work\Keil5\UV4\UV4.exe
```

为了保持`teammate/24`冻结，正常审计不要直接重建原目录。需要复现时，先在Git
工作区外复制一份临时目录，再运行：

```powershell
& 'D:\Work\Keil5\UV4\UV4.exe' `
  -r 'ADC.uvprojx' `
  -j0 `
  -o 'rebuild.log'
```

验收不能只看进程退出码；必须检查日志出现`0 Error(s), 0 Warning(s)`，并核对
新HEX修改时间、长度和SHA-256。冻结工程自带HEX指纹为：

```text
C4E651067E5E20CB610CAFE3AE097FF3796B4388B35604D7D89D5DC9B2E36FC7
```

## SWD烧录

```powershell
$cli = 'F:\AcademicHub\STMicroelectronics\stm32cubeprogrammer\bin\STM32_Programmer_CLI.exe'
$hex = '<临时复现目录>\ADC\MDK-ARM\ADC\ADC.hex'
& $cli -c port=SWD mode=UR reset=HWrst -w $hex -v -rst
```

必须看到连接、擦除、写入、校验和复位完成。Keil或CubeProgrammer GUI占用ST-Link
时先断开，不能并发连接。比赛已结束，除非明确需要复现，不要给现有板卡自动烧录。

## 最小运行验收

1. 上电后确认MCU进入主循环而非HardFault、Error_Handler或启动BKPT。
2. 检查两路DMA数组非全0、非饱和且随输入变化。
3. 检查`VO[4096]`按ADC1/ADC2顺序交错。
4. 检查桥接结果序号持续递增。
5. 检查dashboard已上报两条曲线数字ID。
6. 分别验证无信号、单频、双频和三频输入。
7. 验证1T/3T只改变横向周期数，不改变Upp、Urms和频谱。
8. 验证刷新、停止、清除、测试以及KEY1短按/长按。

## 屏幕和串口诊断顺序

```text
CPU运行位置
→ ADC DMA与VO
→ FFT/Goertzel结果
→ AnalyzerBridge序号与快照
→ dashboard.valid与曲线ID
→ USART3 ORE/错误状态
→ FE/FD握手和对象ID
```

整屏无图时不要先改曲线算法。测试模式正常而真实模式异常，问题通常在采集、算法
或桥接；两种模式都无图，优先查页面握手、UART和曲线协议。

## 固定源码指纹检查

```powershell
Get-FileHash -Algorithm SHA256 `
  'F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\teammate\24\Core\Src\main.c'
```

期望：

```text
C12E9457F697F2816666BA39715B98D29453572F613888421E431A635F3EB914
```

完整关键文件表见仓库`docs/00_overview/FINAL_COMPETITION_SOURCE.md`。

## Git与赛后整理

```powershell
git -C 'F:\Project\stm32G474VETx\TI' status --short --branch
git -C 'F:\Project\stm32G474VETx\TI' log -n 12 --oneline --decorate
git -C 'F:\Project\stm32G474VETx\TI' diff --check
```

当前工作树包含赛末未提交材料。整理时必须按主题分批审计，禁止`git add -A`后直接
发布。用户未明确要求发布时，不自动commit、tag或push。

## 资料和知识库维护

- 比赛资料入口：先读`F:\AcademicHub\000资料相关\电赛\2026TI杯\README.md`。
- 项目知识库：先读本目录`README.md`、`00_project_brief.md`和`10_project_summary.md`。
- 新事实只更新`01_Projects/stm32g474-tjc-display`；不得顺手改其他项目。
- 最终源码、报告或获奖证据变化时，同步更新项目地图和冻结哈希。
