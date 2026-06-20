# Reference Video Deep Read

Date: 2026-06-20

Source video: `07_PersonalSite/media/raw/reference/个人站.mp4`

Evidence workspace generated with:

```powershell
.\tools\analyze-video-reference.ps1 `
  -Video .\07_PersonalSite\media\raw\reference\个人站.mp4 `
  -Slug personal-site-reference `
  -IntervalSeconds 8 `
  -MaxFrames 36 `
  -ExtractAudio `
  -Force
```

Output was written to `.tools/video-analysis/personal-site-reference/`:

- `metadata.json`
- `contact-sheet.jpg`
- `frames/frame_001.jpg` through `frames/frame_033.jpg`
- `audio-preview.wav`
- `analysis.md`

## Why This Replaces The Earlier Read

The earlier pass treated the video mostly as a dark portfolio visual reference. That was too shallow. The video is a workflow lesson: define the site purpose, define the visual style, list modules, generate a first version, then improve it with references/components and deploy.

The useful takeaway is not "make YUSU look like Xiaoyang/Lizixuan". The useful takeaway is the method and the density of concrete page modules.

## Technical Facts

| Field | Value |
|---|---|
| Duration | 00:04:25.10 |
| Resolution | 1920x1080 |
| Frame rate | 30 fps |
| Video codec | H.264 |
| Audio | AAC, 1 stream |
| Read method | 8-second sampled frames + contact sheet + subtitle/visual beat inspection |

The video includes Chinese hard subtitles for many narration points. The audio stream was confirmed and extracted; for this video, the key narration points were visible in subtitles on the sampled frames. For future videos without subtitles, a transcript or listening notes are required.

## Timeline Observations

| Time | What Happens | Reusable Lesson | Must Not Copy |
|---|---|---|---|
| 00:00-00:24 | Shows a finished personal portfolio hero with full-screen image, pill nav, huge name, bottom image strip, then "Selected Works" style cards. | The first viewport must immediately prove the page's identity and visual ambition; nav and work samples are part of the composition, not afterthoughts. | Do not copy the fictional identity or generic designer portfolio copy. |
| 00:24-00:48 | Introduces "制作个人站的两个思路": custom build vs one-click template. | Treat a personal site as a deliberate strategy choice, not just page assembly. | Do not choose a generic template if the current site needs local evidence/search/workspace functions. |
| 00:48-01:12 | Critiques missing purpose: "没有说明网站的用途"; shows prompt-like module planning. | Before implementation, write use, style, and module requirements. | Do not jump from screenshots to CSS without an intent brief. |
| 01:12-01:36 | Defines example modules: hero, profile/about, selected work, skills, contact, project data; asks for React/Vite and advanced interaction. | A good prompt/taskbook enumerates page sections and interaction quality. | Do not translate these modules literally; YUSU needs evidence, projects, KB search, Agent, Kaoyan. |
| 01:36-02:00 | Sends profile/copy to Codex and asks it to produce a first version. | The video treats Codex as an implementation worker after requirements are precise. | Do not ask Codex to infer the whole taste system from "make it nicer". |
| 02:00-02:24 | Collects references from inspiration boards and says current design taste is not enough. | Use references to set visual taste, not only functionality. | Do not rely on one image; gather a style board or sampled timeline. |
| 02:24-02:56 | Iterates a dark red/black portfolio, fixes layout and hero image placement. | Improvement happens through targeted critique: theme color, hero background, layout spacing. | Do not accept first pass just because it is functional. |
| 02:56-03:20 | Inspects profile/selected work/contact sections and asks for fine-grained adjustment. | Every section must have a job and a recognizable visual beat. | Do not let lower sections degrade into plain lists. |
| 03:20-03:44 | Browses mature component examples: navbar, border glow, interaction components. | After first version, use mature components/patterns for high-quality details. | Do not paste components blindly without adapting to current IA and local stack. |
| 03:44-04:08 | Applies navigation and border glow examples, then improves the site again. | The visual finish comes from component-level polish and motion details. | Do not stop at a static screenshot-level imitation. |
| 04:08-04:25 | Shows GitHub + Render deployment and summarizes the Codex website-making method. | Final product needs deployment/run instructions and a repeatable workflow. | Do not ignore runtime/deployment/verification after design. |

## Synthesis For YUSU Personal Site

### Intent

The video teaches a repeatable way to build a personal site with Codex: define use and style, specify modules, generate a first version, then refine with references, components, motion, and deployment.

### Visual Language

Dark cinematic portfolio, high-contrast name/title, glass or pill navigation, bright accent color, image-led hero, work/project strips, profile metrics, selected work cards, subtle glowing borders, mature component inspiration.

### Information Architecture

The reusable sequence is:

1. Hero identity
2. Work/project evidence
3. Profile/context
4. Capability/modules
5. Contact/action
6. Deployment/publishing path

For YUSU this should become:

1. YUSU identity and local evidence mission
2. Verified awards/materials
3. Cross-project memory and major projects
4. Agent, Marginalia, Kaoyan, search, media library
5. Next actions and maintenance status
6. Local/remote run instructions

### What The Current V0.4 Did Right

- Moved away from a generic resume site.
- Put YUSU, evidence, project count, media count, Agent, Kaoyan, and search into the first screen.
- Used real certificate imagery instead of decorative placeholders.
- Added Lenis and reveal/hover motion without introducing a build step.
- Verified desktop/mobile rendering with Playwright.

### What The Current V0.4 Still Misses

- The video expects stronger module-by-module visual beats below the fold; the current site still has some information-list sections that could feel utilitarian.
- It lacks a dedicated "design reference board" or component-inspiration section for future refinement.
- It does not yet use mature component-level polish such as border glow, magnetic nav, sticky selected-work strip, or richer scroll choreography.
- The "contact/action/deploy" ending is weak for a local admin site; it should become "how to operate/sync/update this vault".
- The existing contact sheet in the page is useful proof, but future design passes should use a filled timeline table, not just the image.

## Next Design Implications

- Treat the next personal-site pass as V0.5, not a random CSS polish pass.
- Start from a taskbook: use, style, modules, target screenshots, verification.
- Add a section that exposes "reference read -> design decisions" so the site demonstrates its own design logic.
- Make each major workspace card behave like a mature component, not a plain link list.
- Improve below-the-fold sections with clearer visual rhythm: sticky headers, horizontal work strips, richer project previews, and better terminal/admin ending.

## Completion Gate For Future Video Reads

Future Codex sessions should not claim "video understood" unless they have:

- generated `.tools/video-analysis/<slug>/`;
- inspected contact sheet and representative frames;
- considered audio or subtitles;
- written a project-level deep read like this file;
- mapped the result to concrete implementation changes;
- verified the target with rendered screenshots.
