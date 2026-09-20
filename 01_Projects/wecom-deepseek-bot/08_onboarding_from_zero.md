# Onboarding From Zero

1. Read `F:\Project\微信智能体\立项任务书.txt`.
2. Read project `README.md`.
3. Inspect protocol code first:
   - `src/wecom/protocol.ts`
   - `src/wecom/client.ts`
   - `src/wecom/types.ts`
4. Inspect handler/provider code:
   - `src/handlers/messageHandler.ts`
   - `src/llm/deepseekProvider.ts`
   - `src/llm/provider.ts`
5. Run local checks:

```powershell
npm install
npm test
npx tsc --noEmit
npm run self:test:mock -- "你好"
```

6. Only after local checks pass, fill `.env` locally and run `npm run dev`.

Do not add OpenAI API, ChatGPT browser automation, personal WeChat hooks, databases, or knowledge-base systems unless the user starts a separate phase.
