# Phase 01 - Template domain + controller refactor

## Context
Current composer is fixed at 4 slots (`ComposerController` initializes length 4) and all downstream consumers assume this constant.

## Overview
- Date: 2026-05-16
- Priority: high
- Status: completed

## Key Insights
- Hard-coded slot count appears in controller and export request readiness checks.
- Slot indices are 1-based and used by UI dropdown/selection logic.

## Requirements
- Add a frame template abstraction with at least: id/label, rows, cols, slotCount.
- Controller must rebuild slots when template changes.
- Preserve existing tap-to-select and assign semantics.

## Architecture
- Introduce `FrameTemplate` domain object in composer domain layer.
- Controller owns `selectedTemplate` + computed `slots`.
- `setTemplate(template)` resets slots to new `slotCount`; selected slot fallback handled by UI phase.

## Data Flow
1. UI emits selected template key.
2. Controller maps key -> template metadata and regenerates slot list.
3. Slots stream/notification updates composer grid, preview, export payload.

## Related code files
- `lib/features/composer/application/composer_controller.dart` (modify): replace fixed `4` with template-driven generation. (lines 5-10, 36-41)
- `lib/features/composer/domain/slot_assignment.dart` (read-only): remains slot value object.
- `lib/features/export/domain/export_request.dart` (modify in later phase): remove fixed-length readiness assumption. (line 7)
- `lib/main.dart` (uses controller slots today). (lines 50, 57, 168-172)

## Implementation Steps
1. Define frame template model/constants (2x2, 2x4).
2. Extend controller with template state and `setTemplate` API.
3. Update controller tests for dynamic slot count and reset behavior.

## Todo list
- [x] Create frame template domain file.
- [x] Refactor controller initialization/reset for variable slot counts.
- [x] Add tests: template switch 2x2->2x4 clears and resizes slots.

## Success Criteria
- Controller exposes selected template and slot list matching template `slotCount`.
- Assign/clear/reset still notify listeners and remain deterministic.
- Unit tests cover both templates.

## Risk Assessment
- Risk: stale selected slot index after template shrink/expand.
  - Likelihood: medium; Impact: medium.
  - Mitigation: enforce selected-slot clamping in Phase 02 UI.
- Risk: silent export mismatch if request still assumes 4 slots.
  - Likelihood: high; Impact: high.
  - Mitigation: Phase 03 updates request contract + validation.

## Security Considerations
- No new trust boundary.
- Keep template options internal constants (no user-provided layout expressions).

## Rollback Plan
- Revert controller/template files as one commit; retain previous fixed-4 behavior.

## Next Steps
Proceed to UI dropdown and dynamic grid adaptation.
