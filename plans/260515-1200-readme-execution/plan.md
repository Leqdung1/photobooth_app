---
title: README execution plan (photo booth MVP)
date: 2026-05-15 12:00
status: completed
priority: high
blocks: []
blockedBy: []
---

# Plan Overview

Scope mode: **HOLD** (implement README Phase 1+2 only; defer printer integration).
Mode: **--auto**.

## Scope challenge summary
- Reusable code: only Flutter project scaffolding (`pubspec.yaml`, platform runners).
- Minimum change set: replace template UI/state, add watcher+composer+export pipeline, update tests/docs.
- Complexity: medium (desktop file IO + image processing + UI state sync).
- Not in scope: direct print, customer/order history, backend/cloud, AI editing.

## Cross-Plan Dependencies
- No existing active plans detected.
- No blockers/blocked dependents at creation time.

## Phases
1. [Phase 01 - Foundation & environment contract](./phase-01-foundation-environment.md) — completed
2. [Phase 02 - Ingest pipeline (watcher + gallery)](./phase-02-ingest-pipeline.md) — completed
3. [Phase 03 - 2x2 composer UI/state](./phase-03-composer-ui-state.md) — completed
4. [Phase 04 - Export engine + verification hardening](./phase-04-export-verification.md) — completed

## Dependency graph
- Phase 01 unblocks all later phases.
- Phase 02 depends on Phase 01.
- Phase 03 depends on Phase 02 (needs loaded assets/state).
- Phase 04 depends on Phase 03 (needs slot mapping + composed preview state).

## File ownership matrix (no parallel collisions)
- Phase 01: `pubspec.yaml`, new `lib/core/config/*`, docs updates.
- Phase 02: `lib/features/ingest/*`, integration into `lib/main.dart` shell.
- Phase 03: `lib/features/composer/*`, widget tests for composer behaviors.
- Phase 04: `lib/features/export/*`, export tests, final README runbook updates.

## Success definition
- Operator can drop/tether images into inbox folder, see thumbnails, place 4 photos in fixed grid, preview, and export final file into exports folder with deterministic naming.
- Workflow works on Windows desktop without backend services.

## Task hydration note
- 4 phases => suitable for hydrated execution tasks in cook session.
- Recommended model override if needed: `internal.model.plan` for planning depth consistency.
