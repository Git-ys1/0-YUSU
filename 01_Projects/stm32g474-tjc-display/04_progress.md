# Progress

## 2026-07-29

- 已在`F:\Project\stm32G474VETx\TI`建立G题总仓库，并发布到`https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer`。
- 正式工作区为`G_Periodic_Signal_Analyzer`，内部保存显示工程`tjc_display_demo`和信号处理工程`teammate_adc_reference`。
- 原`test/`完整保留但不进入版本库；复制工程未携带嵌套`.git`、Debug/Release等生成目录或`Core.zip`。
- 总仓库首个提交为`f84f268 初始化：整理G题双工程工作区`，默认分支为`main`，远端可见性为public。
- 已将已验证的显示功能从`Core/Src/main.c`拆分到`display`和`tjc_hmi`模块。
- 保留模拟100 kHz正弦、256点演示DFT、1/3周期显示、页面就绪门控和`addt -> FE -> data -> FD`握手。
- STM32CubeIDE 2.1.0 Debug全量构建通过：0 errors、0 warnings。
- 构建结果：text 23680 B、data 96 B、bss 4792 B。
- `.ioc`、USART3 115200 8N1、PC10/PC11和CubeMX初始化代码未改。
- 已补齐`display.c`和`tjc_hmi.c`全部函数定义前的中文Doxygen注释；仅改注释，重新构建仍为0 errors、0 warnings。
- 已重新核对G题题面、北京赛区两轮问答和江苏赛区回复：
  - 第二问复合波峰峰值为50至250 mV，全部频率分量位于10至500 kHz；
  - 正式信号由基波与1个或2个谐波组成，每个分量峰值不低于5 mV；
  - 频谱分量幅值指峰值，频谱只要求正频率轴幅度谱，不要求相位谱；
  - 时域画面必须稳定显示1个或3个完整周期，触摸屏虚拟按钮可作为键控；
  - 基频是500 Hz的整数倍，FFT频率分辨率必须不大于500 Hz；
  - 图形和测量结果应在启动或选择后2秒内显示。
- 已审查队友`teammate_adc_reference`工程：
  - 使用ADC2、DMA、TIM3触发、2048点CMSIS CFFT，并尝试计算峰峰值和真有效值；
  - 当前只提取两个最强谱峰，且把最强峰当作`F`，不能覆盖最多3个分量，也不能保证识别基频；
  - `vpp`和`Vrms`仍是主循环局部变量，未提供结果结构体、有效标志或显示接口；
  - 未导出可供屏幕稳定显示的一个周期波形，未实现第三问的高频干扰抑制；
  - 实际TIM3触发率约为1024096.39 Hz，2048点FFT频点间隔约500.047 Hz，略大于题目500 Hz上限。
- 已确认正式HMI源工程仍位于资料目录`淘晶驰串口屏\testv1.HMI`，当前尚未随代码工作区归档。

## 2026-07-30

