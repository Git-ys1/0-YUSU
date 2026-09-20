# Progress

## 2026-08-01: 软件总体流程图按正式链路重制

- 基于`teammate/last/Core/Src/main.c`与当前`firmware/`桥接、显示代码，使用本机
  Microsoft Visio重新生成A4纵向软件总图。
- 总图只保留双ADC交错采集、FFT/分量判定、Goertzel相位、理论波形复原、结果桥接、
  主循环绘图及USART3输出，不纳入测试注入、历史算法或内部模式名称。
- 根据用户审稿意见进一步收敛为9个高层节点：纯黑线、黑字、白底，三个初始化框
  合并为一个“初始化”，图面删除函数名、数组长度和中断细节；PNG另转严格灰度，
  SVG仅含黑白两种颜色。
- 可编辑源图、SVG、PNG、源代码追溯表、模块清单和审查记录位于
  `docs/05_report/figures/`；VSDX已通过关闭重开检查。

## 2026-08-01: V2.7最终队友基线融合与预交接包

- 已完整审计队友最终版；相对旧融合底座的有效源码变化仅在`main.c`，ADC、DMA、
  TIM、Goertzel、桥接和显示外设文件未变。
- 已将981点前级相位表、第二次FFT后的频谱/`Vr`和队友理论Upp融合到`firmware/`；
  时域图直接消费同一组4096点理论值。
- 旧普通/Huber折叠、频率细化、模型Mpp和鲁棒Vpp不再进入最终调用链；链接后
  `AnalyzerBridge_CalculateRobustModelVpp`及Huber工作区均被移除。
- 本地测试版Keil Arm Compiler 6.7构建0 error、0 warning：Code 70820、
  RO-data 81980、RW-data 176、ZI-data 73848；HEX SHA-256为
  `C2E7E1A525DDAFE8CBBCA92614FAD0A02955D6881E170D530704C16FC50E4E0F`。
- 队友生产宏关闭版同样0 error、0 warning：Code 69900、RO-data 48556、
  RW-data 176、ZI-data 73848。
- 已生成`deliverables/V2.7更新包.zip`，SHA-256为
  `E61DDEBCE5075D591A7C45799759691A91350FDE0A514C88A21E2E2C5EEA3F8F`；本轮没有
  烧录、Git提交或发布，等待队友先融合并实机测试。
- 单独交付`deliverables/V2.7_main耗时优化建议.md`：P0为消除隐式double、只算
  1024个有效FFT模和双分量跳过第三路Goertzel；第二次FFT仅在同ADC向量回归后
  才建议删除，不把未经验证的优化混入当前融合包。
- 用户随后明确要求烧录当前测试版；STM32CubeProgrammer 2.22.0通过SWD完成擦除、
  下载、校验和复位，返回码0。烧录HEX SHA-256为
  `C2E7E1A525DDAFE8CBBCA92614FAD0A02955D6881E170D530704C16FC50E4E0F`；当前只证明
  固件已写入，双ADC、理论波形、Vr和刷新时延仍待现场验收。

## 2026-08-01: V2.6.0幅相解析与公式Vpp发布

- 队友`win`版本提升为当前底座，正式固件合入Goertzel分量相位、相对谐波相位
  和4096相位点解析Upp；保留我方显示桥接、触发、折叠和Huber所有权。
- `Vpp_Robust()`不再进入运行链，链接后ZI由上一版约116556降至100212；源码仅
  留作历史对照。
- 72组双/三分量离线回归：解析Upp最大绝对误差0.037693 mV，原`getup()`对照
  最大误差237.181502 mV。
- Keil Arm Compiler 6.7构建0 error、0 warning；HEX 445794 bytes，SHA-256
  `12550422C8989B88B920995E7D5B5D742B77030F58DC761D79F30B2C5B64C53D`，已烧录、
  校验和复位。
- 提交`4894940`、标签`v2.6.0`和GitHub Release已发布：
  `https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.6.0`。

## 2026-08-01: sw_model与ADC部分V1完成但暂未发布

