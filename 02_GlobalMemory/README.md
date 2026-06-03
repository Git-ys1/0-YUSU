# Global Memory

这里是跨 Windows 和 Ubuntu 共享的 Codex 记忆层。它不自动替代当前机器上的 `C:\Users\yusu\.codex\memories`，但后续可以通过全局 `AGENTS.md` 或环境变量让两个系统都读取这里。

## 文件职责

- `PROFILE.md`: 稳定用户偏好和身份信息
- `ACTIVE.md`: 大多数任务都应应用的高优先级规则
- `LEARNINGS.md`: 尚未提升为规则的可复用经验
- `ERRORS.md`: 可复用的错误和环境排障记录
- `FEATURE_REQUESTS.md`: 长期缺失能力或反复出现的需求
- `legacy-import-YYYY-MM-DD.md`: 从旧 Codex memory 迁移来的来源说明和导入边界

## 提升规则

1. 只把稳定、跨项目有用的内容提升到 `ACTIVE.md`。
2. 只把长期用户偏好提升到 `PROFILE.md`。
3. 不确定内容先放 `LEARNINGS.md`。
4. 一次性噪声不入库。
