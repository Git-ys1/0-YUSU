# ADR: RF1 native timer encoder path

**Status**: accepted  
**Date**: 2026-04-19

## Context

CN1/CN3 编码器问题一度让项目怀疑 OpenRF1 的原生 TIM 编码器路线失效，并引入了循迹口软编码器止损分支。

## Decision

正式 RF1 主线继续使用原生 TIM2/TIM3/TIM4/TIM5 编码器架构；软编码器只保留为证据和临时止损历史。

## Consequences

- 保住了正确的硬件架构
- 后续排障必须更重视硬件证伪，而不是先改软件架构

## Evidence

- `docs/VERIFY/C-3.1.4B_openrf1_timer_final_convergence.md`
