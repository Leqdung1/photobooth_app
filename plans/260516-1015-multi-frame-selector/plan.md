---
title: Multi-frame photo booth planning (2x2 + 2x4)
date: 2026-05-16 10:15
status: completed
priority: high
blocks: []
blockedBy: []
---

# Plan Overview

Scope mode: **HOLD** (add selectable frame templates 2x2 and 2x4, keep current flow).
Mode: **--auto**.

## Scope challenge summary
- Reusable code: current 4-slot composer, grid UI, preview panel, export pipeline.
- Minimum changes: add frame-template model + dropdown + dynamic slot count/layout + export layout branching.
- Complexity: medium (state/data contract currently hard-coded to 4 slots).
- Not in scope: freeform custom layouts, drag-drop reorder, print integration.

## Cross-Plan Dependencies
- Reviewed `plans/260515-1200-readme-execution/plan.md` (completed); no active blockers.
- Overlap only in composer/export surfaces; safe to proceed.

## Phases
1. [Phase 01 - Template domain + controller refactor](./phase-01-template-domain-controller.md) — completed
2. [Phase 02 - UI integration (frame dropdown + dynamic grids)](./phase-02-ui-frame-selector.md) — completed
3. [Phase 03 - Export layout branching + test matrix](./phase-03-export-layout-tests.md) — completed

## Dependency graph
- Phase 01 unblocks all later phases (new template contract).
- Phase 02 depends on Phase 01.
- Phase 03 depends on Phases 01-02.

## File ownership matrix
- Phase 01: `lib/features/composer/domain/*`, `lib/features/composer/application/composer_controller.dart`.
- Phase 02: `lib/main.dart`, `lib/features/composer/presentation/composer_grid.dart`, `lib/features/composer/presentation/preview_panel.dart`.
- Phase 03: `lib/features/export/domain/export_request.dart`, `lib/features/export/application/export_service.dart`, `test/export/*`, `test/composer/*`.

## Success definition
- Operator can choose frame type from dropdown (`2x2`, `2x4`).
- Slot picker and composer/preview update to matching slot count.
- Tap slot then pick image behavior remains deterministic.
- Export validates required slot count per template and writes correct collage geometry.

## Validation note
- Assumption: `2x4` means 2 columns × 4 rows (8 slots). Confirm before implementation if needed.
- Planning model override (if needed): `internal.model.plan`.
