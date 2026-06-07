# Topic Map

主题索引。

## Knowledge System

- [[01_Projects/yusu-codex-knowledge-vault/README]]
- [[04_Runbooks/system-decisions]]
- [[04_Runbooks/codex-retrieval-workflow]]
- [[04_Runbooks/codex-ingestion-guide]]
- [[04_Runbooks/mature-project-ingestion]]
- [[04_Runbooks/windows-ubuntu-shared-folder]]
- [[04_Runbooks/shared-access-verification]]
- [[04_Runbooks/github-sync]]

## Automation And Windows Desktop Tools

- [[01_Projects/auto-play/README]]
- [[03_CrossProject/patterns]]: 自动化层级阶梯、可观察自动化 UI
- [[03_CrossProject/pitfalls]]: 坐标宏回放没有恢复起点、覆盖用户设置和用户宏文件
- [[03_CrossProject/tooling]]: Windows desktop tool launchers、Windows GUI automation input stack、宏录制器冒烟测试
- [[03_CrossProject/architecture-decisions]]: 保持自动化实验边界

## Embedded And Instrument Apps

- [[01_Projects/simple-oscilloscope/README]]
- [[03_CrossProject/patterns]]: Transport-protocol-acquisition-processing-UI layering、Hardware release requires artifact plus device verification
- [[03_CrossProject/pitfalls]]: Instrument UI readouts placed in data coordinates、High-rate firmware claims made by changing constants only、Sample-index trigger quantization causes visible instrument jitter
- [[03_CrossProject/tooling]]: Keil plus STM32CubeProgrammer Windows release loop、Windows PyInstaller rebuilds can fail when the packaged exe is still running

## CleanScout Robotics Software

- [[01_Projects/cleanscout-rover-vue3/README]]: V 线前后端、public-edge、OpenClaw、ESP32-CAM、ASR；source `Git-ys1/CleanScout_rover/vue3`
- [[03_CrossProject/patterns]]: Outbound relay/worker behind NAT
- [[03_CrossProject/pitfalls]]: Duplicate UI intent as device toggle; long-lived MJPEG timeout
- [[03_CrossProject/architecture-decisions]]: Product UI wraps high-privilege local capabilities through backend adapters