- `sw_model`协议`A5 02 09 mode 5A`已接入；新模式消费队友幅相模型生成的256点
  解析曲线，旧模式继续由`sw_huber`选择普通或Huber。
- 新模式期间HMI事件和MCU解析器双重忽略`sw_huber`；返回旧模式后才接受新的
  Huber控制帧。HMI对象和事件写入`HMI_RECONSTRUCTION_MODE_SWITCH.md`。
- Keil全量重建0 error、0 warning；Code 81508、RO-data 78056、RW-data 172、
  ZI-data 102276；HEX 449365 bytes，SHA-256
  `3D9089FABA9108F786167978AE77AB27915F781021C3F93712F224B61E221261`。
- 因用户尚未加入`sw_model`控件，本版未烧录、未发布。
- `docs/05_report/ADC部分V1.docx`完成；11页A4逐页渲染检查通过，文件SHA-256
  `52150BDF7622C8E9641BCCA7DB9BEE7DEB4E0B27E158ED51B3080B56067EDDB4`。
- 成熟项目回顾审计的27项历史结构缺口仍保留在`06_todo_next.md`；本轮没有可用的
  新session证据文件，不伪造重跑结论，也不借当前功能开发补写整套历史考古文件。

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
- 商家误发不可触摸屏后，已在V1.4稳定基线上加入KEY1（PB8/BOOT0）实体控制：短按切换1T/3T，长按执行原测试命令。
- KEY1与HMI按钮统一进入`Display_ProcessButtonCommand()`，没有建立第二套显示状态机；EXTI只记录按下时刻，主循环处理松开与按压时长。
- Keil ArmClang 6.7最终Clean Rebuild通过：0 errors、0 warnings；Code 56880 B、RO-data 25700 B、RW-data 52 B、ZI-data 48284 B。
- 最终`ADC.hex`为232493字节，SHA-256为`36BC21B04451250138FFFA0F95174AC218E66342375379CFE893A96FAFB268D0`。
- STM32CubeProgrammer 2.22.0已完成下载、校验和复位；实物确认KEY1短按、长按和原HMI按钮共存正常，冻结为V1.4.1实体按键兼容版。
- 已新增`tools/generate_g_problem_adc_tests.py`，按G题第1、2、3问生成9组确定性的原生`uint16_t[2048]`测试数组、JSON清单、CSV误差表和SVG对比图。
- 测试集固定Fs=1.024 MSPS、Vref=3.3 V、1.65 V ADC中点偏置，并包含多个真实频率位于500 Hz栅格半点的场景。
- `AnalyzerBridge`测试模式已从“直接合成分析结果波形”改为“原生ADC数组→与真实输入共用波形提取”；理想Vpp/RMS/谱峰元数据继续用于隔离显示侧验证。
- 旧首周期提取最坏RMSE为26.061 mV；新相关频率细化+2048点相位折叠最坏RMSE为0.865 mV，256点到794列显示插值最坏RMSE为0.749 mV。
- 生成器已通过重复运行SHA-256一致性检查；Keil ArmClang 6.7 Rebuild通过，0 errors、0 warnings，Code 59696 B、RO-data 63272 B、RW-data 52 B、ZI-data 50740 B。
- 最新`ADC.hex`为346073字节，SHA-256为`589BF3A8EF482121B5422A397A3E1414762561FA75185F7364055955EFD8EA74`。
- STM32CubeProgrammer 2.22.0已将120.14 KB有效固件下载、校验并复位，ST-Link电压3.20 V。
- 详细证据见`docs/V1.6_NATIVE_ADC_TEST_DATASET.md`、`tests/generated_adc/manifest.json`和`tests/generated_adc/validation.csv`。

## 2026-07-30: V1.7增加测试编号与9组相位折叠对比图

