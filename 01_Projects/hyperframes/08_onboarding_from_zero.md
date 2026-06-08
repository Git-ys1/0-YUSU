# Onboarding From Zero

## First Run

```powershell
cd F:\Project\HyperFrames
npm install
npm run doctor
npm run check
```

If Chrome is missing:

```powershell
npx hyperframes browser ensure
```

## Edit A Video

1. Read `DESIGN.md`.
2. Edit `index.html` or add a composition under `compositions/`.
3. Keep GSAP timelines paused and registered on `window.__timelines`.
4. Run:

```powershell
npm run check
```

5. Start preview:

```powershell
npm run dev -- --port 3022
```

6. Render:

```powershell
npm run render
```

For the first production, use explicit named scripts:

```powershell
npm run check:001
npm run dev:001
npm run render:001
npm run snapshot:001
```

## Where To Look

- Local workflow: `F:\Project\HyperFrames\docs\WORKFLOW.md`
- Production catalog: `F:\Project\HyperFrames\productions\README.md`
- First production: `F:\Project\HyperFrames\productions\001-first-hyperframes-demo\README.md`
- Official docs: `https://hyperframes.heygen.com`
- Official repo: `https://github.com/heygen-com/hyperframes`
- Plugin skills cache: `C:\Users\yusu\.codex\plugins\cache\openai-curated\hyperframes\e2d08a2e`
