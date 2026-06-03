# Ubuntu First Run

这是给 Ubuntu 20.04 那边 Codex 的第一次接入清单。

## 1. 找到 Windows F 盘

```bash
lsblk -f
```

找到包含 `AcademicHub` 的 NTFS 分区。记录它的 UUID。

## 2. 挂载

```bash
sudo apt update
sudo apt install -y ntfs-3g
sudo mkdir -p /mnt/yusu-f
sudo mount -t ntfs-3g -o uid=$(id -u),gid=$(id -g),windows_names,big_writes UUID=<F_DRIVE_UUID> /mnt/yusu-f
```

## 3. 建立稳定路径

```bash
ln -sfn "/mnt/yusu-f/AcademicHub/0#YUSU" "$HOME/YUSU-KB"
echo 'export YUSU_KB_ROOT="$HOME/YUSU-KB"' >> ~/.bashrc
source ~/.bashrc
```

## 4. 验证

```bash
test -f "$YUSU_KB_ROOT/00_START_HERE_FOR_CODEX.md"
bash "$YUSU_KB_ROOT/tools/check-shared-access.sh" ubuntu
```

## 5. 接入 Ubuntu Codex

把下面内容加入 Ubuntu 的 `~/.codex/AGENTS.md`：

```md
## Shared YUSU Knowledge Vault

Use the shared YUSU knowledge vault at `$YUSU_KB_ROOT`.

Before non-trivial project work, read `$YUSU_KB_ROOT/00_START_HERE_FOR_CODEX.md`, then search project and cross-project memory before editing.

After non-trivial project work, update reusable lessons in the shared vault. Do not store secrets.
```

然后把 skill 链接到用户级 skills：

```bash
mkdir -p "$HOME/.agents/skills"
mkdir -p "$HOME/.codex/skills"
ln -sfn "$YUSU_KB_ROOT/.agents/skills/yusu-kb" "$HOME/.agents/skills/yusu-kb"
ln -sfn "$YUSU_KB_ROOT/.agents/skills/yusu-kb" "$HOME/.codex/skills/yusu-kb"
```

说明：官方路径是 `$HOME/.agents/skills`；为了兼容本机 Codex 桌面当前使用的 `$HOME/.codex/skills` 习惯，也同时链接到 `$HOME/.codex/skills`。
