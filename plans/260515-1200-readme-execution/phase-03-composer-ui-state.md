# Phase 03 — 2x2 composer UI/state

## Context
README requires fixed 2x2 composition area with assign/replace/reset behaviors (`README.md:177-186`, `README.md:208-214`, `README.md:246-250`).

## Overview
- Date: 2026-05-15
- Priority: High
- Status: completed

## Key Insights
- Composer state must be deterministic and independent from gallery list order changes.
- Drag/drop is optional UX enhancement; click-to-assign should exist as baseline reliability path.

## Requirements
- Provide 4 fixed slots with explicit indices (1..4).
- Allow assign image to selected slot; replace and clear per-slot.
- Show preview canvas reflecting crop/fit policy.
- Global reset clears all slots atomically.

## Architecture
Data flow:
1) User selects asset from gallery.
2) Composer controller maps assetId to target slot.
3) Slot state emits updates to grid + preview panel.
4) Reset actions mutate slot map and emit new immutable snapshot.
Output: finalized slot map for export phase.

## Related code files
- `lib/features/composer/domain/slot_assignment.dart` — create — slot model and invariants.
- `lib/features/composer/application/composer_controller.dart` — create — assignment/reset logic.
- `lib/features/composer/presentation/composer_grid.dart` — create — 2x2 grid widgets.
- `lib/features/composer/presentation/preview_panel.dart` — create — composite preview render.
- `lib/main.dart` — modify — orchestrate gallery↔composer interactions.
- `test/composer/composer_controller_test.dart` — create — slot logic tests.

## Implementation Steps
1. Define slot invariants (exactly 4 slots, nullable assignment).
2. Implement controller API: assign, replace, clearSlot, resetAll.
3. Build grid UI with clear visual occupancy states.
4. Wire gallery selection + slot targeting interaction.
5. Add preview rendering path consistent with export dimensions policy.

## Todo list
- [x] Create slot domain model + controller.
- [x] Build 2x2 grid and reset controls.
- [x] Integrate with gallery selection flow.
- [x] Add logic and widget tests for assignment/reset.

## Success Criteria
- Operator can fill all 4 slots and replace any slot without affecting others.
- Reset all clears grid in one action.
- Preview always matches current slot state.

## Risk Assessment
- Risk: state desync between selected asset and target slot. Likelihood: Medium, Impact: High.
  - Mitigation: single source of truth controller + immutable state snapshots.
- Risk: over-complex gesture handling delays delivery. Likelihood: Medium, Impact: Medium.
  - Mitigation: ship click-first assignment; add drag/drop only if low-risk.

## Security Considerations
- Do not execute or parse arbitrary metadata from images beyond rendering needs.
- Bound image dimensions in preview path to avoid memory exhaustion.

## Next Steps
- Expose composed slot payload + geometry contract to export module.

## Test Matrix
- Unit: slot invariant enforcement and reset semantics.
- Integration: gallery-to-slot assignment interactions.
- E2E: fill/replace/reset workflow with 4 real images.

## Rollback Plan
- Keep gallery read path intact; disable composer interactions and show maintenance fallback panel.

## Backwards Compatibility
- UI behavior evolves from empty shell; no persisted user data contract broken.
