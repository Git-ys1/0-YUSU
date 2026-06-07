# 09 Session Evidence

## Ingestion Session

- Ingestion date: 2026-06-08
- Current engineer JSONL:
  `C:\Users\hzh\.codex\sessions\2026\04\17\rollout-2026-04-17T19-03-28-019d9b1c-2ef8-7051-9146-d70901325331.jsonl`
- Identified via `CODEX_THREAD_ID=019d9b1c-2ef8-7051-9146-d70901325331`.
- Project cwd matched HDS-side CleanScout vue3 worktree.
- Audit note: the JSONL metadata renders the `CSc——uniapp` path with a historical encoding mismatch when read by the gate, so `mature-project-retro-audit.ps1` should be run with `-AllowCwdMismatch`; the session id, real project path and Git history were still verified.

## Repository Evidence

Observed locally during ingestion:

```text
repo scope: Git-ys1/CleanScout_rover/vue3
HDS path: F:\Project\CSc——uniapp\vue3
HEAD: 2026-05-28 bf9cf82 V-2.2.3: 优化 OpenClaw 对话显示与状态口径
branch: feature/v-1.7.0-edge-relay-cloud-transport
```

Observed untracked files during ingestion:

- `docs/2026-05-04-Vibe coding前端干货！4种方法提升页面质感.md`
- `docs/PLAN/V-1.8.8.md`
- `docs/PLAN/V-1.9.0.md`
- `docs/PLAN/V-2.2.0.md`
- `docs/PLAN/V2.1.0.md`

These were not treated as published release evidence unless separately cited by stable docs.

## Files Used As Evidence

- `README.md`
- `docs/deployment.md`
- `docs/camera-mjpeg-stream.md`
- `docs/releases/V-1.0.0/README.md` through `docs/releases/V-2.1.0/README.md`
- `backend/src/app.js`
- `backend/src/server.js`
- `backend/src/services/openclawAgentService.js`
- `backend/src/camera/*`
- `tools/pc-openclaw-worker/*`
- `tools/pc-camera-worker/*`

## Redaction

No token, key, password, cookie, or private credential value is intentionally written into this 0-YUSU entry. Only variable names and protocol names are recorded.
