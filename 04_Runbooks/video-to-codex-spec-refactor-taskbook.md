任务名称：
将 Azure-Samples/video-analysis-with-aoai 重构为 video-to-codex-spec：视频教程自动学习与工程复现系统

目标仓库：
https://github.com/Azure-Samples/video-analysis-with-aoai.git

第一步：
克隆目标仓库到本地。

执行：
git clone https://github.com/Azure-Samples/video-analysis-with-aoai.git

进入克隆后的仓库根目录，在该仓库根目录内完成全部重构工作。

背景：
该仓库当前定位是使用 Azure OpenAI 多模态模型分析视频，核心流程包括视频分段、按 FPS 抽帧、时间戳标注、可选 Whisper 转写、再把帧和转写发送给模型生成描述、摘要或 insight。这个基础可以复用，但当前目标不是视频摘要，也不是视频问答，而是让 Codex 能够从视频教程中自动提取工程复现规范，并继续按照视频内容完成后续构建工作。

最终目标：
把原项目重构为一个“视频教程 → Agent 可执行施工说明书 → Codex 自动复现工程”的系统。

系统新名称：
video-to-codex-spec

不要做 MVP。
不要做最小实现。
不要只改 prompt。
不要只保留 Streamlit Demo。
不要只输出视频摘要。
不要只输出时间轴。
不要只输出问答索引。
必须直接重构到可验收状态。

一、核心输入输出

输入：
本地视频文件，支持 mp4、mkv、mov、webm 等常见格式。

输出：
必须生成 agent_context/ 目录。

agent_context/ 必须包含：

1. goal.md
说明视频教程最终要构建什么、最终产物是什么、项目目标是什么。

2. environment.md
提取视频中出现或可明确推断的环境信息，包括但不限于：
操作系统、Python、Node.js、npm、conda、Docker、CUDA、ROS、数据库、Web 服务、云平台、依赖库、端口号、路径。

3. step_by_step.md
这是最核心文件。
必须把视频内容整理成“真实工程执行顺序”，而不是简单按视频时间顺序堆叠。
格式必须是：
step_001
step_002
step_003
...
每一步包含：
目标、操作、涉及文件、涉及命令、预期结果、检查方法、不确定项。

4. commands.sh
提取视频中出现的所有可执行命令。
包括：
git、pip、conda、npm、pnpm、yarn、docker、docker compose、apt、curl、wget、python、uv、cargo、go、make、cmake、ros、ssh、scp、rsync、systemctl、nginx、pm2 等。
每条命令前写注释说明来源时间戳和用途。
不要凭空编命令。
可以把推断命令标记为 inferred。

5. file_changes.md
提取视频中创建、修改、打开、编辑过的文件。
包括：
.py、.js、.ts、.tsx、.vue、.json、.yaml、.yml、.env、Dockerfile、docker-compose.yml、requirements.txt、package.json、README、nginx 配置等。
必须记录：
文件路径、修改目的、关键内容、来源时间戳、是否来自 OCR、是否来自语音、是否为推断。

6. ui_operations.md
提取视频里的界面操作。
包括：
VS Code、浏览器、宝塔、GitHub、Docker Desktop、终端、网页后台、云平台控制台、IDE 菜单、按钮点击、表单填写等。
必须按操作顺序整理。

7. checkpoints.md
整理每个关键阶段完成后应该如何验证。
例如：
服务启动成功、端口监听成功、网页可访问、日志出现指定文本、Docker 容器 running、测试命令通过、文件生成成功。

8. errors_and_fixes.md
提取视频里出现的报错、warning、异常、失败命令、修复动作。
没有发现时写“未从视频中明确发现”，不要编造。

9. timeline.json
完整时间轴。
每个片段包含：
start_time、end_time、关键帧路径、ASR 文本、OCR 文本、视觉描述、识别出的动作、命令、文件、UI 操作、不确定项。

10. video_index.json
供后续 Codex 检索使用。
按时间片、步骤、命令、文件、错误、检查点建立索引。

二、重构方向

原项目当前大致是：
视频
→ 分段
→ FPS 抽帧
→ 可选 Whisper
→ Azure OpenAI 分析
→ 摘要 / insight

必须重构为：
视频
→ 场景切分
→ 关键帧提取
→ 关键帧去重
→ OCR
→ ASR
→ 视觉动作分析
→ 命令/文件/UI/错误提取
→ 工程步骤重排
→ Agent Context 生成
→ Codex 使用 Agent Context 执行后续构建

三、必须保留和复用的能力

