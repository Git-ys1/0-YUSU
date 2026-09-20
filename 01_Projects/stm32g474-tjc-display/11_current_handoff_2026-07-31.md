# 2026-07-31当前永久交接

> 2026-08-01 V2.7覆盖说明：用户指定的队友最终版已原样提升为
> `teammate/current`；正式融合主线仍是`firmware/`。V2.7测试版已完成SWD下载、
> 校验和复位，但尚未完成实物功能验收，也未提交或发布。下文V2.6及更早内容仅作历史解释，冲突时以
> 本节和仓库`docs/06_handoff/README.md`为准。

## V2.7当前唯一未发布工作区

- 队友最终算法所有权：981点相位表、两次4096点FFT、Goertzel相位、`Vpp_R()`、
  `getup()`理论Upp和第二次FFT有效值`Vr`。
- 我方显示所有权：`AnalyzerBridge`、淘晶驰协议、1T/3T、动态曲线ID、结果文本、
  KEY1本地测试和立即刷新。
- `getup()`现在保存一个基波周期的4096点理论值；桥接层直接取同一数组显示，
  不再运行旧普通/Huber折叠、独立Mpp或鲁棒Vpp。
- `sw_model`固定为1，旧模式与Huber控制帧被MCU拒绝；手动刷新在页面ID有效时
  直接画最新结果。
- 正式本地测试构建0 error、0 warning，HEX SHA-256为
  `C2E7E1A525DDAFE8CBBCA92614FAD0A02955D6881E170D530704C16FC50E4E0F`。
- 队友交接包为`deliverables/V2.7更新包.zip`，SHA-256为
  `E61DDEBCE5075D591A7C45799759691A91350FDE0A514C88A21E2E2C5EEA3F8F`；只允许覆盖
  桥接/显示四文件并按摘要手工改`main.c`三处。包内随机测试关闭，队友KEY1
  长按刷新保持不变。

> 2026-08-01 V2.6覆盖说明：当前已发布基线是`v2.6.0`、提交`4894940`，队友
> 底座是原`teammate/win`、现`teammate/current`。下文V2.5及更早内容只用于
> 解释历史；发生冲突时以本节和仓库`docs/06_handoff/README.md`为准。

## V2.6当前唯一基线与未发布工作区

- 双ADC各2048点交错为`VO[4096]`不变；队友Goertzel初相位已经进入正式解析链，
  公式按谐波阶数在4096相位点求Upp。
- 原`getup()`的同频/Hz索引错误已修正；`Vpp_Robust()`运行调用已停用。
- 发布HEX SHA-256为
  `12550422C8989B88B920995E7D5B5D742B77030F58DC761D79F30B2C5B64C53D`，已烧录验证。
- 当前另有未发布`sw_model`工作区：0旧折叠、1新幅相解析；新模式时`sw_huber`
  无效。构建0 error、0 warning，但HMI尚未加入，所以未烧录。
- 解析模型可直接复原曲线，但前端相位函数仍为0；相位折叠/Huber必须保留为
  原始证据、残差校验和回退，不能因曲线更平滑就删除。
- ADC报告初版位于`docs/05_report/ADC部分V1.docx`，只新增理论和一个ADC模块，
  11页版式已逐页检查。

> 2026-08-01 V2.5覆盖说明：当前发布基线已经更新为`v2.5.0`、提交`d40eb01`。
> 下文V2.4及更早内容只用于解释历史；发生冲突时以本节和仓库
> `docs/06_handoff/README.md`为准。

## V2.5当前唯一基线

- 正式主线仍是`firmware/`；队友取证底座已经更新为`teammate/current/`中的
  `4096-2`，不得再从旧单ADC/2048点代码重新融合。
- 当前采集为ADC1/PA0上升沿与ADC2/PA1下降沿各2048点，交错为单位V的
  `VO[4096]`；桥接接口不再接收原始ADC码。
- 必须在会原地修改VO的`Vpp_R()`之前调用`AnalyzerBridge_PrepareReal()`，在
  Vpp/RMS得到后调用`AnalyzerBridge_PublishPreparedReal()`；这是数据所有权边界，
  不是可交换的显示调用顺序。
- 队友交接使用`deliverables/V2.5更新包.zip`，包内不含`main.c`；按摘要手工接入
  四处即可。队友生产版测试宏为0、KEY1长按刷新；我方`firmware/`长按测试。
