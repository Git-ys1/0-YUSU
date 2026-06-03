param(
    [string]$KbRoot = "F:\AcademicHub\0#YUSU"
)

$ErrorActionPreference = "Stop"

$result = [ordered]@{}
$result["KB Root"] = $KbRoot
$result["KB Exists"] = Test-Path -LiteralPath (Join-Path $KbRoot "00_START_HERE_FOR_CODEX.md")

$driveName = (Split-Path -Qualifier $KbRoot).TrimEnd(":")
$volume = Get-Volume -DriveLetter $driveName -ErrorAction Stop
$result["Drive"] = "$($volume.DriveLetter):"
$result["File System"] = $volume.FileSystem
$result["Volume Label"] = $volume.FileSystemLabel
$result["Health Status"] = $volume.HealthStatus
$result["Size Remaining GB"] = [math]::Round($volume.SizeRemaining / 1GB, 2)

$hiberbootPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
try {
    $hiberboot = Get-ItemProperty -LiteralPath $hiberbootPath -Name HiberbootEnabled -ErrorAction Stop
    $result["Fast Startup HiberbootEnabled"] = $hiberboot.HiberbootEnabled
} catch {
    $result["Fast Startup HiberbootEnabled"] = "unknown"
}

$hibernate = powercfg /a 2>$null
$result["powercfg /a"] = ($hibernate -join " | ")

[pscustomobject]$result | Format-List

Write-Output ""
Write-Output "Interpretation:"
Write-Output "- File System should normally be NTFS for the Windows data partition."
Write-Output "- If HiberbootEnabled is 1, Windows Fast Startup is enabled; disable it before Ubuntu writes this partition."
Write-Output "- Ubuntu must still run 04_Runbooks/ubuntu-first-run.md and then tools/check-shared-access.sh."

