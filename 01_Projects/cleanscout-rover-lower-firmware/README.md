# CleanScout_rover 下位机

## Metadata

- Project Name: CleanScout_rover 下位机
- Project Slug: `cleanscout-rover-lower-firmware`
- Primary Path: `F:\Project\CleanScout_rover`
- OS/Environment: Windows, PowerShell, Keil MDK ARM, STM32CubeProgrammer, ST-Link
- Main Languages/Frameworks: C, STM32F1 SPL/CMSIS, PowerShell
- Last Updated: 2026-06-07
- Maintainer/Source: Codex current engineer session `019ce0df-b2bc-76d0-9e0e-fd78073132a1`

## Scope

这份项目记忆只覆盖 `CleanScout_rover` 的下位机线，不覆盖树莓派 ROS、Vue3/uni-app 前后端或云端后端。

当前纳入范围：

- `firmware/openrf1_motion_controller/`：OpenRF1 底盘正式固件主线
- `firmware/mechanical_arm_official_baseline/`：机械臂 STM32 官方冻结基线
- `firmware/mechanical_arm_controller/`：机械臂后续独立开发占位
- 相关下位机文档、烧录/串口脚本、验证记录

不纳入本条目主叙事的部分：

- `Raspberrypi/`
- `vue3/`
- `jixiebi/` 旧视觉/抓取实验线
- `_local/` 历史工作副本

## Quick Links

- [[00_project_brief]]
- [[01_architecture]]
- [[02_runbook]]
- [[03_decisions]]
- [[04_progress]]
- [[05_known_issues]]
- [[06_todo_next]]
- [[07_development_history]]
- [[08_onboarding_from_zero]]
- [[09_session_evidence]]
- [[10_project_summary]]

## Maturity Level

- [x] Mature project full-cycle ingestion
- [ ] New/light project snapshot

## One Sentence

CleanScout_rover 下位机已经从早期 UNO / `_local` 多工作副本试错，收敛为一条正式 RF1 底盘固件主线，并在 2026-06-07 冻结了机械臂 STM32 官方基线，准备从 `C-3.7.0` 开始独立推进机械臂控制。