- 已修复`time`页面按下`b1`或`b3`后返回`12 FF FF FF`的问题。
- 根因是模块化精简时错误地让两个页面共用曲线数字ID 1；实际`time.s0=11`、`spectrum.s0=1`。
- 时域现使用`cle 11,0`和`addt 11,0,674`；频谱继续使用`cle 1,0`和`addt 1,0,674`。
- 已新增`docs/HMI_LAYOUT.md`与`docs/DEBUG_HISTORY.md`记录布局参数、故障现象、根因和回归顺序。
- STM32CubeIDE 2.1.0 / GNU Tools for STM32 14.3 Debug构建通过：0 errors、0 warnings；text 23680 B、data 96 B、bss 4792 B。
- 本次未修改`main.c`、`.ioc`、USART3配置、页面协议、FE/FD握手、演示数据、频谱方向或队友工程。
- 当前显示实现冻结为单一`display`模块：`main.c`只调用`Display_Init(&huart3)`和`Display_Task()`，通信、4字节协议、FE/FD握手、时域重采样、内部正弦和演示DFT均在`display.c`内部以私有函数组织，不再保留`tjc_hmi.c/.h`。
- 已新增`docs/CURRENT_DISPLAY_BASELINE_PATH.md`，记录当前代码入口、函数职责、时域/频谱数据流、关键状态和后续接入真实信号时的不可变边界。
- 已按V1.3任务书把显示改为`dashboard`单页面：`s_time`和`s_spec`均为794×145，页面用6字节初始化帧动态上报两个曲线ID。
- MCU删除旧双页面ready、页面切换和`current_page`逻辑；上电发送`page dashboard`，收到真实ID后依次绘制时域、频谱并更新六项完整UTF-8文本。
- 1T/3T按钮只重画时域；100 kHz演示谱线继续保持在0至500 kHz横轴左侧约20%。
- 已补齐`HMI_LAYOUT.md`、`HMI_PROTOCOL.md`、`DISPLAY_ARCHITECTURE.md`和`CURRENT_STATUS.md`，并将V1.3任务书纳入版本库。
- STM32CubeIDE 2.1.0 / GNU Tools for STM32 14.3 Debug Clean Build通过，无warning；当前产物text 24292 B、data 96 B、bss 4920 B。
- 本次提交：`65d9897 feat: 切换dashboard单页面显示`；未修改`main.c`、`.ioc`或`teammate_adc_reference`。
- V1.3.1完成HMI模拟器回归：1T、3T、100 kHz频谱线、Upp、Urms、基频和频谱分量文本均正常显示。
- 已确认故障链由启动页握手无恢复路径、频谱失败提前阻断文本、以及newlib-nano浮点格式化三项叠加形成。
- 已新增刷新按钮`A5 01 02 5A`、定点整数文本格式化和频谱错误现场诊断。
- STM32CubeIDE 2.1.0 Clean Build通过：0 errors、0 warnings；text 23880 B、data 96 B、bss 4920 B，总计28896 B。
- 发布复盘和截图证据写入`docs/DASHBOARD_V1.3.1_RELEASE.md`；正式配套HMI确认为最新单页面`testv2.HMI`。
- 已将队友2026-07-30最新信号处理工程原样归档到`projects/teammate_adc_newest`，提交并推送为`ef394ba chore: 归档队友最新信号处理工程`；未修改`tjc_display_demo`或V1.3.1显示基线。
- 新快照继续使用ADC2（PA7/IN4）、TIM3 TRGO、DMA循环采集2048点和CMSIS 2048点CFFT；程序把ADC码转换为0至3.3 V浮点数组后计算频谱、峰峰值和真有效值。
- 相比`teammate_adc_reference`，新快照新增第三个谱峰`FC/VC`、三个谱峰按频率升序排序的`sof()`、2/3分量标志`flag`，并把稳健峰峰值改为最低5点均值与最高5点均值之差。
- ADC配置由2倍过采样改为关闭过采样，采样时间由2.5周期改为24.5周期；频率换算仍硬编码为1024000 Hz。
- 随快照带来的Keil构建日志显示MDK 5.42 / ArmClang 6.23构建为0 errors、0 warnings；发布时只提交源码、CubeMX/Keil工程配置和驱动，约45 MB Keil中间产物及本机`DebugConfig`未上传。
- 当前新快照仍未形成显示模块可直接消费的稳定结果接口：`vpp`与`Vrms`仍是主循环局部变量，谱峰使用全局`F/V/FB/VB/FC/VC`，没有结果结构体、结果有效标志或一个周期波形导出接口。
- 已按V1.4任务书创建独立融合工程`projects/g474_full_integration_test`，没有修改`teammate_adc_newest`或`tjc_display_demo`。
- 新增`analyzer_bridge.c/.h`：真实和测试结果统一收敛为`AnalyzerResult`，单位统一为Hz、mV和mVpk，并只保存256点显示波形。
- 真实模式在第一次FFT后保存`F/V/FB/VB/FC/VC`，待队友原有Vpp/RMS完成后发布；正式频谱直接使用队友FFT谱峰，显示侧演示DFT已删除。
- 新增`A5 01 04 5A`随机测试结果注入，内置6个相干场景，按波形计算Vpp和RMS，使用xorshift32并避免连续重复，测试覆盖锁存不阻塞真实ADC流程。
- 补入官方STM32Cube G4 V1.6.3的CMSIS-DSP头文件，Keil Include Path和DSP库改为仓库相对路径；只在融合工程中将不可用的Arm Compiler 6.23调整为本机6.7。
- Keil Clean Rebuild通过：0 errors、0 warnings；Code 55304 B、RO-data 25700 B、RW-data 52 B、ZI-data 46108 B；同时验证`ANALYZER_TEST_ENABLE=0`时桥接模块可编译。
- 已新增`TEAMMATE_OUTPUT_MAP.md`、`DSP_DEPENDENCY_AUDIT.md`、`INTEGRATION_CHANGES.md`和`SCREEN_TEST_GUIDE.md`。
- V1.4初次烧录后依次修复三项运行时故障：ArmClang半主机`BKPT 0xAB`、2048点FFT期间USART3 ORE、1084字节`AnalyzerResult`导致1 KB主栈溢出。
- USART3已改为中断接收并在错误回调中清ORE、flush和重挂；耗时绘图仍在主循环。
- 大型桥接结果已改用静态RAM，ST-Link确认最终MSP位于合法栈区，CFSR/HFSR为0。
- Keil ArmClang 6.7最终Clean Rebuild通过：0 errors、0 warnings；Code 56544 B、RO-data 25700 B、RW-data 52 B、ZI-data 48276 B。
- 最终`ADC.hex`为231548字节，SHA-256为`80F21985D63D5E0968E4EEB423243C1277CB32EDDC02DF4A3781F5BDA5676693`。
- HMI模拟器已稳定验证1T、3T、刷新、测试按钮、复合时域波形、最多3根频谱线和六项文本。
- 已验证10.5/31.5/42 kHz场景（Upp 126.0 mV、Urms 40.93 mV）和120/240/480 kHz场景（Upp 136.1 mV、Urms 45.28 mV）。
- 当前阶段冻结为V1.4全量融合稳定基线，后续只做真实输入标定、算法边界和实体屏回归微调。

