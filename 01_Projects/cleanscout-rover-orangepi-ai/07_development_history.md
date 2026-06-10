# Development History

## Phase 1: NPU looked hopeless because `init_runtime()` segfaulted

The first task was not ordinary YOLO debugging. Both the user's custom RKNN and the official YOLO11 RKNN crashed at `RKNNLite.init_runtime()` on Orange Pi 5 Max. The investigation followed a diagnostic-first rule: no OS reinstall, no ROS deletion, no `.bashrc` changes, no destructive cleanup.

The decisive evidence was binary integrity, not a Python stack trace. `/usr/lib/librknnrt.so` claimed to be 2.3.2 by strings, but was 28 bytes shorter than the official file; `readelf` detected a broken section table and `ctypes.CDLL` segfaulted. Replacing it with the official v2.3.2 aarch64 runtime fixed both C API and Python RKNNLite.

## Phase 2: YOLO11 ran inference but died in visualization

After runtime repair, official YOLO11 entered postprocess and then failed inside `dfl()` because torch was imported late. Import-order testing showed a static TLS/libgomp conflict. The stable fix was to remove the torch dependency from the board-side postprocess and implement DFL in NumPy.

The NumPy DFL path was validated against torch with `max_abs_error: 0.0`, then used to produce the final `yolo11_result.jpg`.

## Phase 3: Camera demo became the first real visual baseline

The third task created `yolo11_camera.py` without modifying the already fixed image script. It uses OpenCV V4L2 capture, auto-falls back away from the UVC metadata node, runs YOLO11 RKNN inference, draws boxes/FPS, supports `q`/ESC, and releases camera/NPU resources.

NoMachine GUI was tested with a real `q` key event. Headless video and snapshot were also validated. This is the first stable OrangePi perception baseline suitable for future mechanical-arm vision work.

## Phase 4: Windows repo publication had to avoid vendor bloat

The local Windows workspace contained a full `rknn_model_zoo` clone and a large venv. These are required for development but are not CleanScout-owned source. The repository now publishes only reports, scripts, selected images, task books, and `model_zoo_overlay/`, plus explicit upstream recovery instructions.

