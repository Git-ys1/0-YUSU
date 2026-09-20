# Development History

This is a light snapshot, not a mature full-cycle ingestion.

## 2026-06-22: Initial implementation

The project started from `F:\Project\微信智能体` with only `立项任务书.txt`. Codex read the taskbook, verified official Enterprise WeChat long-connection protocol facts from `https://developer.work.weixin.qq.com/document/path/101463`, verified DeepSeek model availability through `/models`, then scaffolded `wecom-deepseek-bot`.

Key implementation moved from empty folder to:

- protocol-accurate subscribe/ping/reply builders;
- long-connection client with reconnect and heartbeat;
- text-only message handler;
- DeepSeek/Mock provider abstraction;
- self-test scripts and unit tests;
- README and Docker files.

## Known unfinished history

The real enterprise WeChat client message round-trip is still pending user action.
