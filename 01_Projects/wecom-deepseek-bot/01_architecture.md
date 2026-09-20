# Architecture

## Runtime Shape

```text
企业微信客户端
  -> 企业微信 openws 长连接
  -> WeComLongConnectionClient
  -> MessageHandler
  -> LLMProvider: DeepSeekProvider | MockProvider
  -> replyBuilder
  -> aibot_respond_msg
  -> 企业微信客户端显示回复
```

## Key Modules

- `src/index.ts`: 加载配置，创建 logger/provider/handler/client，启动长连接。
- `src/wecom/client.ts`: WebSocket 连接、订阅、心跳、重连、回复发送和响应关联。
- `src/wecom/protocol.ts`: 官方协议 payload 构造，包括 `aibot_subscribe`、`ping`、`aibot_respond_msg`。
- `src/wecom/types.ts`: zod 解析企业微信基础包、消息回调、事件回调。
- `src/handlers/messageHandler.ts`: 文本消息过滤、群聊 @ 判断、去重、上下文、Provider 调用、回复构造。
- `src/handlers/dedupe.ts`: 内存 `msgid` 去重，默认 30 分钟。
- `src/handlers/contextStore.ts`: 内存上下文，按会话保留最近 6 轮。
- `src/llm/deepseekProvider.ts`: DeepSeek Chat Completions HTTP 调用。
- `src/llm/mockProvider.ts`: 本地 Mock 回复。
- `src/llm/browserProvider.placeholder.ts`: ChatGPT browser provider 占位，调用即报错。

## Official WeCom Facts Used

- WebSocket endpoint: `wss://openws.work.weixin.qq.com`
- Subscribe command: `aibot_subscribe`
- Subscribe body: `bot_id`, `secret`
- Message callback command: `aibot_msg_callback`
- Heartbeat command: `ping`, suggested interval 30 seconds
- Reply command: `aibot_respond_msg`
- Reply association: reuse callback `headers.req_id`
- Ordinary reply implementation: non-streaming markdown payload; stream payload helper reserved

## Data Storage

本轮不接数据库。去重和上下文都在内存中，进程重启后丢失可接受。
