# Personal Site Design Brief

## Visual Thesis

深色工程控制台、真实证据照片、荧光绿动作色和金色证书质感并置：看起来像一个正在运转的个人项目档案墙，而不是简历模板。

## Reference Video Read

Source: `记得整理/个人站.mp4`

Technical facts:

- Duration: 00:04:25.10
- Resolution: 1920x1080
- Frame rate: 30 fps
- Codec: H.264 video + AAC audio

Observed direction:

- Dark full-screen composition.
- Glass-like top navigation.
- Large title blocks with a small accent color.
- Horizontal project / work wall.
- Repeated proof panels and strong motion cues.
- The example is design-portfolio oriented; YUSU should translate the pattern into engineering projects, verified artifacts, and knowledge-base search instead of copying the fictional persona.

## Content Plan

1. Hero: YUSU as the unmistakable first-viewport signal, with certificate/project imagery behind it.
2. Proof Wall: competition certificates, public award-list rows, and source files.
3. Project Spine: major local projects that already have YUSU KB entries.
4. Knowledge Search: direct live Markdown search into the vault.
5. Local Admin Signals: file counts and run mode so future Codex can tell it is using the local vault.

## Interaction Thesis

- Hero elements enter with staggered opacity and vertical motion.
- Proof/project items reveal as they enter the viewport.
- Search results update without leaving the page and link directly to vault-relative paths.

## First-Version Stack Decision

The first V0.3 preview used a zero-build frontend plus Python standard-library backend. After Marginalia became a first-class workspace, this decision was superseded: the showcase remains zero-build, while the Marginalia React source and FastAPI app are integrated under one `8787` runtime with committed, freshness-checked dist assets.