- 原生ADC测试结构增加固定`test_number`，T1至T9与生成器、JSON、CSV和屏幕显示保持一致。
- 测试模式下在“谐波2”末尾显示`[Tn]`，真实ADC模式不显示，编号不参与任何测量计算。
- 生成器新增`tests/generated_adc/phase_fold_gallery.svg`，逐组叠加理想波形和折叠波形并标出RMSE、最大误差。
- 修复过一次生成器循环变量错误：C头文件初始化曾全部写成9，重新生成后已核对为1,2,3,4,5,6,7,8,9。
- Keil ArmClang 6.7 Rebuild通过：0 errors、0 warnings；Code 59800 B、RO-data 63280 B、RW-data 52 B、ZI-data 50756 B。
- 最新`ADC.hex`为346388字节，SHA-256为`0E0C3B6A9508C99C7E2E93293731369B8F5E375727C3D533B927F22B5C731766`。
- 详细原理与边界见`docs/V1.7_PHASE_FOLDING_AND_TEST_ID.md`。

## 2026-07-31: 自定义波形实验室和混合相位覆盖扫描完成

- 新增`tools/custom_waveform_lab.py`、`waveform_lab_core.py`和双击启动脚本，支持基波加0至2个谐波、全局起始相位、相对相位、噪声和随机种子。
- 工具可保存测试组、导出每组JSON/2048点CSV/PNG/SVG，并统一生成固件头文件`generated_custom_adc_tests.h`。
- 首批T101至T107覆盖10 kHz纯基波、10.5 kHz三分量、128/160/200 kHz相干频率、250 kHz边界与249.75 kHz半栅格场景。
- 7组Python自检通过；最差T103仅命中8个硬相位槽，256槽和794列RMSE均约4.87 mV，证明显示插值不能补回ADC未采到的信息。
- 混合扫描共77430个去重频点，其中9564个为精确有理共振；最差点为`Fs/3`，只命中3/256个硬槽。
- 默认与自定义测试宏两种Keil ArmClang 6.7构建均为0 errors、0 warnings。
- 2026-07-31 01:11 按用户现场验收需要将`ANALYZER_CUSTOM_TEST_ENABLE`切换为1，
  重新生成自定义测试版HEX并通过ST-Link完成下载、校验和复位。HEX SHA256为
  `4B73754C79EC2FBB5EBE139361229F43B48196FFAE755FA45A10EA57C0AF68EC`；
  点击“测试”后应从T101开始显示组号，真实ADC/自动刷新结果仍不显示测试组号。
- 使用说明与相位步进公式见`docs/CUSTOM_WAVEFORM_LAB.md`；扫描输出位于`tests/phase_coverage`。

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
| 本机STM32CubeProgrammer CLI应使用已知固定路径，禁止全盘递归搜索 | cross-project tooling | `03_CrossProject/tooling.md`与`06_Maps/tool-map.md` | written | 2026-07-30 KEY1固件烧录前已确认独立CLI路径 |
| 同一业务动作的触摸按钮和实体按键必须汇入同一命令处理入口 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | KEY1独立显示逻辑曾导致错误曲线，统一复用原按钮命令后实物验收通过 |

## 2026-07-31: V1.8波形实验室与时域方向修复

- `display.c`已补齐时域整帧横向反转；T102的屏幕相位方向现在与PC连续模型一致，纵轴映射未改。
- `custom_waveform_lab.py`新增64/128/256槽选择、1T/3T、清晰的三图说明和谐波最小二乘对比。
- 新增T108精确256 kHz纯基波：4个独立相位，64/128/256槽显示RMSE分别约8.375/8.222/8.191 mV，谐波最小二乘约0.236 mV。
- 新增`analyze_256k_frequency_sensitivity.py`；真实256 kHz误估高100 Hz时，计算覆盖率虚高到82.03%，但折叠RMSE升到27.33 mV，LS样本残差为13.80 mV。
- Python语法检查、8组×3档槽数无界面自检、T102/T108图像检查和±500 Hz灵敏度扫描均通过。
- Keil ArmClang 6.7构建通过：0 errors、0 warnings；`ADC.hex`为334267字节，SHA-256为`159E08A37C5BE6B3607226836095129A166AE0081AF866B3581D9695CDDFBD8C`。
- STM32CubeProgrammer已完成SWD下载、校验和复位，日志返回`Download verified successfully`。

