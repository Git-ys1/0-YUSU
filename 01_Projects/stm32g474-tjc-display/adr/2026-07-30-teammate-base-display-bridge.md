# ADR：以队友采集算法工程为底座，通过桥接接入显示

- 日期：2026-07-30
- 状态：accepted
- 证据：`v1.4.0`、`docs/04_releases/V1.4_INTEGRATION_ARCHITECTURE.md`

## Context

显示演示工程和队友信号处理工程各有独立`main.c`、CubeMX配置和外设初始化。
直接拼接会重复初始化ADC、定时器、UART和中断，也无法稳定判断哪份全局缓冲有效。

## Decision

以采集、FFT和测量链更完整的队友工程为底座；显示逻辑拆成`display`模块，算法和
显示之间通过`AnalyzerResult`及`analyzer_bridge`传递稳定快照。禁止复制粘贴两个
主程序形成混合入口。

## Consequences

- 上游算法升级时只需调整桥接调用和少量集成点；
- 显示层不依赖FFT内部全局变量；
- 必须明确快照时机、单位和数组生命周期；
- 队友原始快照与融合工程需要分层保存。

## Revisit Conditions

只有在采集算法被完整重写为独立库、外设所有权明确且有自动化回归时，才考虑改变
该边界；不能因为两个文件都叫`main.c`就重新拼接。
