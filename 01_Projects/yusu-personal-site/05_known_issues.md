# Known Issues

## Raw certificate images are not yet normalized

Some certificate photos are rotated or captured with perspective distortion. The first version displays raw evidence directly; a later pass should generate web-optimized corrected derivatives while preserving originals.

## Search is lexical, not semantic

The built-in `/api/search` endpoint scans Markdown with keyword matching. Marginalia remains the semantic/deep-research layer and must be synced separately.

## The site is local-only

There is no cloud deployment, auth layer, or public privacy review yet. Do not expose this server outside `127.0.0.1` until the raw media and project facts have been reviewed for public release.
