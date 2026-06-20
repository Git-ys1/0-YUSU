# Video Understanding Protocol For Codex

本协议用于任何“参考视频 -> 设计/产品/实现判断”的任务。它的目标不是生成几张截图，而是让 Codex 证明自己理解了视频的时间线、意图、风格、模块和可迁移结论。

## 2026-06 Upgrade: video-to-codex-spec

当任务目标是“让 Codex 从教程视频继续工程构建”，不要只使用 contact sheet 脚本。优先使用：

```powershell
cd F:\AcademicHub\video-analysis-with-aoai
.\.venv\Scripts\python.exe -m video_to_codex_spec analyze `
  --video "<video>" `
  --output ".tools\analysis\<slug>" `
  --scene-detect --ocr --asr `
  --vision-provider openai_compatible
```

必须生成并读取 `agent_context/`：

- `goal.md`
- `environment.md`
- `step_by_step.md`
- `commands.sh`
- `file_changes.md`
- `ui_operations.md`
- `checkpoints.md`
- `errors_and_fixes.md`
- `timeline.json`
- `video_index.json`

如果真实视觉 provider 被阻断，`mock` 只能用于导出中间产物。Codex 应直接查看 keyframes，写 `manual_visual_review.json`，再运行：

```powershell
.\.venv\Scripts\python.exe -m video_to_codex_spec apply-manual-review `
  --output ".tools\analysis\<slug>" `
  --review ".tools\analysis\<slug>\manual_visual_review.json"
```

这样最终 `agent_context/` 有可追溯视觉证据，不会把 mock 当成理解结果。

## When To Use

遇到以下情况必须用：

- 用户给视频作为网站、应用、PPT、动画、交互或产品风格参考。
- 用户指出“你没有看懂视频”“只是截了几张图”。
- 视频内容会影响 UI、动效、信息架构、叙事、文案、功能模块或验收标准。
- 之后其他 Codex 还需要复用这份视频理解。

## Non-Negotiable Rule

不能把 contact sheet 当作最终理解。Contact sheet 只是索引。真正完成前必须有：

1. 视频技术事实：时长、分辨率、帧率、音频流。
2. 时间轴观察：按时间段写清画面、变化、动效、文案/语音、模块。
3. 意图综合：视频想教什么、展示什么、面向谁。
4. 可迁移判断：哪些模式可复用，哪些只是视频里的示例内容，不能照搬。
5. 目标映射：这些结论如何改变当前项目的设计或实现。
6. 验收证据：目标页面/产物是否真的体现了这些结论。

## Standard Workflow

### 1. Locate The Taskbook

先找用户提供的任务书：

```powershell
rg -n -i "任务书|视频理解|观片|分镜|reference video|video brief" .
Get-ChildItem C:\Users\yusu\.codex\attachments -Recurse -File
```

如果任务书不存在，不要假装读过。先按 `05_Templates/video-understanding-taskbook.md` 生成一个待填模板，并在结果里说明“未找到用户任务书，已建立标准任务书”。

### 2. Generate Evidence Workspace

所有临时产物默认放在 `.tools/video-analysis/`，不要落到 C 盘，也不要把大批帧图直接提交。

```powershell
.\tools\analyze-video-reference.ps1 `
  -Video .\07_PersonalSite\media\raw\reference\个人站.mp4 `
  -Slug personal-site-reference `
  -IntervalSeconds 8 `
  -Force
```

脚本会生成：

- `metadata.json`
- `contact-sheet.jpg`
- `frames/frame_001.jpg` 等抽帧
- `analysis.md` 待填写观察表

如视频有音频且语音会影响理解，加 `-ExtractAudio` 生成 `audio-preview.wav`，再使用可用的转写工具或人工听读摘要。

### 3. Watch By Beats, Not By Pretty Frames

填写 `analysis.md` 时按视觉节拍拆解：

- 开场/定位
- 导航/布局结构
- 模块切换
- 滚动与转场
- 关键文案/字幕/讲解
- 结尾/部署/行动指引

每个节拍至少回答：

- 画面上有什么？
- 和上一段相比改变了什么？
- 动效或交互是什么？
- 这对当前项目有什么用？
- 哪些内容不能复制？

### 4. Synthesize Before Implementing

实现前必须写出短综合：

```md
## Video Synthesis

- Intent:
- Audience:
- Visual language:
- Information architecture:
- Motion language:
- Reusable patterns:
- Rejected patterns:
- Project mapping:
```

如果综合无法解释“为什么这样改”，就还没看懂。

### 5. Verify The Target

面向 UI/视觉的任务必须用真实渲染验证：

- 桌面与手机截图。
- 图片/视频资源是否加载。
- 横向溢出检查。
- 首屏是否符合视频综合，而不是只符合一张截图。
- 交互入口是否可达。

对个人站一类本地网页，优先用 Playwright。截图放 `.tools/playwright-artifacts/`。

## Routing Results

- 项目专属视频理解：写入 `01_Projects/<project-slug>/` 或项目内 `notes/`。
- 跨项目方法：写入 `03_CrossProject/tooling.md` 或 `03_CrossProject/patterns.md`。
- 通用任务书模板：写入 `05_Templates/`。
- 可长期执行的步骤：写入 `04_Runbooks/`。

## Completion Checklist

- [ ] 找到并阅读任务书，或明确记录任务书缺失并创建标准模板。
- [ ] 生成并检查 metadata/contact sheet/frames。
- [ ] 填写时间轴观察，不少于主要视觉节拍。
- [ ] 处理音频或说明音频与任务无关。
- [ ] 输出综合和项目映射。
- [ ] 实现或修改目标产物。
- [ ] 用截图/运行结果证明目标产物体现综合结论。
- [ ] 更新知识库路由和索引。
