# CleanScout Rover 前后端 / V 线软件交互系统

## Metadata

- Slug: `cleanscout-rover-vue3`
- Canonical remote repository: `https://github.com/Git-ys1/CleanScout_rover`，本条目覆盖其中 `vue3/` 子树。
- HDS-side observed checkout: `F:\Project\CSc——uniapp\vue3`
- Cloud-side observed checkout variants: `/opt/CleanScout_rover/vue3`、`/opt/cleanscout-src/vue3`
- YUSU-side checkout path: use an environment variable, e.g. `%CLEANSCOUT_VUE3_ROOT%` on Windows or `$CLEANSCOUT_VUE3_ROOT` on Linux/macOS, pointing to the local `CleanScout_rover/vue3` checkout.
- Do not assume HDS evidence path exists on yusu-side machines.
- Current evidence HEAD: `bf9cf82 V-2.2.3: 优化 OpenClaw 对话显示与状态口径`
- Current local branch observed during ingestion: `feature/v-1.7.0-edge-relay-cloud-transport`
- Status: active, CSR / superyusu 重点项目子系统。
- Ingested at: 2026-06-08

## One-Line Positioning

CleanScout Rover 前后端不是单纯 uni-app 页面，而是 V 线软件交互系统：`uni-app Vue3 前端 + Express/Prisma/SQLite backend + public-edge 设备网关 + OpenClaw/ESP32-CAM/ASR 接入链路`。

## Path Portability

0-YUSU 最终会回到 yusu 端 Windows 使用，因此本文档里的 `F:\Project\CSc——uniapp\vue3` 只是本次 HDS 入库时的证据路径。未来在 yusu 端检索或继续开发时，应以远程仓库 `Git-ys1/CleanScout_rover` 的 `vue3/` 子目录为准，先设置 `%CLEANSCOUT_VUE3_ROOT%` / `$CLEANSCOUT_VUE3_ROOT` 指向 yusu 本机 checkout，再执行命令。

## Primary Boundary

前端不直接连接树莓派、ROS master、rosbridge、OpenClaw Gateway 或 ESP32-CAM 内网地址。正式链路统一走 backend，由设备侧或 PC worker 主动连接云端。

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

## ADR

- [[adr/2026-04-19-edge-relay-public-edge]]
- [[adr/2026-05-03-backend-bootstrap-and-deploy-revision]]
- [[adr/2026-05-24-openclaw-pc-worker]]
- [[adr/2026-05-26-esp32cam-raw-mjpeg-relay]]

## Retrieval Hints

关键词：CleanScout、CSR、vue3、V 线、public-edge、edge-relay、ROS_TRANSPORT、OpenClaw PC worker、ESP32-CAM raw MJPEG、FunASR、uni-app、小程序、Netlify H5、VPS backend。
