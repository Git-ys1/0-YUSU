# Personal Site Open-Source Research

Date: 2026-06-20

## Requirement

Improve the YUSU personal site beyond a scaffold, look for existing open-source projects/plugins/skills, and use a larger existing project only if it actually fits the local evidence-vault purpose.

## Findings

| Candidate | Result | Decision |
|---|---|---|
| Full portfolio templates | Many templates optimize for public designer portfolios and marketing copy. They would replace the local knowledge/search/workspace structure with a generic resume site. | Do not adopt wholesale. Use the reference-video structure instead: purpose, style, modules, then evidence/project/workspace sections. |
| GSAP / Codrops-style portfolio motion | Good fit for scroll/reveal language, but a full GSAP dependency is not needed for the current no-build local site. A local `hyperframes:gsap` skill exists, but it is scoped to HyperFrames video composition, not this site runtime. | Reuse the motion pattern conceptually; implement current pass with CSS transitions and IntersectionObserver. |
| Lenis smooth scroll | `npm view lenis@1.3.23` reports MIT license. It is small enough to self-host and improves scroll feel without changing the architecture. | Vendor only `lenis.min.js`, `lenis.css`, and `LICENSE` under `web/vendor/lenis/`. |
| Local Codex tool/skill search | `tool_search` found no additional callable personal-site visual plugin for this session. | Continue with frontend-skill + local browser QA. |

## Implemented

- Vendored `lenis@1.3.23` browser runtime under `07_PersonalSite/web/vendor/lenis/`.
- Kept the site zero-build: no React/Next migration for the showcase layer.
- Reworked the page structure around:
  - local workspace dock
  - evidence wall
  - project spine
  - reference-video time-axis read
  - live Markdown search

## Upgrade Rule

If the personal site later becomes a public cloud portfolio, then reassess a full React/Next template or a GSAP/Framer Motion build pipeline. For the current local-only YUSU vault, avoid dragging in a large external template unless it preserves the knowledge-vault workflows as first-class UI.