- 代码链说明位于
  `docs/02_integration/TEAMMATE_4096_2_CODE_CHAIN_AND_IMPLEMENTATION_NOTES.md`；
  实测前继续把`Vpp_Robust()`视为未验证、可后续替换的队友函数。
- V2.5主线构建和烧录均成功，HEX SHA-256为
  `CEFA87F1953CEDE198AE476043E0E169BF66CAD7D808335D8B1743A545DB86C2`；
  Release为`https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.5.0`。

## 当前唯一基线

代码仓库实际Git根是`F:\Project\stm32G474VETx\TI`，正式子工作区是
`G_Periodic_Signal_Analyzer`，远端为
`Git-ys1/STM32G474-Periodic-Signal-Analyzer`。当前发布基线是标签
`v2.4.0`、提交`554cdcb`；权威编译与烧录工程为
`firmware/`。它以`teammate/current/`保存的ADC1/Goertzel队友版本为底座，叠加用户
`analyzer_bridge.c/.h`、`display.c/.h`、USART3和KEY1。后续不得从
`archive/firmware/tjc_display_demo/`、V1.4、V1.8、旧任务书或旧`main.c`
重新融合。旧`projects/`目录已在V2.3移除。

V2.1.0在V2.0.0相位锚基础上增加PC端两遍Huber鲁棒折叠量化验证，以及默认
关闭的STM32普通/Huber状态开关`A5 02 08 enabled 5A`。发布构建为
`Code=68532, ZI-data=63068`、零错误零警告；`ADC.hex` SHA-256为
`FA1CC4CCB29C1B29C0832A31970DCF5C91CCF823962DA71FF4A04902F8252600`，
已完成烧录和板上普通→Huber→普通无故障冒烟。GitHub Release：
`https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.1.0`。
真实HMI开关和真实ADC毛刺A/B仍待用户测试，不得把人工污染改善率当作实机结论。

V2.2真实ADC平滑方案已由用户确认定版，并与V2.3工作区分层统一发布为
`v2.3.0`。输入为`tests/三组实际ADC数据.xlsx`中的三组2048点原生ADC。严格重放
当前FFT、频率细化、普通/Huber折叠、触发和794点显示后，选定
“两遍Huber + FFT已识别整数谐波正交投影”。三组合法次数为
`{1,8}`、`{1,3,4}`、`{1,2,7}`，折返点由Huber的138/138/124降为
16/6/14，与独立原始ADC稳健拟合参考一致；相位RMSE为
0.150/0.070/0.118 mV。

V2.2定版构建为`Code=69652, RO-data=59000, RW-data=52, ZI-data=63060`、
0 error、0 warning；`ADC.hex`长度362077 bytes，SHA-256为
`C4F6BADEAB9B45F0CFB7C5F50FF58912CC9A4C2C64259FA14DBC5991C9A2DCCB`。
固件已通过SWD下载、校验和复位；HOTPLUG中序号1.5秒增加16，CFSR/HFSR为0。
HMI协议不变：`A5 02 08 00 5A`是普通，`A5 02 08 01 5A`现在是
“Huber + 已识别谐波投影”。用户确认效果定版后，上电默认增强Huber。

V2.3.0 GitHub Release：
`https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.3.0`。
Release包含`ADC.hex`、队友生产融合ZIP和波形复原数学说明DOCX；HEX SHA-256
为`C4F6BADEAB9B45F0CFB7C5F50FF58912CC9A4C2C64259FA14DBC5991C9A2DCCB`，
队友ZIP SHA-256为
`5A7C489F4D86C43032D8C95105972F1737A6417E8504C73FC72C55EFE5BF496D`。

V2.4.0增加独立模型峰峰值`Mpp`，不替换队友`Upp`且未修改`main.c`。
`AnalyzerBridge_CalculateRobustModelVpp()`直接拟合全部2048点的DC与FFT筛出的
最多三路整数次谐波，执行3轮Huber IRLS，并在4096相位点求峰峰值；真实ADC按
前端总增益6折回输入端。HMI对象名为`t_vpp2`。V2.4.0还发布512×256时域、
256×256频谱、动态实际坐标和`sw_period`主循环回写。合成验证和Keil构建已
通过，提交、标签、HEX和GitHub Release均已发布；尚未烧录和取得真实三方证据。
完整证据在
`docs/03_validation/MODEL_VPP_2048_VALIDATION_2026-07-31.md`。

