# 项目阶段总结：STM32G474周期信号分析显示融合

更新时间：2026-09-20
阶段：比赛结束，获北京市二等奖（省级）；最终代码已定位，Git赛后发布整理尚未完成

## One-Page Summary

本项目在四天高强度迭代中把独立淘晶驰显示演示和队友的STM32G474采集分析工程
融合为周期信号测量分析装置。最终链使用双ADC各2048点交错形成4096点，经过FFT、
Goertzel相位、前端相位补偿和解析波形复原，向屏幕发布Upp、Vr、最多三个频谱
分量和512点时域曲线。项目经历了普通相位折叠、Huber、谐波投影、新旧模式等路线，
最后只保留幅相解析复原，并为无信号和单频建立显式状态。

比赛现场最终工程是仓库`teammate/24`。它与资料目录原始`24`的346个文件、
56,045,062字节逐文件SHA-256完全一致。`firmware`是赛前重构开发工作区，
`teammate/current/last`是较早队友底座，均不能替代最终真源。官方名单确认B26244、
G题、北京交通大学获二等奖，按省级二等奖结题。

## Most Important Things

| 排名 | 最重要事项 | 结论 | 证据 |
|---:|---|---|---|
| 1 | 最终源码真源 | `teammate/24`是唯一最终比赛源码，外部`24`仅作原始备份 | `FINAL_COMPETITION_SOURCE.md`、全树哈希 |
| 2 | 正确融合边界 | 以采集算法完整工程为底座，通过桥接接显示，不能拼两个`main.c` | `v1.4.0`、ADR 2026-07-30 |
| 3 | 最终算法路线 | 只保留幅相解析复原，废弃普通/Huber和新旧模式 | V2.8、ADR 2026-08-01 |
| 4 | 实时系统稳定性 | 栈、共享FFT缓冲、UART ORE和中断分工比单个公式更易造成致命故障 | `05_known_issues.md` |
| 5 | 无信号语义 | 无信号必须发布全零有效帧，单频必须是独立状态 | 最终桥接头源文件、V2.8.1记录 |
| 6 | 证据方法 | 构建、烧录和实屏结论必须绑定日志、HEX哈希、关键变量和输入条件 | `02_runbook.md`、`09_session_evidence.md` |
| 7 | 最终成果 | 官方名单确认省二等奖，正式报告和源码均已冻结定位 | 获奖名单第142行、`docs/05_report/final` |

## Final Shape

- 最终硬件链：TIM3双边沿触发ADC1/ADC2，各2048点DMA，交错为`VO[4096]`。
- 最终算法链：FFT识别幅值、Goertzel求相位、相位表补偿、`getup()`解析复原、
  `Vpp_R()`第二次FFT形成Vr和最终频谱。
- 最终软件边界：`main.c`拥有采集分析，`AnalyzerBridge`发布静态快照，
  `Display_Task`拥有HMI状态和USART3输出。
- 最终显示：512点时域、256点频谱、1T/3T、动态刻度、触发锚点和KEY1控制。
- 最终归档：代码在项目仓库，正式报告在`docs/05_report/final`，外部目录保存赛题、
  名单、HMI资料和原始`24`备份。

## Hard-Won Lessons

1. 多工程融合必须先确定外设所有权和完整底座，再设计数据契约。
2. 指针、点数、元素类型和单位要同时一致；任一错位都能生成“看似合理”的错误波形。
3. 相位折叠不是通用复原方案，低分母共振与频率误差会造成不可由平滑修复的信息缺口。
4. 大型局部结果结构、半主机BKPT、UART ORE和共享FFT覆盖都需要用调试器看运行事实。
5. 稀疏解析模型必须配合无信号门控、分量分类和原始数据证据，不能只追求平滑画面。
6. 报告公式、PC仿真和实物标定是三种不同证据，不能互相替代。
7. 比赛最后一天的现场工程可能晚于最后Git标签，赛后必须重新做文件树取证。

## Rules For Future Codex

- 新会话先读`00_project_brief.md`和仓库`FINAL_COMPETITION_SOURCE.md`。
- 复现实赛只从`teammate/24`复制，禁止在冻结真源内直接开发。
- 不把`firmware`、`current`、`last`或远端`v2.6.0`称为最终现场版本。
- 不自动烧录；先确认板卡、接线、输入安全范围和用户授权。
- 不用画面形状推断幅值正确性；测量结论必须绑定同帧ADC与外部参考。
- 不恢复已废弃的普通/Huber和新旧模式，除非新的研究目标明确要求。
- 整理当前脏工作树时按主题分批审计，不执行盲目全量提交。

