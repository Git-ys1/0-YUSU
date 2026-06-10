# Project Summary

## Most Important Things

| Rank | Lesson | Why It Matters |
| --- | --- | --- |
| 1 | RKNN Runtime crashes need binary integrity checks first | Version strings can be misleading; the actual root cause was a corrupt `librknnrt.so` |
| 2 | C API smoke test is the clean separator between driver/runtime and Python wrapper | It proved RK3588 driver/runtime/model compatibility before touching YOLO postprocess |
| 3 | Board-side YOLO postprocess should avoid unnecessary torch dependency | NumPy DFL removed the libgomp/static TLS failure path and kept output identical |
| 4 | Camera demos must distinguish video nodes from metadata nodes | `/dev/video1` was not a normal image stream; auto-fallback prevented false camera failures |
| 5 | Vendor upstreams should be rebuilt from official Git plus overlay | CleanScout should own its delta, not silently vendor a large mutable upstream clone |
| 6 | This is the future mechanical-arm perception seed | Do not jump to servo control before the detection output contract is defined |

## Current Deliverable

CleanScout now has a published OrangePi AI baseline in the main repo:

```text
F:\Project\CleanScout_rover\OrangePi\rk3588_ai
```

It contains task books, reports, smoke scripts, selected validation images, and a model-zoo overlay. The full upstream RKNN Model Zoo is intentionally reconstructed from official Git.

## Memory Routing Audit

| Candidate Lesson | Route | Action |
| --- | --- | --- |
| RKNN Runtime version string is not enough; verify binary integrity | project plus reusable tooling | written here; can later be promoted to cross-project tooling if more RKNN projects appear |
| Official model zoo should be upstream + overlay, not vendored wholesale | project plus cross-project pattern | written here; useful for other vendor-heavy embedded projects |
| Do not store board passwords in KB | global existing rule | obeyed; no password copied into this project memory |
| Camera metadata nodes can masquerade as video devices | project-only for now | written in known issues |

## Completion Status

This entry is a new-project snapshot, not a mature multi-month ingestion. It records the JSONL and current baseline sufficiently for future Codex work to continue the OrangePi AI line without relying on chat memory.

