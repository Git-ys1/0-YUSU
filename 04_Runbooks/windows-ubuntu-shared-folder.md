# Windows / Ubuntu 共享文件夹指南

目标：Windows Codex 和 Ubuntu 20.04 Codex 读写同一份知识库，而不是复制两份。

## 已查证结论

已按 Ubuntu、Microsoft、OpenAI、Obsidian 官方资料核对过。双系统共享不是“建一个 Markdown 文件夹就行”，关键是 Ubuntu 必须挂载 Windows 所在 NTFS 数据分区，并且 Windows 不能处于 Fast Startup/休眠留下的半关闭状态。

Microsoft 文档说明 Fast Startup 是一种使用休眠文件的关机方式，看起来像完整关机，但实际经历了 S4；Windows 默认 shutdown 会走 Fast Startup，而 restart 才是 full shutdown。Ubuntu 文档也明确警告：Windows 休眠或混合关机后，从 Ubuntu 写 NTFS 会有变更丢失或拒绝写入风险。

## 推荐策略

1. 以 Windows 当前目录作为主副本：`F:\AcademicHub\0#YUSU`
2. Ubuntu 挂载同一个 Windows/NTFS 分区。
3. Ubuntu 侧创建稳定软链接：`~/YUSU-KB`
4. 两边都设置环境变量 `YUSU_KB_ROOT`。
5. 任何 Codex 先通过 `YUSU_KB_ROOT` 找知识库。

## Windows 设置

当前 PowerShell 会话：

```powershell
$env:YUSU_KB_ROOT = "F:\AcademicHub\0#YUSU"
```

永久环境变量：

```powershell
setx YUSU_KB_ROOT "F:\AcademicHub\0#YUSU"
```

验证：

```powershell
Test-Path "$env:YUSU_KB_ROOT\00_START_HERE_FOR_CODEX.md"
```

如果从命令行额外启动 Windows PowerShell 5.1，建议带 `-NoProfile`，避免用户 profile 噪声影响判断：

```powershell
powershell.exe -NoProfile -Command "Test-Path 'F:\AcademicHub\0#YUSU\00_START_HERE_FOR_CODEX.md'"
```

Windows 共享前置检查：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\windows-shared-preflight.ps1
```

如果输出 `Fast Startup HiberbootEnabled = 1`，说明 Fast Startup 开启。Ubuntu 写入前应关闭 Fast Startup/休眠相关状态，避免 NTFS unsafe state。

## WSL 情况

如果 Ubuntu 是 WSL，通常直接使用：

```bash
export YUSU_KB_ROOT="/mnt/f/AcademicHub/0#YUSU"
test -f "$YUSU_KB_ROOT/00_START_HERE_FOR_CODEX.md"
```

写入 `~/.bashrc`：

```bash
echo 'export YUSU_KB_ROOT="/mnt/f/AcademicHub/0#YUSU"' >> ~/.bashrc
```

## 原生 Ubuntu 20.04 双系统

先找 Windows 的 F 盘分区：

```bash
lsblk -f
```

创建挂载点：

```bash
sudo mkdir -p /mnt/yusu-f
```

Ubuntu 20.04 通常使用 `ntfs-3g`：

```bash
sudo apt update
sudo apt install -y ntfs-3g
sudo mount -t ntfs-3g -o uid=$(id -u),gid=$(id -g),windows_names,big_writes UUID=<F_DRIVE_UUID> /mnt/yusu-f
```

创建稳定软链接：

```bash
ln -s "/mnt/yusu-f/AcademicHub/0#YUSU" "$HOME/YUSU-KB"
echo 'export YUSU_KB_ROOT="$HOME/YUSU-KB"' >> ~/.bashrc
```

验证：

```bash
source ~/.bashrc
test -f "$YUSU_KB_ROOT/00_START_HERE_FOR_CODEX.md"
bash "$YUSU_KB_ROOT/tools/check-shared-access.sh" ubuntu
```

## 双系统写入注意

- Windows 必须完全关机，不要让 NTFS 分区处于休眠或快速启动锁定状态。
- 如果 Ubuntu 报 NTFS unsafe state，需要先回 Windows 完全关机，并关闭 Fast Startup。
- 不要在 Windows 和 Ubuntu 同时打开并写入同一个 Obsidian vault。
- 同一时间只让一个系统的 Codex 作为写入者。
- 路径里有 `#`，Linux shell 中请始终加引号。

## 持久挂载

确认手动挂载成功后，再考虑写入 `/etc/fstab`：

```fstab
UUID=<F_DRIVE_UUID> /mnt/yusu-f ntfs-3g uid=1000,gid=1000,windows_names,big_writes,nofail,x-gvfs-show 0 0
```

写入前先备份：

```bash
sudo cp /etc/fstab /etc/fstab.bak.$(date +%F-%H%M%S)
```

`uid` / `gid` 应替换为 Ubuntu 用户自己的 `id -u` 和 `id -g` 输出。

## 给未来 Codex 的约定

未来 Codex 不应硬编码某个系统路径。优先使用：

```text
YUSU_KB_ROOT
```

如果变量不存在，再使用 `tools/resolve-kb-root.*` 自动探测。

## Sources

- Ubuntu Mounting Windows Partitions: https://help.ubuntu.com/community/MountingWindowsPartitions
- Ubuntu ntfs-3g manpage: https://manpages.ubuntu.com/manpages/jammy/man8/mount.ntfs.8.html
- Microsoft System Power States: https://learn.microsoft.com/en-us/windows/win32/power/system-power-states
