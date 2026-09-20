# 05 Known Issues

## Issue: Cloud cannot reliably reach robot-side rosbridge behind NAT

**Status**: active
**Severity**: high

### Symptom

Cloud backend cannot connect to robot-side rosbridge when Pi is on phone hotspot or lab LAN.

### Root Cause

Robot-side ROS services are behind private LAN/NAT. Cloud cannot assume inbound reachability.

### Verified Fix

Use outbound `/edge/ros` from Pi to backend. Keep `rosbridge` for local LAN only.

### Codex Rule

Do not “fix” this by adding frontend direct ROS URLs. Change the transport boundary.

## Issue: Edge relay token/env drift causes immediate WebSocket close

**Status**: active
**Severity**: high

### Symptom

Pi repeatedly logs websocket closed by peer after connecting.

### Root Cause

Env token, DB bcrypt tokenHash, allowed device list, and running service instance are not aligned. Changing env alone does not update existing DB token hash.

### Verified Fix

Confirm env, DB seed/update, whitelist, systemd restart, and Pi launch token as one set.

### Codex Rule

Never hand out “the token” without checking where backend is actually validating it.

## Issue: Prisma seed fails when migration is missing

**Status**: resolved
**Severity**: high

### Symptom

`npx prisma db seed` fails with `The table main.EdgeDevice does not exist`.

### Root Cause

Schema and seed referenced `EdgeDevice`, but migration creating the table was missing.

### Verified Fix

Add migration and run `npx prisma migrate deploy` before seed. `db push` is emergency-only.

### Codex Rule

Seed failure can be a migration failure; inspect schema/migrations before blaming env.

## Issue: Update scripts run Prisma without DATABASE_URL

**Status**: resolved
**Severity**: high

### Symptom

Cloud `update-backend` fails with `Environment variable not found: DATABASE_URL`.

### Root Cause

Prisma CLI validates schema before systemd env is available.

### Verified Fix

Update/bootstrap scripts must load `/etc/vline-backend.env` or explicit `ENV_FILE` before Prisma generate/migrate.

### Codex Rule

If a service has env under systemd, CLI scripts still need their own env loading.

## Issue: One UI click becomes duplicate robot toggle commands

**Status**: resolved
**Severity**: high

### Symptom

Robot logs `active -> stopped -> active -> stopped` while operator thinks they clicked once.

### Root Cause

Frontend/backend emits both press and release as identical `manual_control`, while Pi interprets identical repeated command as toggle stop.

### Verified Fix

Send one `manual_control` per intentional toggle. Use explicit `stop` for stop semantics.

### Codex Rule

Do not mix press-and-hold semantics with toggle semantics without an explicit protocol.

## Issue: Cloud backend is the wrong place for 50Hz realtime loops

**Status**: active
**Severity**: high

### Symptom

Continuous motion is unstable or safety semantics become unclear when cloud repeatedly sends commands.

### Root Cause

Public internet and WSS path are not deterministic realtime control channels.

### Verified Fix

Backend sends intent; Pi/ROS locally publishes 50Hz and chooses lower controller protocol (`W` open-loop or `M` closed-loop).

### Codex Rule

Keep realtime loops as close to the robot as possible.

## Issue: OpenClaw Dashboard is not CleanScout product UI

**Status**: active
**Severity**: medium

### Symptom

Project drifts toward embedding or exposing OpenClaw Dashboard because it already has chat/control UI.

### Root Cause

Dashboard is a high-privilege management surface, not CleanScout product UX.

### Verified Fix

Use CleanScout chat UI. Backend routes to pc-openclaw-worker; Gateway token stays local to UbuntuPC.

### Codex Rule

Capability can be reused; third-party operator UI should not become the public product UI.

## Issue: MJPEG long stream killed by normal request timeout

**Status**: resolved
**Severity**: high

### Symptom

Camera stream is extremely choppy or reconnects every few seconds even when native ESP32-CAM page is smooth.

### Root Cause

Long-lived stream was handled like a short request, or frames were parsed/repacked unnecessarily.

### Verified Fix

Use raw MJPEG tunnel where possible. Do not apply short source timeout or historical frame queue.

### Codex Rule

Compare native stream first; do not optimize constants before proving the transport path preserves stream shape.

## Issue: H5 third-party deployment lacks backend CORS

**Status**: active
**Severity**: medium

### Symptom

Netlify H5 loads but API calls fail while mini-program works.

### Root Cause

Backend public-edge env does not include H5 origins in `CORS_ALLOWED_ORIGINS`.

### Verified Fix

Add Netlify/custom H5 origins to backend env. WeChat legal domains are separate.

### Codex Rule

Different frontend deployment surfaces need separate domain/CORS checks.

## Issue: HDS local paths are not yusu-side source paths

**Status**: active
**Severity**: medium

### Symptom

Future yusu-side engineer follows `F:\Project\CSc——uniapp\vue3` and cannot find source.

### Root Cause

This ingestion happened on HDS Windows, but 0-YUSU memory will return to yusu Windows.

### Verified Fix

Use `Git-ys1/CleanScout_rover/vue3` as canonical source and set `%CLEANSCOUT_VUE3_ROOT%` / `$CLEANSCOUT_VUE3_ROOT` to the local checkout.

### Codex Rule

Treat local paths in ingestion as evidence paths, not portable runbook paths.

## Issue: chat image uploads must not trust client MIME or filename extensions

**Status**: resolved in PR #1, merged as `b7fc1c1b` on 2026-08-17
**Severity**: high

### Symptom

The Chapter 2 chat-image implementation accepted a non-image file when the multipart request claimed `image/svg+xml`, retained the attacker-controlled `.html` extension, and exposed the result through the backend's static `/uploads` route. Ordinary rejected text uploads also returned HTTP 500 instead of a client-error status.

### Root Cause

The upload filter trusted the client-provided MIME prefix, while the storage service fell back to the original filename extension for MIME values outside its explicit mapping. Multer validation errors were not normalized to 400/415 responses.

### Verified Fix

PR #1 now restricts uploads to an explicit JPEG/PNG/GIF/WebP allowlist, detects the file signature, lets the server choose the stored extension, rejects MIME/signature mismatches with HTTP 415, and normalizes Multer validation failures to client-error responses. Its smoke script covers valid PNG 201, non-image 415, spoofed MIME 415, and unauthenticated upload 401. The reviewer repeated these cases plus a dangerous original extension test before approval and merge.

### Codex Rule

For any user-uploaded static asset, validate content independently of client metadata and never publish an attacker-controlled extension from a same-origin static route.

## Issue: BS Python bootstrap can inherit an incompatible PowerShell module path

**Status**: active, non-blocking follow-up after PR #2
**Severity**: low

### Symptom

Running `vue3/bs/setup-python.cmd` from the Codex/PowerShell 7 environment can make its child Windows PowerShell fail with `Get-FileHash is not recognized`, even though the system Windows PowerShell module contains that command.

### Root Cause

The `.cmd` process inherits a PowerShell 7-oriented `PSModulePath`; Windows PowerShell then fails to auto-load its compatible utility module. The downloaded Python archive itself matched the pinned SHA-256, and initialization succeeded when Windows PowerShell received its normal module path.

### Recommended Fix

Change the bootstrap hash calculation to a module-independent .NET SHA-256 implementation, or explicitly establish the Windows PowerShell module path before calling `Get-FileHash`. Keep the pinned hash check mandatory.

### Codex Rule

When a Windows bootstrap script nests `cmd` and Windows PowerShell under a PowerShell 7 host, test the inherited environment rather than assuming module auto-loading is identical.