## 2026-07-31: V1.9队友ADC1底座融合完成

- 已归档并提交`teammate_adc_reallynewest!`原始快照，提交为`44fc481`。
- 融合工程已同步ADC1/PA0、DMA1 Channel 1、2倍过采样、Vpp新统计、RMS取整和`goertzel_sync.c/.h`。
- 保留第一次FFT快照、静态大对象、no-argv、UART中断、动态曲线ID、FE/FD、时域方向和统一按钮入口。
- KEY1长按已从测试改为刷新真实ADC；短按仍切换1T/3T。
- Keil ArmClang 6.7 Clean Rebuild通过：0 errors、0 warnings；Code 62276 B、RO-data 59000 B、ZI-data 50756 B。
- `ADC.hex`为341332字节，SHA256为`B3C0F656FCEB10C57E68EE742B9AFCA77A8E0D93683D79F3EB8B2A80A403C803`。
- STM32CubeProgrammer完成下载、校验和复位；HOTPLUG读取发布序号3秒内从`0x041A`增至`0x0435`，CFSR/HFSR均为0。

## 2026-07-31: 永久交接包与真实ADC审计入口完成

- 在仓库`docs/HANDOFF`建立九篇长期文档，覆盖项目总背景、G题与官方问答、
  软件工作区与Git、人员职责、硬件接线、软件主链、故障史、当前问题和构建烧录。
- 仓库`README.md`与`docs/CURRENT_STATUS.md`均增加新会话入口；后续上下文压缩或
  换人必须从`docs/HANDOFF/README.md`恢复，不能只读旧任务书或聊天摘要。
- 按当前V1.9源码纠正KEY1文档漂移：短按切换1T/3T，长按刷新真实ADC；旧V1.4.1
  “长按测试”只保留为历史说明。
- 冻结用户实测修正：信号源与ADC引脚示波器Vpp通常差不到5mV，但示波器与
  屏幕Upp经常差超过10mV；单张截图不能用于推断模拟前端固定增益。
- 下一步P0是同步导出信号源、PA0示波器、`adc_b[2048]`和屏幕结果，审计VDDA、
  ADC比例、采样相位和`Vpp_Robust()`，未取得原始数组前不提交显示缩放或平滑补丁。
- 共享知识库新增`11_current_handoff_2026-07-31.md`，Codex长期记忆扩展新增项目
  恢复入口，防止后续会话再次从过时中间态开始。

## 2026-07-31: 显示模块设计报告素材稿

- 新增仓库文档`docs/REPORT_DISPLAY_MODULE_DRAFT.md`，按2026北京赛区设计报告模板组织显示侧素材。
- 内容覆盖职责边界、方案比较、折叠频率细化、256槽相位折叠、1T/3T重采样、频谱线映射、`addt`握手、HMI/KEY1统一交互及测试表。
- 文档明确队友ADC与测量算法只作为上游输入，显示层不重新计算或篡改`Upp`、`Urms`、频率和频谱幅值。
- 文档区分题目要求的按键后2秒响应与当前3秒自动调试刷新，后者不得当作正式响应指标。

## 2026-07-31: V2.3.0正式发布

- 提交`bd295f8`把V2.2真实ADC谐波投影定版与V2.3工作区分层统一发布。
- 标签与GitHub Release均为`v2.3.0`：
  `https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.3.0`。
- 根目录唯一正式固件入口为`firmware/`；队友输入在`teammate/`，旧工程在
  `archive/`，文档从`docs/README.md`分层导航。
- Release附件包含`ADC.hex`、队友生产融合ZIP和波形复原数学说明DOCX。
- `ADC.hex`为362077字节，SHA-256为
  `C4F6BADEAB9B45F0CFB7C5F50FF58912CC9A4C2C64259FA14DBC5991C9A2DCCB`；
  队友ZIP SHA-256为
  `5A7C489F4D86C43032D8C95105972F1737A6417E8504C73FC72C55EFE5BF496D`。
- 发布前验证：42份维护层级README无漏项、Markdown真实断链0、Python工具
  语法通过、613个旧工程追踪文件迁移后缺失0、Keil 0 error/0 warning。

