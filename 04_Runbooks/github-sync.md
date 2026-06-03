# GitHub Sync

本文件定义云端同步方案。

## Final Decision

- 本地主库路径：`F:\AcademicHub\0#YUSU`
- GitHub 私有远端：`https://github.com/Git-ys1/0-YUSU`
- GitHub 可见仓库名：`0-YUSU`

用户希望仓库名为 `0#YUSU`。实际创建时，GitHub CLI / GitHub 将名称规范化成 `0-YUSU`。因此本地主库仍保留 `0#YUSU`，云端使用 `0-YUSU`。

## Why GitHub Sync

原生 Windows/Ubuntu 双系统共享需要 Ubuntu 挂载 Windows NTFS 分区；这一步必须进入 Ubuntu 后实测。为了避免“Ubuntu 暂时看不到 Windows 文件夹”导致知识库不可用，采用 GitHub 私有仓库作为跨端同步层。

主机仍是 Windows 本地目录；GitHub 是同步远端。

## Windows 主机工作流

```powershell
cd "F:\AcademicHub\0#YUSU"
git status --short
git add .
git commit -m "更新知识库"
git push
```

Windows Codex 接入：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\setup-codex-endpoint.ps1
```

## Ubuntu 20.04 工作流

如果不使用 NTFS 共享，直接 clone 私有仓库：

```bash
mkdir -p "$HOME/AcademicHub"
git clone https://github.com/Git-ys1/0-YUSU.git "$HOME/AcademicHub/0-YUSU"
cd "$HOME/AcademicHub/0-YUSU"
bash tools/setup-codex-endpoint.sh
```

以后更新：

```bash
cd "$YUSU_KB_ROOT"
git pull --rebase
```

Ubuntu 侧写入后发布：

```bash
cd "$YUSU_KB_ROOT"
git status --short
git add .
git commit -m "更新 Ubuntu 侧知识库"
git pull --rebase
git push
```

## 冲突规则

1. 写入前先 `git pull --rebase`。
2. 一个端修改完成后尽快 commit + push。
3. 另一个端开始前先 pull。
4. 如果冲突，保留事实证据，不要直接丢弃别端经验。

## Codex 规则

每个端的 Codex 都应能做到：

1. 读取全局 `~/.codex/AGENTS.md` 中的 Shared YUSU Knowledge Vault 段落。
2. 发现 `yusu-kb` skill。
3. 通过 `YUSU_KB_ROOT` 找到知识库。
4. 用 `tools/search-kb.*` 搜索历史经验。

验证：

```bash
test -f "$YUSU_KB_ROOT/00_START_HERE_FOR_CODEX.md"
test -f "$HOME/.agents/skills/yusu-kb/SKILL.md"
test -f "$HOME/.codex/skills/yusu-kb/SKILL.md"
bash "$YUSU_KB_ROOT/tools/search-kb.sh" "Codex Memories canonical"
```

Windows 验证：

```powershell
Test-Path "$env:YUSU_KB_ROOT\00_START_HERE_FOR_CODEX.md"
Test-Path "$HOME\.agents\skills\yusu-kb\SKILL.md"
Test-Path "$HOME\.codex\skills\yusu-kb\SKILL.md"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:YUSU_KB_ROOT\tools\search-kb.ps1" -Query "Codex Memories canonical"
```

