# Phase 03 - Export layout branching + test matrix

## Context
Export currently requires exactly 4 slots and composites into fixed 1600x1600 with 2x2 placement.

## Overview
- Date: 2026-05-16
- Priority: high
- Status: completed

## Key Insights
- `ExportRequest.isReady` hard-locks to 4 slots.
- Placement math uses fixed `cell = canvasSize/2` and 2-column indexing.
- Existing export test validates only 4-image success path.

## Requirements
- Export request must include selected template dimensions.
- Readiness check must require all slots filled according to template slot count.
- Export service must compute cell size and placement from `rows/cols`.
- Keep deterministic naming and file collision safety.

## Architecture
- Extend `ExportRequest` with template metadata (`rows`, `cols`, or template id + resolver).
- Export placement formula:
  - `cellW = canvasWidth / cols`
  - `cellH = canvasHeight / rows`
  - `dx = (i % cols) * cellW`
  - `dy = (i ~/ cols) * cellH`
- Decide canvas strategy:
  - Recommended: fixed width, height derived from ratio (`rows/cols`) to avoid squashing 2x4.

## Data Flow
1. Main UI builds `ExportRequest` with slot paths + template dimensions.
2. Export validates count/fullness.
3. Export loops slots and composites using template-driven coordinates.
4. Output file path returned to UI status message.

## Related code files
- `lib/features/export/domain/export_request.dart` (modify): dynamic readiness contract. (line 7)
- `lib/features/export/application/export_service.dart` (modify): template-driven geometry and validation. (lines 17-43)
- `lib/main.dart` (modify): pass template metadata in export request. (lines 107-110)
- `test/export/export_service_test.dart` (modify): add 2x4 success/failure cases.
- `test/composer/composer_controller_test.dart` (modify): assert template-driven slot resizing.

## Implementation Steps
1. Refactor export request/service interfaces for template dimensions.
2. Implement dynamic composite placement math.
3. Add tests for 2x2 and 2x4 readiness/geometry.
4. Run full flutter test suite.

## Todo list
- [x] Update export request model.
- [x] Update export service placement logic.
- [x] Expand unit tests for both templates and incomplete-slot rejection.
- [x] Verify status messages remain user-readable.

## Success Criteria
- Export succeeds with filled 2x2 and filled 2x4.
- Export rejects incomplete template with correct required-slot message.
- Existing 2x2 behavior remains unchanged (backward compatibility).

## Risk Assessment
- Risk: output aspect ratio disagreement for 2x4 (portrait vs square packing).
  - Likelihood: medium; Impact: high.
  - Mitigation: explicitly choose and document canvas-ratio strategy; validate with user sample.
- Risk: memory increase with larger composite sizes.
  - Likelihood: low; Impact: medium.
  - Mitigation: cap canvas dimensions and reuse decode/resize pipeline.

## Security Considerations
- Continue validating source file existence/decoding failures before compose.
- No path injection exposure beyond existing file-path usage.

## Rollback Plan
- Revert export model/service/tests in one commit if regression appears; keep UI selector hidden behind temporary flag if needed.

## Test Matrix
- Unit: controller template switching, slot reset, slot clamping helper.
- Unit: export readiness for 4/8 slots and missing-source error path.
- Integration/widget: main screen template dropdown changes visible slot count and assignment target.
- E2E manual: import 8 images -> fill 2x4 -> export -> verify output file generated and readable.

## Next Steps
If user confirms 2x4 orientation and preferred final print ratio, proceed to cook execution.
