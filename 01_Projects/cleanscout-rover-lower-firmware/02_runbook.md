# Runbook

## Environment

- OS: Windows
- Shell: PowerShell
- RF1 toolchain: Keil MDK + STM32CubeProgrammer + ST-Link
- Mechanical-arm baseline: 当前已验证可直接用 `template.hex` 烧录；本机尚未复现一套新的机械臂本地 Keil 编译命令

## First Sanity Check

在做任何下位机工作前先运行：

```powershell
git status --short --branch
```

确认你是否在真正的仓库工作区里，而不是 `_local/` 某个旧副本。

## RF1 Formal Build

仓库根目录执行：

```powershell
.\firmware\openrf1_motion_controller\scripts\build.ps1
```

如本机 Keil 不在默认路径，手动指定：

```powershell
.\firmware\openrf1_motion_controller\scripts\build.ps1 `
  -Uv4Path 'C:\Keil_v5\UV4\UV4.exe'
```

成功产物：

```text
firmware/openrf1_motion_controller/Build/Objects/OpenRF1_Motion.hex
```

## RF1 Flash

```powershell
.\firmware\openrf1_motion_controller\scripts\flash.ps1
```

如果要编译后直接烧录：

```powershell
.\firmware\openrf1_motion_controller\scripts\flash.ps1 -BuildFirst
```

## RF1 Serial Debug

默认入口：

```powershell
.\tools\openrf1_serial_probe.ps1
```

常用例子：

```powershell
# 低速前进
.\tools\openrf1_serial_probe.ps1 -WheelA 0.05 -WheelB 0.05 -WheelC 0.05 -WheelD 0.05

# 中速前进
.\tools\openrf1_serial_probe.ps1 -WheelA 0.15 -WheelB 0.15 -WheelC 0.15 -WheelD 0.15

# 后退
.\tools\openrf1_serial_probe.ps1 -WheelA -0.10 -WheelB -0.10 -WheelC -0.10 -WheelD -0.10

# 左转
.\tools\openrf1_serial_probe.ps1 -WheelA -0.10 -WheelB -0.10 -WheelC 0.10 -WheelD 0.10

# 左移
.\tools\openrf1_serial_probe.ps1 -WheelA 0.10 -WheelB -0.10 -WheelC -0.10 -WheelD 0.10
```

## RF1 Expected Serial Output

至少应能看到：

- `CSR_RF1_READY`
- `ACK:W / ACK:M / ACK:E / ACK:D / ACK:STOP`
- `VEL,...`
- `PWM,...`
- `NAVDBG,...`
- `ENC,...`
- `DBG,...`

## Mechanical-Arm Baseline Read-Only Board Check

在烧任何导入的 `hex` 之前，先做 ST-Link 只读确认：

```powershell
$cli = 'F:\CodeForge\STM32CubeIDE_2.1.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cubeprogrammer.win32_2.2.400.202601091506\tools\bin\STM32_Programmer_CLI.exe'
& $cli -c port=SWD mode=UR reset=HWrst -r32 0x08000000 4
```

当前验证到的目标信息是：

- `STM32F101/F103 High-density`
- `Device ID 0x414`
- `256 KB`

## Mechanical-Arm Baseline Flash

当前已验证的烧录链路：

```powershell
$cli = 'F:\CodeForge\STM32CubeIDE_2.1.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.cubeprogrammer.win32_2.2.400.202601091506\tools\bin\STM32_Programmer_CLI.exe'
$hex = (Resolve-Path 'firmware\mechanical_arm_official_baseline\Output\template.hex').Path
& $cli -c port=SWD mode=UR reset=HWrst -w $hex -v -rst
```

注意：

- 这是“烧官方冻结基线”的路径，不是后续机械臂自研迭代路径。
- `template.build_log.htm` 只能证明这份例程历史上编译过，不能证明当前机器已经具备同样的 Keil 环境。

## Files You Read First

RF1：

1. `firmware/openrf1_motion_controller/README.md`
2. `docs/STM32F103RCT6/OpenRF1_开发速查.md`
3. `docs/000操作指令`
4. `docs/SOFTWARE/C-3.6.0_openrf1_firmware_normalization.md`

机械臂：

1. `firmware/mechanical_arm_official_baseline/README.md`
2. `docs/SOFTWARE/C-3.7.0_mechanical_arm_baseline_freeze.md`
3. `firmware/mechanical_arm_official_baseline/User/main.c`
4. `firmware/mechanical_arm_official_baseline/User/Components/y_global/y_global.c`

## Mechanical Arm Manual Pose Tuning

当末端相机负载改变、`001/002/003` 姿态需要重新找平衡时，不要继续靠代码侧猜关节方向。
先让操作者在 OrangePi 远程桌面看着实物调姿：

```bash
cd ~/rk3588_ai/arm_tracking_demo
~/rk3588_ai/rknn_lite_env/bin/python3 tools/arm_servo_tune.py
```

常用交互命令：

```text
read 0-5
set 2=2000,3=1480 1500
nudge 2=-50 1000
nudge 3=50 1000
save 1-3
```

如果 `003` 这类舵机能动作但 `PRAD` 偶发无回包，用显式值保存：

```bash
~/rk3588_ai/rknn_lite_env/bin/python3 tools/save_arm_start_pose.py \
  --values 1=1700,2=2000,3=1480
```

保存会更新 `arm_tracking_demo/config/arm_track_config.yaml` 的启动姿态，并同步 `pitch_pwm_neutral`。

## Last Verified

- RF1 正式工程收口：2026-06-07
- 机械臂官方基线识别 + 烧录：2026-06-07
