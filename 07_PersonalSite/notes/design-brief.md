# Personal Site Design Brief

## Visual Thesis

深色工程控制台、真实证据照片、荧光绿动作色、金色证书质感和少量红蓝状态色并置：看起来像一个正在运转的本地证据中枢，而不是简历模板。

## Reference Video Read

Source: `07_PersonalSite/media/raw/reference/个人站.mp4`

Storyboard contact sheet: `07_PersonalSite/media/derived/reference/personal-site-reference-contact-sheet.jpg`

Technical facts:

- Duration: 00:04:25.10
- Resolution: 1920x1080
- Frame rate: 30 fps
- Codec: H.264 video + AAC audio

Observed direction after full time-axis sampling:

- The video is a personal-site tutorial, not a reusable product UI. It repeatedly emphasizes defining website purpose, visual style, and modules before generating a site.
- It shows dark full-screen portfolio compositions with glass-like top navigation, oversize name/title blocks, selected work strips, capability sections, reference-board browsing, and deployment notes.
- The strongest reusable pattern is information architecture: purpose -> style -> modules -> project wall -> capabilities/work entries -> publish.
- YUSU should translate that pattern into engineering projects, verified artifacts, local workspaces, and knowledge-base search instead of copying the fictional designer persona.

## Content Plan

1. Hero: YUSU as the unmistakable first-viewport signal, with certificate/project imagery behind it.
2. Workspace Dock: direct local entry points for Agent, Kaoyan dashboard, library, and live search.
3. Proof Wall: competition certificates, public award-list rows, and source files.
4. Project Spine: major local projects that already have YUSU KB entries.
5. Reference Read: the video contact sheet and the design method extracted from it.
6. Knowledge Search: direct live Markdown search into the vault.
7. Local Admin Signals: file counts and run mode so future Codex can tell it is using the local vault.

## Interaction Thesis

- Hero elements enter with staggered opacity and vertical motion.
- Lenis smooth scroll improves page traversal while keeping the site no-build and local.
- Proof/project/workspace items reveal as they enter the viewport and lift on hover.
- Search results update without leaving the page and link directly to vault-relative paths.

## First-Version Stack Decision

The first V0.3 preview used a zero-build frontend plus Python standard-library backend. After Marginalia became a first-class workspace, this decision was superseded: the showcase remains zero-build, while the Marginalia React source and FastAPI app are integrated under one `8787` runtime with committed, freshness-checked dist assets.

The V0.4 visual pass keeps the showcase zero-build and vendors only the small MIT-licensed Lenis runtime for scroll quality. Full portfolio templates were rejected because they optimize for public resume sites rather than this local evidence-vault workflow.