保留可复用部分：
1. 本地视频输入能力。
2. 视频 URL 能力，如果原仓库已有且维护成本不高则保留。
3. 视频分段能力。
4. FPS 抽帧能力。
5. 时间戳标注能力。
6. Whisper 接口能力。
7. 现有 Azure OpenAI 调用能力，但不能再写死为唯一 provider。

原仓库中已有的视频分段、抽帧、时间戳、Whisper 和多模态模型分析流程可以作为底座，不要从零重写所有底层处理。该仓库当前 README 的项目定位是演示 Azure OpenAI 多模态模型分析视频，并支持分段、抽帧、时间戳、可选 Whisper 转写和 prompt 驱动分析；本任务是在此基础上重构目标，而不是另起炉灶。

四、必须新增的模块

1. CLI 主入口

新增命令行入口，例如：

python -m video_to_codex_spec analyze --video <video_path> --output <output_dir>

或：

python video_to_codex_spec.py analyze --video <video_path> --output <output_dir>

必须支持：
--video
--output
--fps
--segment-seconds
--scene-detect
--ocr
--asr
--vision-provider
--language
--max-frames-per-segment
--force
--reuse-cache

不要只依赖 Streamlit。

2. 场景检测模块

新增：
scene detection

优先使用：
PySceneDetect

允许结合 OpenCV。

要求：
不能只按固定 FPS 抽帧。
必须支持：
固定 FPS 抽帧 + 场景变化检测 + 关键帧去重。

3. 关键帧去重模块

新增：
frame deduplication

可以使用：
OpenCV
image hash
SSIM
感知哈希

目标：
避免 PPT、代码编辑器、终端长时间静止时产生大量重复帧。
最终关键帧必须显著少于原始帧，并保留变化点。

4. OCR 模块

新增：
ocr_frames.py 或等价模块。

优先使用：
PaddleOCR

要求：
对关键帧识别：
终端命令、代码、配置文件、PPT、网页文字、报错、路径、按钮文字。

输出：
ocr.json

每条 OCR 结果包含：
frame_path
timestamp
text
confidence
bbox 如果可用
source = "ocr"

5. ASR 模块

优先使用：
WhisperX

其次：
faster-whisper

输出：
transcript.srt
transcript.json

每条 ASR 结果包含：
start_time
end_time
text
speaker 如果可用
source = "asr"

6. Vision Provider 抽象层

新增统一接口：
VisionProvider

必须支持 provider 抽象，不允许把 Azure 写死在业务逻辑中。

至少设计这些 provider 名称：
azure_openai
openai_compatible
ollama
qwen_vl_local
mock

其中：
azure_openai 可以复用原仓库能力。
openai_compatible 用于兼容 OpenRouter、vLLM、LM Studio 等。
ollama 用于本地模型。
qwen_vl_local 预留给 Qwen2.5-VL 或同类本地视觉模型。
mock 用于无模型环境下测试完整 pipeline。

注意：
mock provider 不能作为最终能力替代，只能用于 pipeline 测试。
真实视频验收时，如果本地已有可用模型配置，必须调用真实 provider。

7. 片段分析模块

