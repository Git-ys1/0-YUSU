# Architecture

## Current Shape

```text
CleanScout_rover/OrangePi/
└── rk3588_ai/
    ├── README.md
    ├── UPSTREAMS.md
    ├── 任务书.txt / 任务书2 / 任务书3
    ├── *_REPORT.md
    ├── test_*.py / rknn_capi_smoke.c
    ├── model_zoo_overlay/
    │   └── examples/yolo11/python/yolo11.py + yolo11_camera.py
    └── *.jpg 验收图片
```

板端预期运行目录：

```text
~/rk3588_ai/
├── rknn_model_zoo/      # 官方上游 clone，不提交到主仓
├── rknn_lite_env/       # 板端虚拟环境，不提交
├── models/              # RKNN/ONNX/PT 模型，不提交
└── debug_logs/          # 运行日志和视频，不提交
```

## Data Flow

```text
USB Camera / image file
-> OpenCV capture / image loading
-> letterbox + BGR/RGB transform
-> RKNNLite / RKNN Runtime 2.3.2
-> RKNPU driver 0.9.6 on RK3588
-> YOLO11 outputs
-> NumPy DFL + post_process
-> draw boxes / save image / show OpenCV window
```

## Upstream Boundary

- Official upstream: `https://github.com/airockchip/rknn_model_zoo.git`
- Version used: tag `v2.3.2`, commit `bad6c73`
- CleanScout changes are stored as overlay, not as a vendored fork.

## Future Integration Boundary

OrangePi AI is expected to become the perception side for mechanical-arm work. The first stable interface should be detection results, not direct servo control. ROS publication and grasp planning are later layers.

