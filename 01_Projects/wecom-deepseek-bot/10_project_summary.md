# Project Summary

## Key Lessons

1. Enterprise WeChat intelligent bot long connection can be implemented locally without a public callback URL; the critical protocol fields are `wss://openws.work.weixin.qq.com`, `aibot_subscribe`, `body.bot_id`, `body.secret`, `ping`, `aibot_msg_callback`, and `aibot_respond_msg`.
2. The first safe delivery boundary is DeepSeek + Mock only. OpenAI API and ChatGPT browser automation remain explicitly out of scope.
3. Local verification can cover most of the backend: unit tests, mock self-test, provider selection, real DeepSeek self-test, WebSocket subscribe, and heartbeat.
4. Full local MVP completion required a human enterprise WeChat client message test; the user later confirmed the client can see the bot reply.
5. Secret hygiene worked: real credentials were used only as temporary process environment variables, and the project source scan found no real provided secrets.

## Memory Routing Audit

| Candidate Lesson | Route | Target File | Action | Evidence |
|---|---|---|---|---|
| WeCom long-connection protocol facts and doc extraction are reusable for future enterprise WeChat bots | cross-project tooling | `03_CrossProject/tooling.md`, `06_Maps/tool-map.md` | written | Official doc path 101463 extraction and project `src/wecom/protocol.ts` |
| This project's exact implementation state and human client confirmation | project-only | `01_Projects/wecom-deepseek-bot/04_progress.md`, `06_todo_next.md` | updated | Command results, real message logs, and user confirmation |
| Do not store real Bot Secret/API Key in shared memory | project-only | `01_Projects/wecom-deepseek-bot/03_decisions.md` | kept | Existing global secret rules already cover this broadly |
