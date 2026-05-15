# Phase 04 — Export engine + verification hardening

## Context
README requires exporting final composed image to exports folder (`README.md:221-223`, `README.md:252-253`, `README.md:273-278`).

## Overview
- Date: 2026-05-15
- Priority: High
- Status: completed

## Key Insights
- Export correctness is the business-critical output; must validate dimensions and slot placement deterministically.
- File naming collisions can silently overwrite paid customer outputs.

## Requirements
- Convert current slot state into final bitmap using fixed canvas size and grid geometry.
- Enforce preconditions: all required slots filled (or explicit partial export policy).
- Save to exports folder with collision-safe naming.
- Return success/error feedback in UI.

## Architecture
Data flow:
1) Export action requests current composer snapshot.
2) Export service decodes source images and applies crop/fit transform per slot.
3) Raster compositor draws 4 cells into target canvas.
4) File writer persists JPG/PNG into exports path and returns metadata.
Output: finalized file path for print handoff (future phase).

## Related code files
- `lib/features/export/domain/export_request.dart` — create — export contract.
- `lib/features/export/application/export_service.dart` — create — composition and save pipeline.
- `lib/features/export/presentation/export_actions.dart` — create — export button + result states.
- `lib/features/composer/presentation/preview_panel.dart` — modify — share geometry contract with exporter.
- `test/export/export_service_test.dart` — create — geometry + naming tests.
- `README.md` — modify — operator verification checklist.

## Implementation Steps
1. Define deterministic canvas/grid dimensions and shared constants.
2. Implement image decode/fit/crop composition logic.
3. Add collision-proof filename strategy (timestamp + sequence/uuid).
4. Wire export button states (idle/running/success/error).
5. Add verification tests and manual runbook for Windows operators.

## Todo list
- [x] Build export domain contract and service.
- [x] Add file naming + overwrite prevention.
- [x] Connect export UI feedback and disable during processing.
- [x] Add unit/integration tests for output correctness.
- [x] Update README acceptance runbook.

## Success Criteria
- Export produces valid image file in configured exports folder every run.
- No overwrite occurs when exporting repeatedly in same minute.
- Visual slot placement matches preview contract within accepted tolerance.

## Risk Assessment
- Risk: large source images cause slow export/freezes. Likelihood: Medium, Impact: High.
  - Mitigation: background isolate/off-main-thread processing and progress state.
- Risk: geometry mismatch between preview and export output. Likelihood: Medium, Impact: High.
  - Mitigation: single shared geometry constants and snapshot-based tests.

## Security Considerations
- Validate output path is within configured root to prevent arbitrary file writes.
- Handle malformed/corrupt images with safe failure (no crash).

## Next Steps
- Prepare print integration phase using exported file handoff only (Windows print service).

## Test Matrix
- Unit: filename generator, geometry mapping, precondition checks.
- Integration: export request from composed state to disk output.
- E2E: full camera-folder-simulated flow to final export file.

## Rollback Plan
- Disable export action while preserving ingest/composer UI; operators can still stage photos.

## Backwards Compatibility
- Export output format documented; future print phase consumes same file contract.
