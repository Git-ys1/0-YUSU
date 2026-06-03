# Shared Access Verification

这个文件用于验证 Windows 和 Ubuntu 是否真的在读写同一份知识库。

## Windows 侧

```powershell
$env:YUSU_KB_ROOT = "F:\AcademicHub\0#YUSU"
.\tools\windows-shared-preflight.ps1
.\tools\check-shared-access.ps1 -Actor windows
```

输出里应出现：

```text
KB root: F:\AcademicHub\0#YUSU
Wrote:
```

## Ubuntu 侧

先按 `windows-ubuntu-shared-folder.md` 挂载并设置 `YUSU_KB_ROOT`，然后：

```bash
bash "$YUSU_KB_ROOT/tools/check-shared-access.sh" ubuntu
```

## 判定标准

如果 Ubuntu 写入的文件出现在：

```text
F:\AcademicHub\0#YUSU\00_Inbox\shared-checks\
```

并且 Windows 也能读到，那么共享成功。

如果 Ubuntu 只能读不能写，优先检查：

1. Windows 是否关闭 Fast Startup/休眠。
2. NTFS 分区是否被 Windows 标记为 unsafe state。
3. Ubuntu 是否用只读方式挂载。
4. 路径里的 `#` 是否在 shell 里加了引号。
