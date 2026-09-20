# Decisions

## D-20260622-001: Use native fetch for DeepSeek Chat Completions

Decision: `DeepSeekProvider` 用原生 `fetch` 调用 `POST /chat/completions`，Provider 名称保持 `deepseek`。

Reason: 用户明确没有 OpenAI API Key，且要求避免概念混乱。原生 fetch 也让 mock HTTP 单元测试更直接。

Evidence: `src/llm/deepseekProvider.ts`, `src/tests/deepseekProvider.test.ts`.

## D-20260622-002: Non-streaming reply uses aibot_respond_msg markdown payload

Decision: 第一版普通回复使用 `aibot_respond_msg` + `msgtype=markdown`，透传回调 `headers.req_id`。

Reason: 企业微信长连接官方文档普通回复命令是 `aibot_respond_msg`，并说明支持 markdown/stream 等消息类型；任务书要求第一版先做非流式文本回复。

Evidence: `src/wecom/protocol.ts`, `README.md`.

## D-20260622-003: Keep ChatGPT browser provider as hard-failing placeholder

Decision: `chatgpt-browser` 只保留 `BrowserProviderPlaceholder`，调用或选择时直接报错。

Reason: 任务书明确不实现 ChatGPT 网页端自动化，不写 Playwright/Selenium，不抓 DOM。

Evidence: `src/llm/browserProvider.placeholder.ts`, `src/llm/provider.ts`, `src/tests/provider.test.ts`.

## D-20260622-004: Do not create persistent secrets in project memory

Decision: 知识库只记录“真实凭据验证通过”，不记录任何 Bot Secret 或 API Key。

Reason: 全局记忆规则和任务书均禁止提交或共享密钥。

Evidence: 2026-06-22 secret scan found no real provided secrets under project source excluding dependencies.