## Remaining Risks

- Git工作树仍含大量赛末未提交变更，远端发布状态落后于最终现场工程。
- 前端完整复频响、双ADC增益/偏置/时间差和模型残差没有形成完整公开数据集。
- 最终`24`自带构建产物可用于取证，但赛后尚未在干净临时目录重新构建复现。
- 外部资料目录仍保留一份完整`24`，当前作为原始证据；未来删除需单独授权。
- 旧交接和状态文档含有赛前“待烧录/待验证”措辞，阅读时必须服从赛后覆盖说明。

## 2026-09-20 赛后结论

- 官方名单确认`B26244`、G题、北京交通大学获二等奖（省级）。
- 现场最终代码真源为仓库`teammate\24`；外部`24`与其346个文件逐文件一致，只作原始备份。
- `firmware/`是赛前开发工作区而非最终比赛包的逐字副本；V2.8状态记录继续保留，仅作为开发历史。
- 详细定位和恢复顺序见[[12_final_result_and_code_locations_2026-09-20]]。

## 2026-08-01 V2.8覆盖结论

- `teammate/last`是本轮队友重新提供的原始基线，`firmware/`是唯一融合与构建主线。
- 固定幅相解析模式：队友`getup()`同一组4096点理论值同时作为Upp和时域图，
  Urms采用第二次FFT得到的`Vr`。
- 旧普通/Huber折叠、Mpp、两组模式枚举/API及0x08/0x09已从源码删除。
- 复合波形触发改为固定基波解析相位锚点，消除相近正峰换峰导致的整图横移。
- 本地测试版与生产版均0 error、0 warning；V2.8尚未烧录、提交或发布。
- V2.8生产交接包只覆盖桥接/显示四文件，不覆盖队友`main.c`；交接书按
  `teammate/last/main.c`的真实锚点给出`getup()`和主循环发布段完整替换代码，不能
  再用抽象“核对项”代替可执行步骤。数学说明和显示V3统一用N/M/P/K描述点数与
  分量数，后续提高理论点数不再改显示协议或报告推导。

## 赛前V2.8历史结论

以下内容描述2026-08-01赛前工作区，不覆盖赛后最终源码定位。当时项目从“独立显示
演示 + 独立信号处理代码”进入可烧录的融合阶段，开发基线位于：

```text
F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer
\firmware
```

主链路为：

```text
ADC1/PA0上升沿 + ADC2/PA1下降沿，各2048点
→ 交错为VO[4096]浮点电压
→ 4096点FFT幅值 + Goertzel分量相位
→ 前端幅相校正入口 + 相对谐波初相差
→ 4096相位点解析Upp（Vpp_Robust停用）
→ getup理论曲线立即登记
→ AnalyzerBridge_PrepareReal、PublishPreparedReal形成512点稳定快照
→ 固定基波解析相位锚点
→ Display_Task
→ USART3
→ 淘晶驰dashboard
```

## 七条最重要经验

1. 融合应以外设和算法更完整的一侧为底座，通过结果桥接层接显示，不能拼两个`main.c`。
2. 多个处理函数共享FFT全局输出时，必须在覆盖发生前立即快照。
3. 高计算负载下UART短帧接收不能只靠主循环轮询；接收中断与主循环绘图应分工。
4. 嵌入式大结果结构体必须先对照Map和启动栈大小；1084字节对象不能进入1024字节主栈。
5. “屏幕无图”只是表象，ST-Link应依次检查CPU模式、Fault栈、Map、UART寄存器和模块状态。
6. 多种输入设备触发同一业务动作时，必须汇入同一命令处理入口；实体键不应复制触摸按钮后的绘图和状态逻辑。
7. 数字滤波发生在ADC之后，不能替代输入保护、偏置、低阻驱动和模拟抗混叠；采样率改变时滤波器必须按实际频率重新设计。

## 已冻结部分

- dashboard 6字节初始化帧和既有按钮帧；
- 两条曲线动态数字ID；
- `cle/addt → FE → data → FD`握手；
- 1T/3T时域重采样、512/256曲线、动态实际坐标和定点文本格式；
- USART3中断接收、主循环绘图；
- `AnalyzerResult`统一接口和静态快照。
- KEY1与HMI按钮共用`Display_ProcessButtonCommand()`；短按切换1T/3T，长按执行测试。

