# Known Issues

## Some client-side checks require user action

The code can connect and subscribe to WeCom, but Codex cannot independently prove every enterprise WeChat client behavior unless the user sends real messages from the client.

Evidence: 2026-06-22 verified WebSocket connect/subscribe/heartbeat; real single-chat and group @ callbacks reached the backend; the user later confirmed the client can see a bot reply. Group non-@ no-reply remains a useful manual check before production use.

## Official WeCom group mention fields may vary

The official long-connection doc sample shows group text content like `@RobotA hello robot` but does not expose a stable detailed mention field in the extracted sample. The handler first checks likely official mention/at fields and falls back to `WECOM_BOT_NAME` or a leading `@...`.

Evidence: `src/handlers/messageHandler.ts`.

## Ordinary reply uses markdown payload

Taskbook asked for “text reply”; official long-connection ordinary reply docs emphasize `aibot_respond_msg` with stream/markdown and related message types. First version sends markdown as the non-streaming text-like reply. If WeCom rejects markdown replies in a specific tenant, switch to one-shot stream payload with `finish=true`.

Evidence: `src/wecom/protocol.ts` includes both markdown and stream builders.

## One active connection per bot

Official docs state one bot can keep only one effective long connection at a time. Starting this service can kick an older connection for the same bot.

Evidence: Enterprise WeChat official long-connection doc path 101463.
