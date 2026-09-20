# Project Brief

## One Sentence

本地企业微信智能机器人长连接后端：企业微信消息 -> 本地 TypeScript 服务 -> DeepSeek API / MockProvider -> 企业微信回复。

## Current Goal

完成任务书要求的第一版：支持企业微信长连接订阅、心跳、文本消息处理、DeepSeek/Mock Provider、自问自答测试、README 复现说明和 Docker 本地运行配置。

## Core Constraints

- 不接 OpenAI API，不实现 ChatGPT 网页自动化。
- 不使用个人微信 hook、itchat、安卓模拟器或群控工具。
- 不接数据库、知识库、LangChain/LlamaIndex。
- 真实 Bot Secret 与 DeepSeek Key 不写入仓库、README、测试或共享知识库。
- 企业微信长连接协议以官方文档 `https://developer.work.weixin.qq.com/document/path/101463` 为准。

## Current Stage

第一版本地实现已完成并通过自动化验证；企业微信真实连接、订阅和心跳已验证。真实单聊/群聊 @ 消息已进入后端并触发 DeepSeek 回复发送，用户已确认企业微信客户端能看到机器人回复。群聊非 @ 不回复仍建议作为下一阶段补验收。

## Maturity Assessment

- Project age: 2026-06-22 新建
- Approx commit count: 当前项目目录不是 Git 仓库
- Major releases/checkpoints: V0.1 local scaffold and protocol implementation
- Evidence quality: high for local/service checks and at least one human client visible reply; group non-@ no-reply still pending manual confirmation
- Ingestion mode: light snapshot

## From-Zero Summary

- What this project is: Node.js + TypeScript 的企业微信智能机器人长连接服务。
- Why it exists: 用户没有 OpenAI API Key，需要用 DeepSeek API 作为企业微信群聊/单聊机器人后端。
- The smallest useful thing to understand first: 企业微信长连接回复普通消息时使用回调 `headers.req_id` 关联，不需要公网回调 URL。
- The mistake a newcomer is most likely to make: 把长连接 Secret/DeepSeek Key 写进 README 或代码，或误用 OpenAI/ChatGPT 浏览器自动化。

## Source Evidence

- Project path: `F:\Project\微信智能体\wecom-deepseek-bot`
- Root taskbook: `F:\Project\微信智能体\立项任务书.txt`
- Remote: none
- Current commit: none, directory is not a Git repository
- Last verified: 2026-06-22
- Evidence files/logs: `README.md`, `src/`, `npm test`, `npx tsc --noEmit`, `npm run lint`, self-test commands, WeCom connection smoke, `npm run dev:logs`, user confirmation that replies are visible in the Enterprise WeChat client