## 后续重点

- 真实模拟前端增益、偏置和频响标定；
- 500 Hz频率分辨率和实际采样率校准；
- 基频/谐波识别边界；
- 1 MHz以上干扰抑制；
- 正式实体屏和2秒响应时间回归。

## 2026-07-31补充：离线波形验证入口

- 自定义测试统一由`tools/custom_waveform_lab.py`生成2048点ADC码、相位折叠对比和固件头文件。
- 相位覆盖统一由`tools/analyze_phase_coverage.py`检查，不能再用每50 kHz抽查代替精确有理共振枚举。
- 当前256相位槽到512列继续线性插值；低覆盖的根因在采样信息，不在屏幕像素数。

## 2026-07-31补充：V2.4.0显示与幅值审计

- 发布基线为`v2.4.0 / 554cdcb`，时域512×256、频谱256×256。
- 时域Y轴按独立`Mpp`显示输入端实际mV，时域X轴按频率和1T/3T显示us；频谱Y轴
  使用队友FFT幅度，频谱X轴固定0～500 kHz。
- 周期开关外观由MCU主循环回写，页面初始化仍保持原三帧；这延续“ISR只记事件、
  主循环做阻塞I/O”的既有规则。
- 代码、构建、标签和HEX已发布；HMI专有源文件与实屏三方幅值证据仍待用户补齐。

## 2026-07-31补充：三组真实ADC平滑结论

- 权威输入为`tests/三组实际ADC数据.xlsx`，每组2048点原生ADC码。
- 普通折叠和Huber在斜坡上仍产生大量额外折返点；周期Savitzky-Golay只能
  折中削弱抖动，并会影响真实高次谐波。
- G题信号被限定为基波加至多两种谐波，因此V2.2选择“Huber + 队友FFT已识别
  整数谐波正交投影”。三组折返点由Huber的138/138/124降为16/6/14，
  与独立原始ADC稳健谐波拟合参考一致。
- PC相位RMSE为0.150/0.070/0.118 mV；MCU float32递推与双精度投影最大差异
  0.000261 mV。
- 该固件已0 error、0 warning构建并SWD烧录，运行态序号递增且CFSR/HFSR为0；
  尚未提交或发布，下一步是屏幕普通/增强Huber同信号A/B。

## Evidence

- `docs/04_releases/V1.4_FUSION_BASELINE_FREEZE_2026-07-30.md`
- `docs/99_archive/V1.4_INTEGRATION_ARCHITECTURE.md`
- `docs/03_validation/SCREEN_TEST_GUIDE.md`
- `firmware/Core/Src/main.c`
- `firmware/Core/Src/analyzer_bridge.c`
- `firmware/Core/Src/display.c`
- `deliverables/V2.8更新包.zip`
- `deliverables/V2.8_周期信号时域图像复原方法数学说明.docx`
- `docs/05_report/显示部分V3.docx`
- `docs/05_report/ADC部分V2.docx`
- `docs/05_report/B26244_3.docx`
- `docs/05_report/figures/01_软件总体流程图.vsdx`
- [[../../03_CrossProject/stm32-stlink-runtime-debugging]]
- `docs/04_releases/V1.4.1_KEY1_RELEASE_2026-07-30.md`

## Memory Routing Audit

