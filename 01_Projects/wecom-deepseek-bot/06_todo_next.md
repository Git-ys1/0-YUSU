# Todo Next

## Next Actions

- [x] Run `npm run dev` with `.env` filled locally.
- [x] User sends single-chat messages in DeepSeek mode; backend logs `received message`, `deepseek request completed`, and `wecom reply sent`.
- [x] User @mentions the bot in a test group; backend logs group `received message`, `mentioned=true`, `deepseek request completed`, and `wecom reply sent`.
- [x] User confirms the Enterprise WeChat client visually displays a DeepSeek reply.
- [ ] If group visual display was not separately checked, confirm the test group also displays the group @ DeepSeek reply.
- [ ] User sends a non-@ group message and confirms no reply appears.

## Evidence Gaps

- [x] Client-side user confirmation for visible bot reply.
- [ ] Separate client-side confirmation for group @ reply display if needed.
- [ ] Client-side confirmation for group non-@ no-reply behavior.

## Needs User Decision

- [ ] Whether to keep using `deepseek-v4-pro` as default or switch first-run operations to `deepseek-v4-flash`.
- [x] Whether to persist a local ignored `.env` file with the provided credentials or keep passing env vars manually. Decision: user explicitly asked to fill local `.env`; do not copy values into memory.

## Later

- [ ] Add Redis dedupe/context if deploying multiple instances.
- [ ] Add production process manager and structured log sink.
- [ ] Add one-shot stream reply fallback if markdown ordinary replies fail in tenant.
