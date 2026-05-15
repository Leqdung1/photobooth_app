# Phase 02 - UI integration (frame dropdown + dynamic grids)

## Context
Main screen currently has one dropdown for slot index `[1..4]`; grid/preview use fixed 2 columns and implicit 4-cell assumptions.

## Overview
- Date: 2026-05-16
- Priority: high
- Status: completed

## Key Insights
- `ComposerGrid` already reads `slots.length`, but layout columns are fixed at 2.
- `PreviewPanel` fixed 2-column grid can still support 8 items if height/scroll are handled.
- Assignment flow already supports "pick asset then assign selected slot".

## Requirements
- Add frame selector dropdown (`2x2`, `2x4`).
- Slot selector dropdown must be generated from current `slots.length`.
- Keep "tap frame slot to target slot" behavior.
- Preserve current gallery-to-slot assignment on image selection.

## Architecture
- In `main.dart`, add `_selectedTemplate` state bound to controller template.
- Top control row: template dropdown + slot dropdown.
- `ComposerGrid` accepts layout metadata (rows/cols or crossAxisCount) from selected template.
- `PreviewPanel` mirrors template geometry for visual parity.

## Data Flow
1. User changes template dropdown.
2. UI calls controller `setTemplate`; controller emits new slots.
3. UI clamps `_selectedSlot` to valid range and rebuilds dropdown/grid/preview.
4. User taps slot or picks image; assignment writes to matching slot index.

## Related code files
- `lib/main.dart` (modify): controls row, template selection state, dynamic slot dropdown. (lines 57, 166-179, 191-212)
- `lib/features/composer/presentation/composer_grid.dart` (modify): dynamic grid delegate using template columns. (lines 27-31)
- `lib/features/composer/presentation/preview_panel.dart` (modify): dynamic geometry and overflow behavior. (lines 14-17)

## Implementation Steps
1. Add template dropdown and bind to controller template setter.
2. Generate slot dropdown from current slot count.
3. Pass template geometry into composer grid and preview widgets.
4. Clamp invalid selected slot after template change.

## Todo list
- [x] Wire template dropdown into app state.
- [x] Make slot dropdown dynamic.
- [x] Update grid/preview props to receive template columns/rows.
- [ ] Add widget tests for template switch and slot-clamp behavior.

## Success Criteria
- Dropdown changes between 4-slot and 8-slot layouts without crash.
- Selected slot always valid (1..slotCount).
- Tapping slot and selecting image fills intended slot in both templates.

## Risk Assessment
- Risk: UI overflow in 2x4 preview on smaller heights.
  - Likelihood: medium; Impact: medium.
  - Mitigation: keep scroll container and set bounded heights; test on current desktop viewport.
- Risk: stale visual selection after template switch.
  - Likelihood: medium; Impact: low.
  - Mitigation: reset selected slot to 1 when changing template.

## Security Considerations
- No new external inputs beyond constrained dropdown values.

## Rollback Plan
- Revert UI files together (`main.dart`, composer/preview widgets) to previous fixed layout.

## Next Steps
Update export contract and tests for variable template dimensions.
