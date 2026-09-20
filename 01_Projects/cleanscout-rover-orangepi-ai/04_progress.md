# Progress

## 2026-07-15 C-5.2.4 Fixed-View Calibration And Reachable Dry-Run

- CleanScout `main` published commit `29242c6c` with the fixed-view RGB-D calibration, target-coordinate validator, staged grasp planner, calibration evidence, and simplified field commands.
- Thirteen unique camera/base correspondences were audited. The maximum-consensus rigid fit retained 11 points and rejected two outliers at 64.835 mm and 32.615 mm.
- The accepted `T_base_camera_reference` passed its gate: RMSE 5.848 mm, maximum error 9.710 mm, and `det(R)=1.0`; matrix direction is `p_base = R * p_camera + t`.
- At the fixed reference pose `[1380,1909,1900,620,1500,1500]`, live `PRAD` readback returned `1380,1911,1900,620,1500` for Servo000--004. Servo005 still has no position reply.
- The current bottle target passed workspace and IK checks with `pitch_deg=35`; dry-run completed OPEN, PRE_GRASP, seven horizontal APPROACH waypoints, CLOSE, and LIFT while Servo004 stayed at 1500.
- This is not a real-grasp success claim. `kinematics.calibrated=false` and `serial.joint_pwm_calibrated=false` remain mandatory blockers until local link/TCP and PWM-angle calibration are accepted.
- `arm_servo_tune.py` now correctly parses signed `nudge` values; both board-side `PRAD` readback and the signed-delta parser were verified after deployment.

## 2026-07-13 C-5.2.0B Official-KMS And Camera/TCP Boundary

- CleanScout `main` published checkpoint `6513c482` for the honest failed-grasp boundary, then `4613e2db` for the official-firmware convergence.
- The real 2026-07-13 attempt did not grasp the bottle: RGB-D lock worked, but PRE_GRASP moved the D435 into the bottle. Battery depletion stopped further close/lift verification.
- Official firmware review proves `$KMS:x,y,z,time!` owns Servo000--003 only. Servo004 and Servo005 are separate stages; Python no longer fabricates those two PWM outputs.
- D435 factory RGB/infrared/depth intrinsics and extrinsics remain active through librealsense `depth -> color` alignment. They do not provide the robot-installation transform `T_tool_camera_color_optical`.
- Hardware relation is frozen: D435 is mounted above the non-rotating Servo004 stator housing; TCP/gripper is downstream of the Servo004 rotor and Servo005. The first grasp baseline therefore fixes Servo004 at PWM 1500.
- Uncalibrated reference matrices are now zero/unset placeholders. Real execution requires hand-eye, reference TCP, and joint/PWM calibration gates; dry-run perception prints `GRASP_PLAN_BLOCKED` instead of a misleading plan.
- Measurement and calibration input sheet: `docs/VERIFY/C-5.2.0_arm_camera_tcp_measurement_sheet.md`.

## Current Status

**State**: C-5.0.9 three-axis visual tracking remains the stable baseline; C-5.1.1 now has real aligned RGB-D validation on a rebuilt D435 in addition to dry-run grasp-pipeline checks
**Current phase**: RK3588 YOLO11 visual-servo plus D435 RGB-D grasp prework; keep `arm_tracking_demo/` stable while calibrating `arm_grasp_pipeline/` separately

## Stable Today

- RKNN Runtime 2.3.2 repaired and validated.
- C API and RKNNLite Python both prove NPU access.
- YOLO11 image detection runs without torch/LD_PRELOAD dependency.
- YOLO11 USB camera window and headless video mode both run.
- CleanScout main published the lightweight OrangePi baseline in commit `b78f372`.
- CleanScout main published C-5.0.1 arm-tracking dry-run demo in commit `cc12f95e`.
- CleanScout main published C-5.0.5A/C-5.0.5B for current OrangePi arm tracking in commits `3dc970d8` and `b8009323`.
- CleanScout main published C-5.0.6 for Servo001 lift-only tracking in commit `4fe29bdf`.
- CleanScout main published C-5.0.7 for Servo003 pitch-only tracking in commit `001e08f9`, then C-5.0.7A fixed Servo003 pitch direction in commit `bb81e83f`.
- CleanScout main published C-5.0.8 for initial Servo000 yaw + Servo001 lift + Servo003 pitch combined tracking in commit `b5b0fb5c`.
- CleanScout main published C-5.0.8A in commit `6af4fd8d` to keep the no-config stop fallback aligned with combined axes `[0,1,3]`.
- Board-side current files exist at `~/rk3588_ai/arm_tracking_demo`.
- C-5.0.5 validates `bottle` as target class and Servo000 yaw as the only live tracking axis.
- C-5.0.6 validates Servo001 `lift` as a separate vertical tracking axis while Servo002/003/004/005 keep the manually tuned safe pose.
- C-5.0.7 validates Servo003 `pitch` as the end-effector fine vertical tracking axis while Servo000/001/002/004/005 stay untouched; C-5.0.7A sets `invert_pitch=false` after live testing showed target-below moved up.
- C-5.0.9 keeps the C-5.0.7A pitch direction baseline: `invert_pitch=false` and `driver.pitch_pwm_sign=-1`; do not change the driver sign without a real-motion check.
- C-5.0.9 standardizes the tracking startup pose as `0=1500,1=1907,2=1900,3=900,4=1500,5=1500`.
- C-5.0.9 adds metrics/score response testing and reduced the same perturbation test score from `347.8` to `188.4` by slowing command rate, increasing error filtering, and reducing yaw/pitch step limits.
- C-5.1.1 adds `OrangePi/rk3588_ai/arm_grasp_pipeline/` as a separate RGB-D grasp prework path: D430 depth-only smoke, D435 RGB-D smoke, pixel-to-camera geometry, 5DoF IK, RF1 text-protocol mock execution, and ROS compatibility data boundaries.
- C-5.1.1 board smoke on `192.168.8.148` passed `compileall`, `tools/ik_sweep_check.py`, `tools/mock_grasp_cycle.py`, and `tools/mock_grasp_cycle.py --print_ros` under Python 3.8.10; ROS-compatible `GraspEventMsg` / `ArmTargetMsg` boundary is actually exercised.
- D430 depth-only smoke is now validated on OrangePi: pyrealsense2==2.55.1.6486 was installed in ~/rk3588_ai/rknn_lite_env, D430 serial 045322072042 / firmware 5.17.0.10 was detected, and tools/d430_depth_smoke.py --frames 30 produced 29/30 valid ROI depth frames.
- On 2026-07-10 the known-good D430 depth module was transplanted into the D435 RGB assembly. OrangePi identifies it as Intel RealSense D435 with depth serial `045322072042`; an isolated librealsense/pyrealsense2 2.56.5 RSUSB build produced 60/60 valid aligned RGB-D ROI frames at 640x480@30.
- Depth extraction now has no default near/far clipping. It rejects only zero, negative, NaN, and Inf values; the observed hardware near capability of about 0.17 m is a device note, not a software threshold.
- Board-side audit reports exist at `~/rk3588_ai/debug_logs/arm_visual_tracking/`.

