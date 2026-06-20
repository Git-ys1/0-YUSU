# Project Summary

## Most Important Lessons

1. Video learning needs artifacts, not impressions.
   A usable system must export keyframes, OCR, ASR, segment JSON, timeline, video index, and `agent_context/`.

2. `mock` provider is a pipeline test only.
   When real vision APIs fail, Codex must inspect keyframes directly and preserve that review as structured evidence.

3. `step_by_step.md` must be rebuilt into engineering order.
   Raw video chronology is not enough for a future Codex to continue work.

4. OCR and ASR need budgets and caches.
   Long videos can otherwise burn time and disk; keep caches under the project `.tools/` directory.

5. Validation must use a real local video.
   This project was validated on `个人站.mp4`, including OCR, ASR, keyframes, segment analysis, timeline, video index, and follow-up notes.

## Memory Routing Audit

- Project-specific facts: this directory.
- Cross-project reusable lessons: update `04_Runbooks/video-understanding-protocol.md` and `03_CrossProject/tooling.md`.
- Global stable rule candidate: do not claim video understanding without timeline/OCR/ASR/keyframe evidence.
- Secrets: no API keys or tokens were written.

