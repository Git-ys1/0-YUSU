# Todo Next

## C-5.2.4 staged unlock before real PRE_GRASP

1. Keep the accepted 11-point fixed-view matrix unless the camera bracket, arm base, or reference pose moves; do not redo camera/base calibration merely to tune IK.
2. Use `tools/arm_servo_tune.py`: read first, then nudge one Servo000--003 joint by only 20--50 PWM and record direction plus at least two PWM/physical-angle pairs per joint.
3. Recheck axis-to-axis link lengths and define TCP as the center between the two fingers at the intended grasp closure, then update kinematics evidence without location-specific PWM fitting.
4. Measure Servo005 full-open, bottle-contact, and safe-close PWM/readback with a charged battery.
5. Unlock only `max_stage=pre_grasp`; have the operator confirm the open gripper stops in front of the bottle without contact. Only then enable APPROACH, CLOSE, and LIFT one stage at a time.

## C-5.2.0B calibration work before the next real grasp

1. Keep Servo004 fixed at PWM 1500 and do not enable real auto-grasp yet.
2. Recharge the arm battery, then separately validate Servo005 full-open/full-close safe PWM and physical jaw width; current evidence proves P0600 opens, but P2400 close-end is not yet accepted.
3. Measure L0--L3, Servo003/004/TCP offsets, jaw geometry, table height, bottle diameter/grip height, and the RGB optical-center offset using `docs/VERIFY/C-5.2.0_arm_camera_tcp_measurement_sheet.md`.
4. Record PWM/physical-angle points for Servo000--004 and the exact TCP pose at `[1380,1909,1900,620,1500,1500]`.
5. Capture at least 15 calibration-board poses with Servo004 fixed at 1500, solve `T_tool_camera_color_optical`, then validate on at least five held-out poses.
6. Only after the three calibration gates pass, test OPEN, PRE_GRASP, APPROACH, CLOSE, LIFT, and RETURN_VERIFY one stage at a time; do not run the whole cycle first.

# C-5.1.1 immediate next steps

1. Use `source ~/rk3588_ai/scripts/use_realsense_rsusb.sh` before RealSense Python tests; do not mix pip `pyrealsense2 2.55.1` with librealsense 2.56.5 again.
2. Wait for the long USB 3.0 cable, mount the rebuilt D435 at the actual end-effector pose, then repeat the 60-frame aligned RGB-D smoke before calibration.
3. Calibrate the rebuilt D435 hand-eye transform on the final mechanical mount. The current matrix is only a reference initial value.
4. Keep depth extraction unbounded by default. Apply workspace/reachability limits only after camera-to-base transformation and in IK/safety logic.
5. Keep `arm_tracking_demo/` as the stable C-5.0.9 bottle visual-servo baseline; integrate RGB-D detection into `arm_grasp_pipeline/` instead of destabilizing the tracker.
6. Do not use bbox area as distance. Aligned RealSense depth ROI median remains the accepted distance source for grasp planning.
7. Treat `docs/00最新参考/` and `docs/00任务书及代码包/` as ignored local reference/input material; migrate only minimal rewritten code into formal repo paths.

## Previous tracking backlog

1. Have the operator run C-5.0.9 three-axis real tracking from the standard pose and judge whether the second-round smoother parameters feel better in the remote-desktop camera view.
2. If tracking is still too slow but smooth, raise only `max_yaw_delta` from `0.018` to `0.020`; do not change `driver.pitch_pwm_sign`.
3. If tracking is still jittery near center, tune `dead_zone_px` and `error_filter_alpha` before increasing `kp_yaw`.
4. Tune `combined_lift_error_px` and `combined_lift_rate_divider` from live behavior. If the arm feels too lazy vertically, lower the threshold gradually; if it fights pitch, raise the threshold or divider.
5. Decide whether combined vertical control needs Servo003 range-margin logic, so 001 joins when 003 nears `pitch_min/pitch_max`.
6. Add a ROS-facing detection publisher only after the standalone camera + arm demo remains stable.
7. Define a mechanical-arm perception contract: class, confidence, image-space box, timestamp, and optional target point.
8. Add a model provenance document for `official_yolo11.rknn`: source ONNX, conversion command, toolkit version, quantization choice.
9. Benchmark lower-latency options: frame queue, latest-frame-only capture thread, smaller model, C++/C API pipeline.
10. If the board is reinstalled or Runtime is updated, rerun C API smoke and Python RKNNLite smoke before touching YOLO code.