## 2026-07-31: V2.4独立模型Vpp开发构建完成

- `firmware/Core/Src/analyzer_bridge.c`新增全2048点Huber谐波模型Vpp，结果独立
  写入`model_vpp_mv`；未修改`main.c`和队友测量算法。
- `display.c`新增`t_vpp2`文本输出，HMI配置、融合说明、报告草稿、当前状态和
  下一代理任务书均已同步。
- 6倍前端合成验证加入6～40个尖峰，四组新Mpp误差为-0.065%～+0.012%；这只
  证明算法及除6口径，不替代真实硬件标定。
- Keil ArmClang 6.7 Clean Rebuild为0 error、0 warning；Code 74252、RO-data
  59036、RW-data 52、ZI-data 63412，HEX 375115 bytes，SHA-256为
  `E7CCAE4DDF1A09C457B4D856A7CFC640B80E48DE4CFBF7BD2C8FA2136FD1352C`。
- 大求解矩阵移入模块静态工作区；调用图显示模型函数最大栈深352 B、
  `AnalyzerBridge_PublishReal()`完整新链600 B，低于1 KB主栈。
- 当前未烧录、未发布；下一步由用户新增`t_vpp2`后采集信号源/`Upp`/`Mpp`
  三方同帧证据。

## 2026-07-31: dashboard紧凑单页设计完成

- 用户提出把1T/3T两个按钮合并为状态开关、增加坐标刻度，并将时域和频谱改为
  左右并排；设计稿写入`docs/01_architecture/HMI_COMPACT_LAYOUT_DRAFT.md`。
- `sw_period`继续复用`A5 01 01 5A`与`A5 01 03 5A`，HMI触摸无需新增解析协议；
  实体KEY1后的开关视觉同步须在主循环发送，不能在USART中断内阻塞发送。
- 官方文档确认数据记录控件只能用`insert/up/clear`，一定为全局且绑定`.data`
  文件；本项目仅三行实时分量，不采用该控件，继续使用普通文本或数值控件。
- 当前图中曲线横向按407/328点规划；建议高度改为256以匹配0～255的8位曲线
  数据。两条曲线透传量可由1588字节降为735字节，单页无需拆分。
- 本轮只完成设计与官方资料审计，没有修改用户正在编辑的`testv2/testv3.HMI`，
  也没有提前修改固件宽高常量、构建、烧录或发布。
- 用户终止HMI自动化尝试后，设计稿已补为800×480手工坐标定稿；Codex打开的
  编辑器已关闭，`testv3.HMI`与操作前备份SHA-256一致，确认没有保存改动。

## 2026-07-31: V2.4.0紧凑坐标轴与独立模型Mpp发布

- 提交`554cdcb`、标签`v2.4.0`已推送，GitHub Release：
  `https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.4.0`。
- 最终曲线为512×256时域和256×256频谱；动态时域us/mV、频谱mV刻度与
  `sw_period`主循环回写均进入`firmware/Core/Src/display.c`。
- 时域纵轴和真实波形统一折回输入端，独立`Mpp`与曲线口径一致；未修改
  `main.c`或队友`Vpp_Robust()`。
- Keil ArmClang 6.7全量重建为0 error、0 warning；Code 75556、RO-data 59164、
  RW-data 172、ZI-data 63124。
- `ADC.hex`为379480 bytes，SHA-256为
  `A011FD6699D7452C4200FCE385C3BB4FE2C718503CBBEE252B1D41E6A1B2D252`，已附到Release。
- 用户手工HMI尚未归档和实屏回归；发布结论只覆盖源码、构建和HMI契约。

## 2026-07-31: V2.4队友最小增量包已准备

- 增量基准是队友已经融合V2.2生产包；不再要求重做完整融合，也不覆盖队友
  后续修改过的`main.c`。
- `deliverables/V2.4更新包/`只含`analyzer_bridge.c/.h`和`display.c`；
  `display.h`与`main.c`相对上一包无变化。