## Not Finished

- C-5.0.9 still needs user-observed subjective confirmation that the new smoother parameters feel better on the live camera/arm view.
- D435 alignment validation is complete, but full real RGB-D grasping, hand-eye calibration, ROS fusion, and pitch/gripper calibration remain future work.
- No ROS topic publishing yet.
- No complete IK, grasping, fisheye calibration, or hand-eye calibration.
- No multithreaded camera/inference pipeline yet.
- No model management or conversion pipeline formalized in repo.

## Latest Milestones

| Date | Milestone | Evidence |
| --- | --- | --- |
| 2026-06-09 | RKNN Runtime corruption found and fixed | `RK3588_RKNN_NPU_DIAGNOSIS_REPORT.md` |
| 2026-06-09 | YOLO11 NumPy DFL fix validated | `YOLO11_VISUAL_DEMO_FIX_REPORT.md` |
| 2026-06-09 | USB camera YOLO11 real-time demo validated | `YOLO11_CAMERA_DEMO_REPORT.md` |
| 2026-06-10 | OrangePi baseline published to CleanScout main | commit `b78f372` |
| 2026-06-10 | Non-ROS arm visual-tracking dry-run demo published | commit `cc12f95e`; `OrangePi/rk3588_ai/arm_tracking_demo/` |
| 2026-07-03 | C-5.0.5 bottle-only Servo000 yaw tracking implemented and board-smoked | commits `3dc970d8`, `b8009323`; `docs/VERIFY/C-5.0.5_arm_bottle_yaw_tracking.md` |
| 2026-07-03 | C-5.0.6 bottle-only Servo001 lift tracking implemented and board-smoked | commit `4fe29bdf`; `docs/VERIFY/C-5.0.6_arm_bottle_lift_tracking.md` |
| 2026-07-03 | C-5.0.7 bottle-only Servo003 pitch tracking implemented and board-smoked | commit `001e08f9`; `docs/VERIFY/C-5.0.7_arm_bottle_pitch_tracking.md` |
| 2026-07-03 | C-5.0.7A Servo003 pitch direction corrected | commit `bb81e83f`; `invert_pitch=false` because target below previously moved up |
| 2026-07-06 | C-5.0.8 bottle three-axis combined tracking implemented and board dry-run checked | commits `b5b0fb5c`, `6af4fd8d`; `docs/VERIFY/C-5.0.8_arm_bottle_combined_tracking.md` |
| 2026-07-06 | C-5.0.9 standard startup pose and response-score tuning validated on board | `docs/VERIFY/C-5.0.9_arm_tracking_start_pose_response_tuning.md`; board logs `~/rk3588_ai/debug_logs/arm_tracking_eval/20260706-173340/` and `20260706-173547/` |
| 2026-07-09 | C-5.1.1 RGB-D grasp prework split from visual tracking and board-smoked | `OrangePi/rk3588_ai/arm_grasp_pipeline/`; `docs/VERIFY/C-5.1.1_rgbd_grasp_ros_ready.md`; D430 smoke and ROS-boundary smoke passed on board |
| 2026-07-10 | Rebuilt D435 aligned RGB-D pipeline validated with no artificial range limits | 60/60 aligned RGB-D ROI frames; isolated RSUSB 2.56.5 runtime; `docs/VERIFY/C-5.1.1_rgbd_grasp_ros_ready.md` |