| Candidate Lesson | Route | Target | Action | Evidence |
|---|---|---|---|---|
| 最终比赛源码与资料目录必须明确真源，且在迁移前做全树哈希比较 | project-only | `12_final_result_and_code_locations_2026-09-20.md`与仓库冻结说明 | written | 两个`24`均346文件、56,045,062字节、差异0；该结论只针对本项目目录角色 |
| 项目比赛结果和完成状态需要进入项目地图 | map only | `06_Maps/project-map.md`与`01_Projects/README.md` | updated | 官方名单第142行确认省二等奖，项目状态改为completed |
| 最终现场包可能晚于最后Git标签，结题应重新核验源码树和产物哈希 | cross-project pattern | 暂不提升，保留本项目证据 | rejected | 当前只有本项目一次明确案例，不足以修改其他项目或全局规则 |
| KEY1与HMI按钮必须共用业务命令入口 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | 独立按键显示逻辑造成错误曲线；复用原按钮命令后实物验收通过 |
| EXTI只记录事件，阻塞式UART和绘图留在主循环 | project-only | `03_decisions.md` | written | V1.4.1 KEY1短按/长按实现 |
| 固件发布必须同时记录构建体积、HEX哈希、烧录校验和实物结论 | project-only | `04_progress.md` | written | V1.4.1发布证据 |
| 十进制均匀扫描不能替代采样率有理共振枚举 | cross-project pattern | `03_CrossProject/patterns.md`与`06_Maps/topic-map.md` | written | 100/10/1 Hz网格均漏掉q=3、7、9、11；混合扫描捕获Fs/3等最差点 |
| 自定义波形必须输出真实ADC码并复用固件真实波形链路 | project-only | `03_decisions.md` | written | `custom_waveform_lab.py`与`generated_custom_adc_tests.h` |
| 估计频率推导的覆盖率不能单独证明重建可靠 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | 精确256 kHz误估100 Hz时覆盖率82.03%但折叠RMSE 27.33 mV |
| 淘晶驰整帧时域与频谱都要补偿横向写入方向 | project-only | `03_decisions.md` | written | T102理想曲线和屏幕曲线满足`x -> 1-x`，时域反向写缓冲后修复 |
| Huber折叠只能作为默认关闭的真实ADC毛刺A/B手段，不能替代相位覆盖与采集质量检查 | project-only | `11_current_handoff_2026-07-31.md` | updated | v2.1.0的72组PC对照、低覆盖失败边界、板上普通到Huber往返冒烟 |
| 对G题已知稀疏谐波模型，Huber后优先投影到FFT已识别整数谐波，不使用宽窗口通用平滑 | project-only | `11_current_handoff_2026-07-31.md` | updated | 三组真实ADC的折返点、参考RMSE、float32一致性和V2.2烧录证据 |
| 不可触摸屏的KEY1具体长按动作服从现场需求，但必须始终复用HMI命令入口 | project-only | `03_decisions.md`与`11_current_handoff_2026-07-31.md` | updated | V2.2长按测试重新烧录、s_test_override和自动换组RAM证据 |
| 唯一固件主线、队友快照、历史工程必须分层，维护层级README用表格列全直接子项 | project-only | `03_decisions.md`与`11_current_handoff_2026-07-31.md` | updated | V2.3迁移613个追踪工程文件无丢失、真实断链0、Keil构建哈希不变 |
| 全2048点模型Vpp与256槽显示链分离，前端增益只折算一次 | project-only | `03_decisions.md`与`04_progress.md` | written | V2.4 Huber IRLS、4096点求峰峰值、6倍前端合成验证与Keil栈审计 |
| 实时仪表盘不应为三行结果引入持久化数据记录控件 | project-only | `04_progress.md`与`06_todo_next.md` | kept | 淘晶驰数据记录依赖全局`.data`及方法调用；普通文本/数值控件更匹配本项目 |
| 动态HMI坐标只需局部对象名，跨输入状态由MCU主循环回写 | project-only | `03_decisions.md`与`04_progress.md` | written | V2.4的`n_ty*`、`n_sy*`、`x_tx*`与`sw_period`实现及零警告构建 |
| 已融合旧包后的队友更新应只交付真实变化模块并明确禁止覆盖`main.c` | project-only | `04_progress.md`、`06_todo_next.md`与`11_current_handoff_2026-07-31.md` | written | V2.4增量包仅3个文件，生产宏关闭并独立零警告构建 |
| 官方HMI指令资料应保留原PDF并同步生成可检索Markdown | project-only | `04_progress.md`与`11_current_handoff_2026-07-31.md` | written | 46页PDF抽取为48条对象指令、10条GUI指令、30个系统变量和31类返回帧 |
| 设计报告增量内容必须从官方模板复制并用原生OMML公式，且剔除新增段落后审计模板原文与格式 | project-only | `04_progress.md`与仓库`docs/05_report/` | written | 2026-08-01模板初稿：现代兼容模式15下关闭重开仍有7个可编辑公式、理论部分2页、原有145段及媒体/页眉页脚一致 |
| 数字滤波不能替代ADC前的保护、偏置、驱动和抗混叠 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | F103示例无ADC/DMA；4.096 MS/s下该FIR约691 kHz到-3 dB且1 MHz约衰减75.5 dB |
| 4.096 MS/s不能靠修改常数越过单ADC 4 MS/s上限 | project-only | `04_progress.md`与`05_known_issues.md` | written | 独立实验改用ADC1/ADC2交错，4.100 MS/s配置，Keil 0 error、0 warning，待上板实测 |
| 缓冲区指针、计数、元素类型和工程单位必须同时一致 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | 旧桥接把2048点指针按4096点读取并对浮点电压重复ADC换算；V2.5改为显式VO电压接口 |
| 上游函数会原地修改共享数组时应拆分Prepare/Publish边界 | project-only | `03_decisions.md`与`11_current_handoff_2026-07-31.md` | written | `Vpp_R()`去直流并清尾部，桥接必须在其前快照、结果完成后提交 |
| 已融合旧包后的队友升级继续只发增量函数包，不覆盖main | project-only | `03_decisions.md`与`06_todo_next.md` | kept | V2.5包只含桥接函数和手工接线说明，队友长按刷新与我方长按测试保持分离 |
| 稀疏解析模型可作为主显示，但必须保留原始数据残差和回退路径 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | V2.6幅相模型能平滑复原，仍可能隐藏漏峰、削顶、双ADC失配和未标定相移 |
| 新旧算法嵌套开关必须定义明确优先级 | project-only | `03_decisions.md`与仓库HMI历史文档 | rejected | V2.8产品决策已删除两组开关和旧算法，不再保留运行时分支 |
| 解析波形应使用模型自身的固定相位原点，避免每帧从多峰复合波形重新选触发峰 | project-only | `03_decisions.md`与V2.8审计 | written | 相近正峰高度互换会令相邻零交叉跳到另一相位；V2.8固定为0、1/4、1/2周期 |
| 竞赛报告的数学实现误差不得冒充实物幅相标定精度 | project-only | `04_progress.md`与`05_known_issues.md` | written | 72组0.037693 mV只验证公式；G(f)、theta(f)、双ADC失配仍待扫频实测 |
| 原始时序绘图不能冒充已完成相位标定的归一化波形复原 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | L431参考工程直接打印内部ADC原始点；本项目还要求固定1T/3T、幅相模型和实物标定 |
| 最终队友快照只作取证底座，理论4096点必须同时服务Upp与时域图 | project-only | `03_decisions.md`、`04_progress.md`与`11_current_handoff_2026-07-31.md` | written | V2.7最终基线融合、零警告构建与队友增量交接包 |
| 理论点、桥接点和屏幕像素应分别以N/M/P建模，避免点数升级改写显示协议与报告 | project-only | `03_decisions.md`、`04_progress.md`与V2.8报告文档 | written | V2.8接口接受512至8192点并固定抽取512点；显示V3和数学说明使用字母推导 |
| 无信号是明确状态，不能用“拒绝本帧”代替发布空结果 | cross-project pitfall | `03_CrossProject/pitfalls.md`与`06_Maps/pitfall-map.md` | written | V2.8旧PrepareReal拒绝全0频率后会保留旧正弦；新增PublishNoSignal发布全0有效快照 |
| 单频必须是一等分量状态，不能伪装成双频并携带噪声峰 | project-only | `04_progress.md`与`05_known_issues.md` | written | V2.8.1增加flag=1、只合成基波并只发布一个频谱分量；0/1/2/3共用FFT后分类 |
| ADC报告先写通用采样与频域公式，再单独映射具体固件参数 | project-only | `04_progress.md`与仓库`docs/05_report/ADC部分V2.docx` | written | 第2章使用L/B/N/Fs/K/R通式，第3章对应`teammate/last`双ADC 4096点实现；14个原生公式和11页版式已验证 |
| 页数受限的竞赛主报告应原位替换过时链路，并对未授权硬件主体做逐段、媒体和表格不变审计 | project-only | `04_progress.md`与仓库`docs/05_report/B26244_3.docx` | written | 主报告融合最新ADC与V2.8显示后仍为8页；硬件正文、4图和测试表不变，9个原生公式及全页渲染通过 |
| 报告软件总图必须从当前正式调用链生成，并排除测试注入、历史算法和内部模式名称 | project-only | `04_progress.md`与仓库`docs/05_report/figures/` | updated | Visio总图收敛为9个黑白高层节点，初始化合并且框内无函数名；VSDX关闭重开、SVG黑白和PNG灰度检查通过 |
