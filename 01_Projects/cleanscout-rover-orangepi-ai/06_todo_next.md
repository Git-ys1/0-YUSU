# Todo Next

1. Add a ROS-facing detection publisher only after the camera demo remains stable as a standalone script.
2. Define a mechanical-arm perception contract: class, confidence, image-space box, timestamp, and optional target point.
3. Add a model provenance document for `official_yolo11.rknn`: source ONNX, conversion command, toolkit version, quantization choice.
4. Benchmark lower-latency options: frame queue, latest-frame-only capture thread, smaller model, C++/C API pipeline.
5. If the board is reinstalled or Runtime is updated, rerun C API smoke and Python RKNNLite smoke before touching YOLO code.

