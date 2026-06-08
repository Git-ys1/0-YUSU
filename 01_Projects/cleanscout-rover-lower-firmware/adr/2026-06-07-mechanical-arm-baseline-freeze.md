# ADR: Mechanical-arm baseline freeze

**Status**: accepted  
**Date**: 2026-06-07

## Context

下位机准备进入机械臂阶段，但当前仓库里机械臂相关内容既有 `jixiebi/` 历史实验，又有刚导入的 STM32 官方例程资料包。如果继续直接改资料包，会重新制造正式入口混乱。

## Decision

把机械臂线拆成：

- `firmware/mechanical_arm_official_baseline/`
- `firmware/mechanical_arm_controller/`

前者冻结官方真值，后者承接新开发。

## Consequences

- 官方对照与自研修改分离
- 未来机械臂和 RF1 的融合可以延后而不阻塞当前调试

## Evidence

- `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
- current repo directory state on 2026-06-07
