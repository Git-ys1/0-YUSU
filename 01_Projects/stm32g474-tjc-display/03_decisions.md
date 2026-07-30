# Decisions

## 2026-07-29: 以TI目录作为总仓库，两个工程保持独立

- Git根目录设为`F:\Project\stm32G474VETx\TI`，远端仓库为`Git-ys1/STM32G474-Periodic-Signal-Analyzer`。
- 正式工作区命名为`G_Periodic_Signal_Analyzer`，不再使用含义模糊的`TI`作为远端仓库名。
- 原`test/TJC_sine_test`复制为`projects/tjc_display_demo`，原`test/Core`复制为`projects/teammate_adc_reference`。
- 两套工程分别属于显示负责人和信号处理负责人，当前只做统一归档，不视为已经合并。
- 原`test/`暂不删除，并通过根`.gitignore`排除；`Core.zip`等原始交接包不发布。
- `F:\AcademicHub\000资料相关\电赛\2026TI杯`仅作为赛题和文档证据来源，不纳入代码仓库。

## 2026-07-29: 显示逻辑从 main.c 等价拆分

- `tjc_hmi.c/.h`只负责UART、字符串指令、文本、`cle`、`addt`、FE/FD握手和四字节事件解析。
- `display.c/.h`只负责模拟数据、时域重采样、演示DFT、曲线映射和页面动作。
- `main.c`只调用`Display_Init(&huart3)`和`Display_Task()`，CubeMX初始化区保持不变。
- HMI几何参数固定为通道0、宽674、8位纵坐标0到255，不恢复14字节动态几何协议；曲线数字ID必须按页面区分，不能因`objname`均为`s0`而共用。
- 频谱整帧数据保持横向反转，使100 kHz谱线位于0到500 kHz横轴左侧约20%。

## 2026-07-30: 曲线数字ID按页面固定

- `time.s0`的数字ID为11，发送`cle 11,0`和`addt 11,0,674`。
- `spectrum.s0`的数字ID为1，发送`cle 1,0`和`addt 1,0,674`。
- 淘晶驰控件的`objname`相同不代表数字ID相同；显示代码必须使用当前页面的真实数字ID。
- 该修复只涉及显示工程，不改信号处理工程、页面协议、模拟信号、演示DFT、频谱方向和FE/FD握手。

## 2026-07-30: V1.3改为dashboard单页面并动态上报曲线ID

- HMI由`time`/`spectrum`双页面改为单一`dashboard`页面，同时显示`s_time`和`s_spec`两块794×145曲线。
- 页面后初始化发送`A5 20 01 time_id spec_id 5A`；MCU动态保存两个真实数字ID，不再硬编码11和1。
- `b0`/`b1`继续发送1T/3T四字节帧，但按钮只刷新时域曲线，不重复刷新频谱。
- dashboard首次就绪后按“时域曲线、频谱曲线、六项文本”的顺序初始化显示。
- 保留单一`display.c`执行上下文、模拟正弦、演示DFT、频谱方向修正和FE/FD握手；不恢复旧的`tjc_hmi.c/.h`拆分。
- 当前任务书与实现提交为`65d9897`，实机回归前不得再改协议、数据源或USART配置。

## 2026-07-30: dashboard增加显式刷新协议并使用定点文本格式化

- `b2`弹起事件发送`A5 01 02 5A`；MCU不直接使用旧ID重画，而是重新发送`page dashboard`，等待6字节初始化帧后完整刷新。
- 1T/3T仍只刷新时域曲线；刷新按钮才重新绘制时域、频谱和六项文本。
- 结果文本不再依赖newlib-nano的`%f`支持，统一将浮点测量值转换为定点整数后用`%lu`输出。
- 不修改USART3、曲线动态ID协议、模拟数据、演示DFT、频谱方向和FE/FD握手。

## 2026-07-30: V1.3.1冻结为已验证dashboard显示基线

- 正式配套HMI为最新单页面`testv2.HMI`；旧`testv1.HMI`属于双页面历史版本，不得与当前固件混用。
- Dashboard完整刷新不再因频谱局部失败而跳过六项文本；频谱失败时由`t_c3`显示曲线ID、HAL状态和HMI状态码。
- HMI模拟器已验证1T、3T、100 kHz演示频谱和六项文本完整显示，FE/FD握手正常。
- 本次冻结版本命名为`v1.3.1`；后续只替换演示数据源和正式结果接口，不同时改动已验证显示协议。

## 2026-07-29: 正式显示不能只由频率和半幅度重建

- G题正式输入由基波与1个或2个谐波组成，总计2或3个频率分量；不同相位关系会改变时域波形。
- 显示模块必须接收处理后的真实时域采样数组，不能只根据“基频+半幅度”合成正弦波。
- 频谱接口必须支持最多3个分量，并按频率从低到高排列；频谱幅值统一使用峰值，不使用峰峰值或有效值。
- 时域显示仍由屏幕模块完成1周期/3周期截取、重采样和坐标映射，但不得改变原始波形的相对形状。

## 2026-07-30: V1.4以队友工程为基线建立独立全量融合工作区

- 新工作区固定为`projects/g474_full_integration_test`，由`teammate_adc_newest`完整复制；原队友工程和`projects/tjc_display_demo`均保持只读。
- 统一结果接口为`AnalyzerResult`，真实模式在队友FFT、Vpp和RMS全部完成后通过`AnalyzerBridge_PublishReal()`生成稳定快照。
- 真实频谱直接采用队友第一次`fft()`得到的2至3个谱峰；显示侧演示DFT已删除，避免出现两套互相矛盾的频谱算法。
- `Vpp_R()`内部会再次调用`fft()`并覆盖`F/V/FB/VB/FC/VC`，因此必须在第一次FFT后立即保存谱峰，再继续执行队友原有Vpp/RMS流程。
- 测试按钮`A5 01 04 5A`只注入“分析完成后的最终结果”，不伪造ADC或FFT输入；6个测试场景的波形、Vpp、RMS和频谱分量由同一场景定义生成。
- 测试覆盖使用锁存状态：真实采集与算法继续运行并更新真实缓存，显示端在测试宏开启时优先读取测试快照。
- 当前V1.3.1实际显示基线没有独立`tjc_hmi.c/.h`；通信、动态曲线ID、FE/FD握手和事件解析继续保留在`display.c`，不为了任务书旧假设重建重复模块。

## 2026-07-30: V1.4融合稳定基线按运行事实冻结

- 当前唯一融合基线为`projects/g474_full_integration_test`，不反向修改`tjc_display_demo`或`teammate_adc_newest`。
- 主链路冻结为“ADC2/TIM3/DMA → 队友FFT/Vpp/RMS → AnalyzerBridge稳定快照 → Display_Task → USART3 → dashboard”。
- `Vpp_R()`会二次执行FFT并覆盖共享谱峰，因此在第一次FFT后立即保存F/V、FB/VB、FC/VC，再计算Vpp和RMS。
- `AnalyzerResult`为1084字节，大于1 KB主栈；发布缓存和显示缓存必须使用模块静态对象，不得重新放回局部变量。
- USART3接收固定使用单字节中断，回调只喂解析器并设置动作；曲线生成和`addt`阻塞发送继续在主循环。
- ArmClang工程显式保留`__ARM_use_no_argv`，避免无半主机环境下启动库执行`BKPT 0xAB`。
- dashboard初始化、动态曲线ID、四个按钮帧、794×145曲线和FE/FD握手均已实测，后续不再以“代码更美观”为理由重构。
