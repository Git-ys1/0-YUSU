# Architecture

## 系统分层

```text
信号发生器与模拟前端
        ↓
TIM3双边沿触发
        ↓
ADC1/PA0 + ADC2/PA1，各2048点DMA
        ↓
交错为VO[4096]浮点电压
        ↓
4096点FFT分量识别 + Goertzel相位
        ↓
前端相位表补偿 + 相对谐波初相
        ↓
getup()生成4096点理论周期，得到Upp
Vpp_R()第二次FFT得到Vr和最终频谱分量
        ↓
AnalyzerBridge准备、复制512点、原子发布快照
        ↓
Display_Task生成时域/频谱/文本命令
        ↓
USART3 ↔ 淘晶驰dashboard
```

## 硬件与外设

| 模块 | 最终工程事实 |
|---|---|
| MCU | STM32G474VET6 |
| ADC输入 | ADC1/PA0、ADC2/PA1 |
| 采样触发 | TIM3 CH4上升沿/下降沿交错 |
| 缓冲 | `adc_b[2048]`、`adc_b1[2048]` |
| 合成序列 | `VO[4096]`，工程中使用约2.048193 MS/s |
| 屏幕串口 | USART3，PC10/PC11 |
| 实体按键 | KEY1，PB8；现场不可触摸屏的主要操作入口 |
| 调试/烧录 | ST-Link SWD、STM32CubeProgrammer |

## 软件模块

### `main.c`

负责HAL初始化、双ADC DMA、FFT/Goertzel、分量分类、`getup()`理论波形、Upp/Vr
计算、KEY1任务以及桥接发布。最终真源位于`teammate/24/Core/Src/main.c`。

### `analyzer_bridge.c/.h`

算法与显示之间的边界：

- 接收1至3个有效分量及最终Upp/Vr；
- 接收512至8192点理论波形，立即等距复制为512点；
- 用静态快照和序号避免显示读到半更新数据；
- `AnalyzerBridge_PublishNoSignal()`主动发布全零有效帧，覆盖旧结果；
- 生产宏`ANALYZER_TEST_ENABLE`和`ANALYZER_CUSTOM_TEST_ENABLE`均为0。

### `display.c/.h`

负责淘晶驰协议和界面状态：

- 等待dashboard上报两条曲线真实数字ID；
- 用`cle/addt`及`FE/FD`应答绘制曲线；
- 512点时域、256点频谱、定点文本和动态刻度；
- 1T/3T、刷新、测试、清除、停止、3秒自动刷新；
- 无触发、上升过零、下降过零、正峰值四种显示锚点；
- ISR仅接收短帧和置事件，耗时UART发送留在主循环。

## 数据契约

`AnalyzerResult`包含：有效标志、序号、来源、基频、Upp、Urms、最多三个频谱
分量、512点时域波形、测试编号和状态标志。单位边界必须保持：算法输入通常是V，
显示结果是mV；不得重复执行ADC码到电压的换算，也不得把峰值、峰峰值和RMS混用。

## 显示协议边界

HMI上电后通过6字节初始化帧上报`time/spec`真实数字ID。控制帧以`A5`开头、
`5A`结尾。曲线发送必须保证声明点数、实际数据字节数和应答顺序一致。页面对象名
和数字ID都属于固件—HMI联合接口，不能单边修改。

## 源码与证据分层

| 层级 | 路径 | 作用 |
|---|---|---|
| 最终比赛源码 | `teammate/24/` | 只读冻结，可复现实赛 |
| 赛前开发主线 | `firmware/` | 展示重构过程和未发布V2.8状态 |
| 队友底座 | `teammate/current/`、`last/` | 追溯算法融合前状态 |
| 历史工程 | `archive/`、`teammate/archive/` | 只读追溯 |
| 过程实验 | `experiments/`、`tests/`、`tools/` | 离线验证和隔离试验 |
| 报告与交接 | `docs/`、`plan/`、`deliverables/` | 设计、验证和协作证据 |

## 关键架构约束

1. 不能拼接两个`main.c`；以采集算法完整的一侧为底座，通过桥接接入显示。
2. FFT全局缓冲会被后续处理覆盖，需要在正确时点快照。
3. 大型结果对象必须静态分配，不能压入1 KB级主栈。
4. UART中断与绘图分工；禁止在EXTI回调内发送整帧。
5. 解析模型输出必须保留无信号门控，不能把空载噪声合成为稳定正弦。
6. 数字滤波和显示平滑不能替代模拟输入保护、偏置、驱动、抗混叠与标定。
