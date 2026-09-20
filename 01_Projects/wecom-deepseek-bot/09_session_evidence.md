# Session Evidence

## 2026-06-22 Codex Build Session

Evidence summary:

1. Read global memory and YUSU KB startup rules.
2. Read root taskbook `F:\Project\微信智能体\立项任务书.txt`.
3. Confirmed initial project state: root was not a Git repository and contained only the taskbook.
4. Retrieved official Enterprise WeChat long-connection doc page and extracted key protocol facts from the large HTML document.
5. Confirmed DeepSeek official `/models` returned `deepseek-v4-flash` and `deepseek-v4-pro` using a temporary process environment.
6. Created `F:\Project\微信智能体\wecom-deepseek-bot`.
7. Ran `npm install`.
8. Ran `npm test`: 7 test files, 22 tests passed.
9. Ran `npx tsc --noEmit`: passed after RawData and provider-log fixes.
10. Ran `npm run lint`: passed.
11. Ran `npm run self:test:mock -- "你好，测试一下链路"`: produced Mock reply and reply payload.
12. Ran `npm run self:test:provider -- "测试 provider 选择"`: selected mock/deepseek and rejected chatgpt-browser/openai.
13. Ran `npm run self:test:deepseek -- "你好"` with temporary env var: DeepSeek returned valid content.
14. Ran short WeCom dev smoke with temporary Bot env vars and Mock provider: connected, subscribed with `errcode=0`, heartbeat ok.
15. Ran source secret scan for the actual provided Bot ID, Secret, and DeepSeek API Key: no matches in project files excluding dependencies/package lock.
16. Patched reply-send logging to carry `provider` into `wecom reply sent`; reran `npm test`, `npx tsc --noEmit`, `npm run lint`, self-test commands, and WeCom heartbeat smoke.
17. Added `npm run self:test:wecom` as a reproducible WeCom smoke command that reads Bot credentials only from environment variables, subscribes, sends one heartbeat, and exits.
18. Created local ignored `.env` with user-provided credentials, verified `.gitignore` contains `.env`, `.env.local`, and `.env.production`, then reran DeepSeek self-test and WeCom smoke successfully. This memory file intentionally omits the actual secret values.
19. Started the real dev service with `npm run dev:start`; `npm run dev:logs` showed real single-chat messages and one group @ message from the user's Enterprise WeChat client, followed by `deepseek request completed` and `wecom reply sent`.
20. User later confirmed in the Codex thread that the Enterprise WeChat client can see the bot reply and requested no further debugging; Codex generated `F:\Project\微信智能体\任务书简报.md` as the taskbook brief and next-stage plan.

No raw secrets are stored in this evidence file.
