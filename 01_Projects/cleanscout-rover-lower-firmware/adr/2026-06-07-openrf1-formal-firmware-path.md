# ADR: OpenRF1 formal firmware path

**Status**: accepted  
**Date**: 2026-06-07

## Context

RF1 长期存在 `_local` 工程壳、跨目录源码、局部拷贝和工作区实验副本，导致正式入口不唯一。

## Decision

RF1 正式源码、工程和脚本统一收口到：

```text
firmware/openrf1_motion_controller/
```

## Consequences

- 文档、编译、烧录和发布入口统一
- 历史副本仍要保留，但只能当证据

## Evidence

- `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`
- commit `d3710ed`