- 队友包保持`ANALYZER_TEST_ENABLE=0`，因此不携带随机测试数组；KEY1长按继续
  由队友现有`main.c`执行真实ADC刷新。
- 生产配置独立Keil重建为0 error、0 warning；Code 74900、RO-data 25740、
  RW-data 172、ZI-data 63124。
- 压缩包为`deliverables/V2.4更新包.zip`，SHA-256为
  `5CD690DCDAC328B7EC34ADA49FBD34451811D6BF4873F25292A50AA4020D2F02`。
- 这是预交接包；队友发回其最新工程后仍须做一次三文件冲突对比再定版。

## 2026-07-31: 淘晶驰官方指令集转为本地Markdown

- 用户提供的46页淘晶驰官方`help.pdf`已归档到
  `docs/01_architecture/tjc_official_reference/`，不再堆在`docs`根目录。
- 新增`TJC_HMI_INSTRUCTION_SET.md`，按48条对象/系统指令、10条GUI指令、
  30个系统变量、8个颜色值、31类返回帧及高级协议分层，可直接全文检索。
- `addt`的`0xFE/0xFD`透传握手、CRC、HMI下载、文件透传和单片机通信示例均
  已抽样对照原PDF；原PDF与Markdown并存，遇到跨栏或版本歧义时可回看原版。
- PDF SHA-256为`C784798C5880A1A6F4A79B1159554F64C160B6EE360F6D4006DF7FB828CB1311`；
  Markdown SHA-256为`9B62785CB5177A809BD8BD3FAE3CD0AA83C61B762AEC3AFC0061E6283BF5C5BE`。

## 2026-08-01: 官方模板版显示模块报告初稿完成

- 以`北京市大学生电子设计竞赛设计报告模板（2026）.doc`为唯一母版生成
  `docs/05_report/北京市大学生电子设计竞赛设计报告_显示模块初稿.docx`，未覆盖原模板。
- 只在“2 理论分析与计算”新增“基于相位同步与Huber估计的周期波形重构”，
  只在“3.2.2 主要模块软件设计思路”新增桥接模块和显示交互模块；硬件、ADC和
  FFT正文均未代写。
- 理论部分解释相位域同步折叠、残差中位数/MAD、Huber权重、谐波约束重构及
  全2048点模型Vpp；副本使用现代兼容模式15，7个公式关闭并重开后仍为Word
  原生OMML，跨页审计为2页。
- 自动审计确认：剔除24个新增段落后，模板原有145段文字和可见格式逐段一致，
  页边距、页眉页脚及6个原有媒体对象一致；10页渲染逐页无裁切或重叠。

## 2026-08-01: 双ADC高速采样独立实验工程建立

- 新增`experiments/g474_high_speed_adc/`，与唯一主线`firmware/`隔离；只验证
  PA0原始采集，不含屏幕、FFT和正式分析算法。
- ADC1/ADC2共同采样`PA0=ADC12_IN1`，12位双ADC交错，DMA以1024个32位
  CDR打包字采集并拆为`g_adc_samples[2048]`。
- HSI16经PLL得到164 MHz，ADC同步时钟为41 MHz，交错间隔10周期，配置等效
  采样率4.100 MS/s；目标4.096 MS/s误差为+0.0977%，没有让单ADC超过4 MS/s。
- 新增DWT粗测速率、min/max、校验和、重新抓帧命令和Keil/CubeProgrammer脚本；
  Keil ArmClang 6.7构建0 error、0 warning，当前未烧录、未做信号源实测。
- 对本地`digital-lpf`源码和作者8月1日视频文档完成对照：F103没有ADC/DMA，
  只生成64点正弦验证31抽头Q15 FIR并用115200文本串口发送。

## 2026-08-01: V2.5.0双ADC 4096点VO桥接发布

- 以队友`4096-2`为新底座完成双ADC融合：ADC1/PA0与ADC2/PA1各2048点，交错
  得到`VO[4096]`；保留队友FFT频响修正前移、峰值RSS合成和现有Vpp/RMS逻辑。