V2.4.0 GitHub Release：
`https://github.com/Git-ys1/STM32G474-Periodic-Signal-Analyzer/releases/tag/v2.4.0`。
发布HEX为379480 bytes，SHA-256为
`A011FD6699D7452C4200FCE385C3BB4FE2C718503CBBEE252B1D41E6A1B2D252`。

不可触摸屏现场已经恢复KEY1长按测试，并通过ST-Link把当前运行态置为增强
Huber。连续回读T108/T107/T105/T108四个`s_test_result.waveform_mv[256]`，
模型外RMSE仅0.00000344～0.00001111 mV，折返点均为2，证明Cortex-M4内部
输出已经数学光滑。若屏幕仍有小峰谷，下一步查512点映射、像素量化或刷新
残影。T108名义55 mVpk只恢复44.91 mVpk，仍需把低覆盖幅值失真与平滑度分开。

完整交接文档位于：

```text
F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer
\docs\06_handoff\README.md
```

给新会话直接执行的一页式任务书位于：

```text
F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer
\docs\06_handoff\09_NEXT_AGENT_TASK_BRIEF.md
```

它下辖赛题材料、工作区、职责、硬件、软件架构、故障史、当前问题和构建烧录
手册。任何新会话必须先读完整交接包，再读`git status`和实际源码。

## 项目与职责

项目是2026电赛G题周期信号测量分析装置。队友负责STM32G474底座、ADC1 PA0、
TIM3 TRGO、DMA1 Channel 1、2048点采集、CMSIS-DSP FFT、Vpp/RMS和
Goertzel。用户负责淘晶驰X2 7英寸800×480屏幕、dashboard单页HMI、USART3
PC10/PC11、FE/FD透传、实体KEY1、结果桥接、相位折叠、时域/频谱绘图、融合和
Git验证。模拟前端的精确原理图/BOM尚未在仓库确认，不能用早期AD8367测试表
代替。

当前数据链为：

```text
TIM3 → ADC1/PA0 → DMA adc_b[2048]
→ adc码×3.3/4096 → VO
→ 队友fft()并立即快照F/V、FB/VB、FC/VC
→ Vpp_Robust()与Vpp_R()
→ AnalyzerBridge_PublishReal()
├─ 2048点Huber谐波模型 → 4096点峰峰值 → /6 → t_vpp2
→ ±500 Hz相关搜索细化折叠频率
→ 2048点折叠到一个周期256槽
→ 状态1执行Huber和FFT已识别整数谐波投影
→ AnalyzerResult静态快照
→ Display_Task()
→ 256到512点时域、256点频谱、动态坐标和定点文本
→ cle/addt + FE/FD
→ USART3 → dashboard
```

Goertzel三路当前只计算未消费。频谱文本仍使用队友第一次FFT快照。测试模式使用
Python预生成ADC数组走同一波形折叠，但Vpp/RMS/谱峰元数据使用理想值，因此只
验证显示，不验证队友测量算法。

## 当前硬件与交互

屏幕实物因商家发错为不可触摸版本，但保留HMI虚拟按钮协议。页面名
`dashboard`，V2.4目标曲线`s_time=512×256`、`s_spec=256×256`、通道0。页面后初始化动态发送：

```text
A5 20 01 time_id spec_id 5A
```

不能恢复旧双页面固定`time=11/spectrum=1`。按钮命令为`01` 1T、`02`刷新真实、
`03` 3T、`04`测试、`05`清除、`06`停止。KEY1为PB8/BOOT0，高电平有效、上升沿
中断。V1.9曾使用短按切换1T/3T、长按刷新真实ADC；2026-07-31用户因现场屏
不可触摸，已明确要求本地V2.2验证工程恢复为短按切换1T/3T、长按
`Display_RequestTest()`进入随机测试。发给队友的生产融合包则保持短按
1T/3T、长按`Display_RequestRefresh()`，并把`ANALYZER_TEST_ENABLE`设为0，
不携带随机测试数组。用户已经确认Huber效果定版，当前源码和队友包上电默认
增强Huber，不再依赖ST-Link RAM置位。

## 已冻结的高价值修复