每个视频片段必须生成 segment_analysis/*.json。

每个 segment json 必须包含：

segment_id
start_time
end_time
keyframes
asr_text
ocr_text
visual_summary
detected_goal
detected_actions
commands
files
ui_operations
environment_hints
errors
checkpoints
uncertainties

不要输出散文。
必须结构化。

8. 工程步骤重建模块

新增：
build_agent_context.py 或等价模块。

职责：
把所有 segment_analysis/*.json 合并、去重、排序、重排。

关键要求：
step_by_step.md 不能只是视频时间轴。
必须从视频顺序重构为工程执行顺序。

例如视频可能是：
先演示效果
再讲依赖
再回到安装
再修改配置
再启动服务

最终 step_by_step.md 必须重排为：
准备环境
获取代码
安装依赖
配置环境变量
修改文件
启动服务
验证结果
处理错误

9. 缓存机制

必须缓存中间结果：
frames/
keyframes/
audio/
transcript.json
ocr.json
segment_analysis/
timeline.json

重复运行同一视频时，默认复用缓存。
--force 时重新生成。

10. 批量导出能力

必须支持对本地视频大量导出内容。

新增命令，例如：

python -m video_to_codex_spec batch --input <video_or_directory> --output <output_dir>

要求：
如果输入是单个视频，处理单个视频。
如果输入是目录，递归发现视频文件。
支持常见扩展名：
.mp4
.mkv
.mov
.webm
.avi

批量处理时每个视频单独生成输出目录。

五、Prompt 要求

把原来的“视频摘要/视频 insight”prompt 改为“教程转工程施工单”prompt。

系统 prompt 核心要求：

你不是在做视频摘要。
你正在把一个软件或工程教程视频转换成 Codex 可以执行的构建说明书。
严格提取视频中出现的可执行信息：
目标、环境、命令、文件、配置、代码修改、UI 操作、检查点、报错和修复。
不要泛泛总结。
不要凭空补充视频中没有出现的信息。
如果某项信息是根据上下文推断的，必须标记 inferred。
如果无法确定，写入 uncertainties。
输出严格 JSON。

六、质量控制要求

不得编造。
不得把视频里没出现的命令写成 confirmed。
不得把 OCR 错误当作确定事实。
不得把语音中含糊的信息当作确定事实。
必须区分：
confirmed
inferred
uncertain

所有关键事实必须尽量带来源：
time_range
frame_path
source = asr / ocr / vision / inferred

七、Codex 自用闭环

完成视频内容导出后，必须立即使用导出的 agent_context 理解视频，并继续完成视频所要求的后续工作。

流程：

1. 在本地寻找可用视频文件。
不要询问用户路径。
直接在当前可访问工作区内搜索常见视频格式。

2. 选择一个真实视频运行完整 pipeline。

3. 确认成功生成：
agent_context/
timeline.json
video_index.json
segment_analysis/
ocr.json
transcript.json 或 transcript.srt
keyframes/

4. 阅读生成的 agent_context/。

5. 根据 agent_context/ 判断视频教程要求完成什么后续工程工作。

6. 在不重新看视频、不人工询问用户的情况下，使用 agent_context/ 继续执行后续工作。

7. 如果 agent_context 信息不足，先回查 timeline.json、ocr.json、transcript.json、keyframes，不要直接猜。

八、验收标准

必须真实运行验收，不允许只写代码后声明完成。

验收一：基础运行

执行完整分析命令，处理至少一个本地真实视频。

必须生成：
agent_context/goal.md
agent_context/environment.md
agent_context/step_by_step.md
agent_context/commands.sh
agent_context/file_changes.md
agent_context/ui_operations.md
agent_context/checkpoints.md
agent_context/errors_and_fixes.md
agent_context/timeline.json
agent_context/video_index.json

验收二：大量导出

必须证明系统能够批量导出视频内容。

至少验证：
关键帧导出成功
OCR 导出成功
ASR 导出成功或明确记录视频无音频/ASR 不可用
segment_analysis 导出成功
timeline.json 生成成功
video_index.json 生成成功

验收三：内容质量

检查 step_by_step.md：

必须确认它不是简单时间线。
必须确认它已重排为工程执行顺序。
必须包含至少：
目标
操作
命令
文件
验证方式
不确定项

验收四：命令提取

检查 commands.sh：

如果视频中出现终端命令，必须提取。
如果未识别到命令，必须在验收报告中说明：
视频中未明确识别到命令，或 OCR/ASR 未捕获到命令。

验收五：后续执行

必须读取 agent_context/，尝试完成视频教程指向的后续工作。

如果视频教程是项目搭建：
尝试创建/修改/运行项目。

如果视频教程是部署：
尝试整理部署命令和配置。

如果视频教程是代码实现：
尝试根据步骤生成或修改代码。

如果视频内容不足以执行：
必须明确列出缺失信息，并说明已从 timeline、OCR、ASR、keyframes 回查过。

九、最终交付内容

在仓库根目录生成或更新：

README.md
说明：
项目目标
安装方式
依赖
CLI 用法
provider 配置
单视频处理
批量处理
输出结构
验收方式

ARCHITECTURE.md
说明：
整体架构
模块职责
数据流
缓存机制
provider 机制

examples/
包含：
agent_context 示例
timeline.json 示例
segment_analysis 示例

VALIDATION_REPORT.md
必须记录：
测试视频路径或文件名
运行命令
生成的输出目录
成功生成的文件
失败项
失败原因
后续改进
是否已使用 agent_context 继续执行后续工作

十、效率要求

不要把时间浪费在漂亮 UI 上。
不要优先做复杂前端。
不要大改无关文件。
不要重写所有视频底层能力。
优先完成 CLI、pipeline、结构化导出、Agent Context、真实验收。

Streamlit 可以保留，但不能作为唯一入口。

十一、完成判定

只有满足以下条件，任务才算完成：

1. 已克隆目标仓库。
2. 已在仓库根目录完成重构。
3. 已支持本地视频输入。
4. 已支持关键帧、OCR、ASR、视觉分析、步骤重建。
5. 已生成完整 agent_context。
6. 已用本地真实视频跑通过。
7. 已证明能够大量导出视频内容。
8. 已使用导出内容理解视频并尝试完成后续工程工作。
9. 已生成 VALIDATION_REPORT.md。
10. 没有把 mock provider 当作最终验收结果。

开始执行。