- 修复旧桥接调用把2048点`adc_b`按4096点读取并重复按ADC码换算的越界/单位错误；
  新接口直接接收单位V的`VO`，并用Prepare/Publish两阶段避开`Vpp_R()`原地改写。
- 正式主线Arm Compiler 6.7构建0 error、0 warning，`ADC.hex`为437530 bytes，
  SHA-256为`CEFA87F1953CEDE198AE476043E0E169BF66CAD7D808335D8B1743A545DB86C2`；
  已通过STM32CubeProgrammer下载、校验并复位。
- 队友生产包`deliverables/V2.5更新包.zip`只含桥接头源文件和简短接线说明，
  15423 bytes，SHA-256为
  `8F20B56BA04016FEA0355C5DA8C0A1E421DCF2A6DD3D54F009D6D942746173DF`；
  以队友工程独立构建0 error、0 warning，未覆盖其`main.c`。
- Git提交`d40eb01`、标签`v2.5.0`和GitHub Release已发布；随后以`e73f8b9`
  修正摘要中“三处手工改动”被误写成“两处”的文案，并覆盖Release交接包资产。
  最长Word设计报告只替换6处接口/点数文字，171段、25个OMML公式和11页版式保持不变。
- 新增`TEAMMATE_4096_2_CODE_CHAIN_AND_IMPLEMENTATION_NOTES.md`，记录队友完整
  采样、FFT、测量和显示接线链路；它是实现说明，不是最终竞赛报告正文。

## 2026-08-01: V2.7模式切换修复交接包

- 修复`sw_model=0`被拒绝并回写1的问题；新/旧算法现可双向切换，且每帧只运行
  当前选择的复原链，旧模式下普通/Huber重新有效。
- 本机测试配置构建为`Code=78452, RO-data=81988, RW-data=176, ZI-data=100880`，
  0 error、0 warning，HEX SHA-256为
  `4E5403FA8A1B486096A334BDC384F4FD4AF1A18944C44BA7E960F0995448B4CF`。
- 队友生产配置构建为`Code=77236, RO-data=48564, RW-data=176, ZI-data=92688`，
  0 error、0 warning。
- 更新包为`deliverables/V2.7更新包.zip`，SHA-256为
  `13E9C5F4B99F2406C28CDF61D67B16117D29F7BFFF85556DCB5B1445248159E2`。

## 2026-08-01: V2.8单一幅相解析基线

- 用户最终决定废弃旧普通/Huber路径；桥接与显示源码删除模式枚举、切换API、
  Huber/Mpp计算及HMI 0x08/0x09状态机，不再用“固定开关值”模拟单一模式。
- 时域桥接槽由256提高到512，并接受512至8192点理论输入，兼容队友当前4096点
  与后续8192点升级。
- 偶发整图横移的根因是复合波形相近正峰互换后触发搜索跳到另一过零点；触发
  改为固定基波相位0、1/4、1/2周期。
- 测试配置构建`Code=67844, RO-data=81932, RW-data=172, ZI-data=78948`，HEX
  SHA-256为`F7F187119C06B1D7BCF1CBCD8D6256C220B910F9F68F5856E52EB90985D92B8B`；
  生产配置`Code=66996, RO-data=48508, RW-data=164, ZI-data=76836`。两者均
  0 error、0 warning，V2.8尚未烧录。
- 已按用户重新放回的`teammate/last/Core/Src/main.c`重写V2.8交接书：明确说明
  `main.c`本身没有旧模式分支，旧模式由4个桥接/显示文件覆盖删除；另给出
  `getup()`与主循环发布段两处完整替换代码，并固定KEY1长按刷新。
- 前置空载噪声会被FFT固定峰数和`getup()`合成为正弦；桥接新增
  `AnalyzerBridge_PublishNoSignal()`主动发布全0有效快照，避免无效帧被拒绝后
  屏幕继续保留旧波形。交接书给出第一次FFT后、Goertzel前的4.77 mVpk初始门控；
  门限仍须按实测噪声上界标定。本地Keil构建0 error、0 warning。