- dashboard动态上报两条真实曲线ID；
- `addt → FE → 512或256字节 → FD`完整握手；
- USART3单字节中断接收和ORE恢复；
- `AnalyzerResult`与大缓冲静态存储，避免1KB主栈溢出；
- ArmClang保留`__ARM_use_no_argv`，避免启动`BKPT 0xAB`；
- 第一次FFT结果在`Vpp_R()`第二次FFT前快照；
- 时域和频谱分别做淘晶驰水平反向补偿；
- 频谱横轴使用完整256像素，0和500kHz对应左右端；
- HMI与实体KEY共用`Display_ProcessButtonCommand()`；
- newlib-nano不依赖浮点printf，文本使用定点整数格式；
- 页面/曲线局部失败不应阻断独立测量文本。

任何队友新版本融合都要逐项交叉对照这些修复。

## 真实ADC当前结论

用户基于多次实测确认：信号发生器与ADC引脚示波器Vpp通常差不到5mV，但
示波器与屏幕Upp经常差超过10mV。不能再用单张截图得出“模拟前端固定放大”的
结论。显示层只透传`AnalyzerResult.vpp_mv`，所以当前P0是同步保存信号源、
PA0示波器、`adc_b[2048]`和屏幕结果，实测VDDA，并离线拆分码值换算、采样相位、
`Vpp_Robust()`和桥接的误差。

V2.4已经提供独立输入端`Mpp`，当前P0可直接升级为同屏比较信号源/示波器、
队友`Upp`和模型`Mpp`。必须确认队友新增增益宏与桥接各自只除以6一次；若仍有
偏差，必须保存同帧`adc_b[2048]`、VDDA、采样率和FFT三路频率，不得只凭截图。

HMI布局已经按用户最终选择冻结：`s_time=(16,17,512,256)`、
`s_spec=(544,17,256,256)`；1T/3T合并为`sw_period`并复用旧按钮帧。动态纵轴
使用透明普通文本显示实际mV，时域横轴用`vvs1=1`虚拟浮点显示us，频谱横轴
固定0～500 kHz。固件已同步这些对象；用户仍需亲自保存HMI并归档源文件。

纯正弦出现第二峰时，优先审计队友FFT固定至少寻找两峰、缺少第二峰存在性阈值和
谐波整数倍验证；同时用示波器FFT/原始ADC判断模拟链是否真的存在谐波。时域毛刺
已用三组原始数组证明主要表现为模型外相位槽抖动，V2.2投影可离线消除；仍需
屏幕同信号A/B确认。V2.0已经用上升/下降过零、正峰或关闭触发解决相位锚，
不得再按旧结论认为“无基波相位锚”。

离线实验已经证明精确256kHz等低分母锁频场景可能只有4个真实相位，增加槽数和
高阶插值不能创造信息；频率误估又可能让计算覆盖率虚高。因此正式自适应策略必须
联合独立相位数、覆盖率、最大空洞、频率稳定性和模型残差。谐波投影已成为
V2.2状态1实现，但必须在谱峰可信且残差合格时使用；如果FFT漏峰或把噪声
误识别成合法整数谐波，平滑后的外观不能当作测量正确证据。

## 下一次开场

先读根目录`README.md`确认V2.4发布基线，再读`docs/06_handoff/README.md`。正式
固件只从`firmware/`构建，队友当前底座只从`teammate/current/`取证，历史屏幕
演示只在`archive/`查阅。V2.2平滑显示已经由用户确认定版。队友已经融合上一份
V2.2生产包后，V2.4预交接只使用`deliverables/V2.4更新包.zip`：覆盖
`analyzer_bridge.c/.h`和`display.c`，不替换`display.h`或`main.c`。包内测试宏为0，
队友KEY1长按仍刷新真实ADC。该生产配置已0 error、0 warning重建；队友新工程
到达后仍以其完整工程为底座做三文件冲突对比。下一轮优先继续取得同步的信号源、
PA0示波器、ADC数组和屏幕`Upp/Mpp`证据，先验证桥接模型与除6口径，再确定
超过10mV误差的主因。构建固定使用
`D:\Work\Keil5\UV4\UV4.exe`，烧录固定使用
`F:\AcademicHub\STMicroelectronics\stm32cubeprogrammer\bin
\STM32_Programmer_CLI.exe`，禁止再次全盘搜索工具。

淘晶驰官方46页指令集已转为
`docs/01_architecture/tjc_official_reference/TJC_HMI_INSTRUCTION_SET.md`；后续查询
`addt`、返回码、系统变量、CRC或下载协议时优先检索该Markdown，版面歧义再回看
同目录的官方PDF，不必重复查询官网。
