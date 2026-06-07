# ADR: backend bootstrap and deployed revision

**Status**: accepted
**Date**: 2026-05-03

## Context

First cloud deployments repeatedly failed when migration/seed/env steps were manual or when updates were claimed without confirming what code was actually running.

## Decision

Keep `update-backend.sh` as update-only. Add first-deploy `bootstrap-backend.sh` and post-deploy `check-backend-state.sh`. Update scripts load env before Prisma and record `.deploy-revision`.

## Consequences

- First deployment has a repeatable closure: dependencies, migrate, seed, restart, verify.
- Updates can be checked by comparing Git HEAD and `/opt/vline-backend/backend/.deploy-revision`.
- Seed remains idempotent, but is not blindly forced on every update.
