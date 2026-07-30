# STM32无显示/无响应的ST-Link运行态诊断

## 适用场景

适用于固件“能编译、能烧录，但屏幕空白、按键无响应、串口时好时坏或运行一段
时间HardFault”的问题。核心原则是：

> 先判断CPU是否健康，再判断通信和业务状态；不要从UI症状直接猜根因。

## 诊断阶梯

### 1. 确认板卡与连接

用SWD读取目标电压、ST-Link固件、Device ID、Flash容量。此步排除接错芯片、
供电异常和调试器未连接。

### 2. HotPlug冻结核心

读取：

```text
PC LR MSP PSP XPSR
```

判断：

- `XPSR`低9位是否为异常号；
- `PC`是否位于HardFault/BusFault/默认中断；
- MSP/PSP是否落在Map给出的合法栈区；
- CPU是否仍在预期Thread mode代码。

### 3. 读取Fault状态

重点地址：

```text
CFSR  0xE000ED28
HFSR  0xE000ED2C
DFSR  0xE000ED30
MMFAR 0xE000ED34
BFAR  0xE000ED38
```

不要只看当前`PC`。HardFault_Handler里的PC只是异常处理位置，真正的故障指令
通常在异常栈帧。

### 4. 回读异常栈帧

根据EXC_RETURN判断使用MSP还是PSP，读取：

```text
r0 r1 r2 r3 r12 lr pc xPSR
```

用压栈`pc`定位进入异常前的指令，再结合`.map`、反汇编和机器码判断所属模块。

### 5. 对照Map和静态内存

检查：

- 栈区起止地址；
- 大数组/结构体大小；
- UART/ADC句柄等静态对象地址；
- 故障地址是否跨出RAM或外设区。

Fault发生在`HAL_UART_Transmit()`不代表UART是根因；它可能只是第一个解引用被
栈溢出破坏指针的函数。

### 6. CPU健康时检查外设

以UART为例读取：

```text
ISR RDR CR1 CR3
```

检查ORE、RXNE、接收中断使能，以及RDR是否残留。再读协议解析器索引和最后状态，
判断是没收到、只收首字节、完整收帧还是业务未处理。

### 7. 检查业务状态

按链路逐级查看：

```text
页面ready/曲线ID
→ pending action
→ 当前模式
→ 结果valid/sequence
→ 最近FE/FD或错误码
```

最终要能区分：

```text
HMI没发
→ MCU没收
→ UART收不全
→ 协议解析失败
→ 页面未ready
→ 结果未发布
→ 绘图发送失败
→ CPU已异常
```

## 三类高价值故障模式

### ArmClang半主机`BKPT 0xAB`

特征：

- 进入`main()`前HardFault；
- 异常PC在`_sys_command_string`一类运行库函数；
- 机器码出现`BKPT 0xAB`。

处理：

- 检查MicroLIB/semihosting配置；
- 无命令行参数的固件显式声明`__ARM_use_no_argv`；
- 工具链版本变化后重新核对Map，不依赖旧构建的隐式选择符。

### 高计算负载导致UART ORE

特征：

- 上位机完整发送短帧；
- MCU解析器只收第一个字节；
- USART ISR有ORE。

处理：

- 使用中断或DMA持续接收；
- 错误回调清ORE、flush并重启；
- ISR只收字节/设置事件，耗时业务留在主循环。

### 大局部对象导致小主栈溢出

特征：

- Fault位置看似随机；
- BFAR为非法地址；
- MSP低于Map栈底；
- 外设句柄或函数指针被破坏。

处理：

- 对照`sizeof()`和Map中的`Stack_Mem`；
- 大型结果快照使用静态RAM或受控内存池；
- 不要只增大栈掩盖不必要的嵌套拷贝。

## 验证闭环

一次运行时修复至少需要：

```text
Clean Build
→ 下载与校验
→ 复位运行
→ 功能回归
→ ST-Link再次确认Thread mode、栈合法、Fault=0、外设无错误
```

只有“0 errors、0 warnings”不能证明固件可运行。

## Evidence

- Project: `stm32g474-tjc-display`
- Date: 2026-07-30
- Repo: `F:\Project\stm32G474VETx\TI\G_Periodic_Signal_Analyzer`
- Source: `docs/V1.4_FUSION_BASELINE_FREEZE_2026-07-30.md`