- 交接包不覆盖队友主程序，ZIP逐文件哈希校验通过，最新SHA-256为
  `42176CA29129C63A70B010C92B58F600535F71485F38A2A05C8363E0E977E565`。
- 已生成`deliverables/V2.8.1无信号与单频增量包.zip`：只覆盖2个桥接文件，
  `main.c`用说明书手工增加FFT内0/1/2/3分类、单频`getup()`和无信号发布分支。
  本地Keil构建`Code=68676, RO-data=81932, RW-data=172, ZI-data=78948`，0 error、
  0 warning；HEX SHA-256为`5EEC7DE117514C56DCA4634A4268E93698573381D5223735D13C8A317A2A3133`。
  增量ZIP逐文件校验通过，SHA-256为
  `9F200E86FDDB03843F7A6A75D51F31C5D81261FF5DD4BDB9A41C629927EC242B`。
- 已生成`docs/05_report/显示部分V3.docx`，只替换官方模板第2章和3.2.2中的显示
  增量；另生成`deliverables/V2.8_周期信号时域图像复原方法数学说明.docx`。
  两文档分别含7和15个可编辑Word公式，逐页渲染10页和3页均无截断或溢出。

## 2026-08-01: ADC部分V2报告

- 以`docs/05_report/显示部分V3.docx`为模板，仅替换第2章项目理论块和3.2.2第一项，
  生成`docs/05_report/ADC部分V2.docx`，未改动报告其余模板内容。
- 第2章用L路、B位、N点、Fs、K个分量和R个邻域频点建立通式，覆盖交错时间戳、
  ADC吞吐、码值换算、通道失配、DFT、幅值、有效值、Goertzel、相对相位、解析
  重建和整数周期有效长度，共式2-1至式2-13。
- 第3章逐项映射`teammate/last`：ADC1/PA0上升沿、ADC2/PA1下降沿、每路2048点、
  VO[4096]交错、2.048193 MS/s、DMA1通道1/2、4096点CFFT、前后各4点能量和、
  Goertzel、Vpp_R()与getup()；同时记录2048193 Hz和2048000 Hz必须统一。
- Word结构校验为178段、1节、0表格、14个原生OMML公式；11页逐页渲染无截断、
  重叠或公式越界，页眉页脚及节结构与显示V3模板一致。

## 2026-08-01: B26244_3八页主报告融合

- 以`docs/05_report/B26244_3.docx`为唯一主报告，在不增加物理页数的前提下，
  原位替换摘要、ADC方案、第2章采样与幅相算法、第3章软件链路；正文仍为8页。
- ADC内容统一为TIM3双边沿触发、两路DMA各2048点、交错形成4096点、约
  2.048193 MS/s、FFT邻域能量估幅和Goertzel相位；显示内容对应V2.8单一幅相
  解析链路、4096点理论波形、512点桥接以及1T/3T绘制。
- 未修改硬件理论与电路主体、4幅原图、器件参数、测试表、测试结果、结论和参考
  文献；删除页眉中的“AI生成”水印。最终结构为78段、1表、4图、9个原生OMML
  公式，Word与PDF均验证为8页，8页逐页渲染无截断、重叠或溢出。
## 2026-09-20：赛果确认与最终代码定位

- 官方获奖名单确认：参赛编号`B26244`、G题、北京交通大学，获二等奖（省级）；证据位于获奖名单`Sheet1`第142行。
- 最终现场代码真源确定为仓库`teammate\24`；外部`24`只作原始备份，原包`24.zip`的SHA-256为`9E21EB8435983B9AC42F2F062F7BB256D01035A653957155E30D31DDC83213E5`。
- 仓库`teammate\24`与外部`24`的346个文件、56,045,062字节逐文件SHA-256一致；`teammate\current`与`teammate\last`一致，但早于最终`24`。
- `firmware/`定位为后续整理开发主线；它与最终`24`共用相同桥接/显示实现，但`main.c`不同，不能视作最终比赛包的逐字副本。
- Git远端最新正式标签仍为`v2.6.0`；本地存在领先提交和未提交改动，赛后发布整理尚未完成。