## Evidence

- `F:\Project\stm32G474VETx\TI\README.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\integration-notes.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\HMI_LAYOUT.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\DEBUG_HISTORY.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\DISPLAY_BASELINE_FREEZE_2026-07-30.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\CURRENT_DISPLAY_BASELINE_PATH.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\CURRENT_STATUS.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\DISPLAY_ARCHITECTURE.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\HMI_PROTOCOL.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\tjc_display_demo\Core\Src\main.c`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\tjc_display_demo\Core\Src\display.c`
- 构建产物位于本地忽略的`projects\tjc_display_demo\Debug`目录。
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\teammate_adc_reference\Core\Src\main.c`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\teammate_adc_newest\Core\Src\main.c`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\teammate_adc_newest\Core\Src\adc.c`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\g474_full_integration_test\Core\Src\analyzer_bridge.c`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\projects\g474_full_integration_test\Core\Src\display.c`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\TEAMMATE_OUTPUT_MAP.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\DSP_DEPENDENCY_AUDIT.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\INTEGRATION_CHANGES.md`
- `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer\docs\SCREEN_TEST_GUIDE.md`
- `F:\AcademicHub\000资料相关\电赛\2026TI杯\2026电赛命题（北京赛区）\2026电赛命题（北京赛区）\G题_周期信号测量分析装置.pdf`

## Memory Routing Audit

| Candidate Lesson | Route | Target | Action | Evidence |
|---|---|---|---|---|
| dashboard双曲线ID必须由HMI初始化帧动态上报 | project-only | `03_decisions.md` | written | V1.3协议与提交`65d9897` |
| 单页面首次就绪后按时域、频谱、文本顺序初始化 | project-only | `03_decisions.md` | written | `DISPLAY_ARCHITECTURE.md`与构建产物 |
| newlib-nano未启用浮点printf时显示测量值 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | V1.3.1文本空白故障及Clean Build链接参数 |
| 局部曲线失败不应阻断独立测量文本 | cross-project pattern | `03_CrossProject/pitfalls.md` | written | V1.3.1频谱失败导致整页占位符故障 |
| testv2.HMI必须与V1.3.1固件成对冻结 | project-only | `03_decisions.md` | written | HMI模拟器实测与用户确认 |
| 第二个处理函数会覆盖共享FFT输出时必须先快照 | project-only | `03_decisions.md` | written | `Vpp_R()`再次调用`fft()`，V1.4在第一次FFT后保存谱峰 |
| 随机联调应注入一致的最终结果而不是伪造ADC输入 | project-only | `03_decisions.md` | written | V1.4 AnalyzerBridge六场景与测试覆盖锁存 |
| Keil工程的编译器固定版本和DSP绝对路径不可当作可移植依赖 | cross-project tooling | `03_CrossProject/tooling.md`与`06_Maps/tool-map.md` | written | V1.4本机缺少6.23且原Include指向队友E盘 |
| 屏幕无图应先用ST-Link分层定位CPU/Fault/栈/UART/模块状态 | cross-project tooling | `03_CrossProject/stm32-stlink-runtime-debugging.md` | written | V1.4三次不同根因均表现为无图 |
| 大于主栈的结果快照不得作为嵌套局部变量 | cross-project pitfall | `03_CrossProject/stm32-stlink-runtime-debugging.md` | written | 1084字节AnalyzerResult与1024字节Stack_Mem |
| ArmClang升级后应复核半主机和argv选择符 | cross-project pitfall | `03_CrossProject/stm32-stlink-runtime-debugging.md` | written | `_sys_command_string`触发BKPT 0xAB |
| 高计算负载下HMI接收不能只依赖主循环轮询 | project architecture | `03_decisions.md` | written | FFT期间USART3 ORE与中断接收修复 |
