# Runbook

## Install

```powershell
cd F:\Project\微信智能体\wecom-deepseek-bot
npm install
```

## Configure

```powershell
cp .env.example .env
```

填写：

- `WECOM_BOT_ID`
- `WECOM_BOT_SECRET`
- `DEEPSEEK_API_KEY`
- 可选：`WECOM_BOT_NAME`

不要把真实值写进 README、测试文件或知识库。

## Local Checks

```powershell
npm test
npx tsc --noEmit
npm run lint
npm run self:test:mock -- "你好，测试一下链路"
npm run self:test:provider -- "测试 provider 选择"
npm run self:test:deepseek -- "你好"
npm run self:test:wecom
```

## Dev Server

```powershell
npm run dev
```

预期日志：

- `connecting`
- `connected`
- `subscribing`
- `subscribed`
- `heartbeat ok`

## Windows Background E2E Helper

```powershell
npm run dev:start
npm run dev:logs
npm run dev:stop
```

`dev:start` starts the same long-connection service in a hidden background process and writes logs to ignored `logs/dev.out.log` and `logs/dev.err.log`.

## Docker

```powershell
docker compose up --build
docker compose logs -f wecom-deepseek-bot
```

## Real Client E2E

1. 设置 `LLM_PROVIDER=mock` 或 `ENABLE_MOCK_LLM=true`。
2. 启动 `npm run dev`。
3. 用户在企业微信客户端给机器人发单聊消息，确认企业微信客户端出现 Mock 回复。
4. 切到 `LLM_PROVIDER=deepseek` 并配置 `DEEPSEEK_API_KEY`。
5. 用户做单聊 DeepSeek 和群聊 @机器人 DeepSeek 测试。
6. 群聊非 @ 消息应不回复。
