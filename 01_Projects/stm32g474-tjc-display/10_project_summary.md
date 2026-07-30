# 项目阶段总结：STM32G474周期信号分析显示融合

更新时间：2026-07-30  
阶段：V1.4全量融合稳定基线

## 当前结论

项目已经从“独立显示演示 + 独立信号处理代码”进入可烧录的融合阶段。当前基线位于：

```text
F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer
\projects\g474_full_integration_test
```

主链路为：

```text
ADC2/TIM3/DMA
→ 队友FFT、Vpp、RMS
→ AnalyzerBridge统一稳定快照
→ Display_Task
→ USART3
→ 淘晶驰dashboard
```

## 五条最重要经验

1. 融合应以外设和算法更完整的一侧为底座，通过结果桥接层接显示，不能拼两个`main.c`。
2. 多个处理函数共享FFT全局输出时，必须在覆盖发生前立即快照。
3. 高计算负载下UART短帧接收不能只靠主循环轮询；接收中断与主循环绘图应分工。
4. 嵌入式大结果结构体必须先对照Map和启动栈大小；1084字节对象不能进入1024字节主栈。
5. “屏幕无图”只是表象，ST-Link应依次检查CPU模式、Fault栈、Map、UART寄存器和模块状态。

## 已冻结部分

- dashboard 6字节初始化帧和四个按钮帧；
- 两条曲线动态数字ID；
- `cle/addt → FE → data → FD`握手；
- 1T/3T时域重采样、0至500 kHz定性频谱和定点文本格式；
- USART3中断接收、主循环绘图；
- `AnalyzerResult`统一接口和静态快照。

## 后续重点

- 真实模拟前端增益、偏置和频响标定；
- 500 Hz频率分辨率和实际采样率校准；
- 基频/谐波识别边界；
- 1 MHz以上干扰抑制；
- 正式实体屏和2秒响应时间回归。

## Evidence

- `docs/V1.4_FUSION_BASELINE_FREEZE_2026-07-30.md`
- `docs/V1.4_INTEGRATION_ARCHITECTURE.md`
- `docs/SCREEN_TEST_GUIDE.md`
- `projects/g474_full_integration_test/Core/Src/main.c`
- `projects/g474_full_integration_test/Core/Src/analyzer_bridge.c`
- `projects/g474_full_integration_test/Core/Src/display.c`
- [[../../03_CrossProject/stm32-stlink-runtime-debugging]]
