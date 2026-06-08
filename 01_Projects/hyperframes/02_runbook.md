# Runbook

## Stable Commands

```powershell
cd F:\Project\HyperFrames
npm install
npm run doctor
npm run lint
npm run inspect
npm run check
npm run dev
npm run render
```

`npm run dev` is long-running. The verified preview URL on 2026-06-05 was:

```text
http://localhost:3022/#project/001-first-hyperframes-demo
```

`npm run render` writes:

```text
F:\Project\HyperFrames\productions\001-first-hyperframes-demo\outputs\001-first-hyperframes-demo.mp4
```

The current default scripts target production `001`. Use named scripts for clarity:

```powershell
npm run check:001
npm run dev:001
npm run render:001
npm run snapshot:001
```

## Plugin Evidence

Codex plugin cache showed `HyperFrames by HeyGen` installed at:

```text
C:\Users\yusu\.codex\plugins\cache\openai-curated\hyperframes\e2d08a2e
```

The plugin exposes `hyperframes`, `hyperframes-cli`, `hyperframes-registry`, `gsap`, and `website-to-hyperframes` skills.
