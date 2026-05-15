# Phase 02 — Ingest pipeline (watcher + gallery)

## Context
README requires automatic detection of new images in inbox and display in left panel (`README.md:197-201`, `README.md:237-245`).

## Overview
- Date: 2026-05-15
- Priority: High
- Status: completed

## Key Insights
- File watcher events may fire before file write completes; naive load causes corrupted thumbnails.
- Need dedup and stable ordering for operator confidence.

## Requirements
- Watch inbox directory for supported image extensions.
- Debounce/retry load until file is readable.
- Maintain in-memory gallery state: id/path/createdAt/thumb status.
- Render left panel list with thumbnail + selection affordance.

## Architecture
Data flow:
1) Folder watcher emits create/modify events.
2) Ingest service filters extension and checks file readiness.
3) Thumbnail loader generates preview metadata.
4) Gallery store updates ordered list and notifies UI.
Output: selectable photo collection for composer phase.

## Related code files
- `lib/features/ingest/domain/photo_asset.dart` — create — ingest entity model.
- `lib/features/ingest/data/folder_watch_service.dart` — create — watcher adapter + retries.
- `lib/features/ingest/data/thumbnail_service.dart` — create — preview generation.
- `lib/features/ingest/presentation/gallery_panel.dart` — create — left panel UI.
- `lib/main.dart` — modify — mount gallery panel and shared app state.

## Implementation Steps
1. Define image extension whitelist + event filters.
2. Implement resilient watcher with retry/backoff for locked files.
3. Build gallery state notifier with dedup + sorting policy.
4. Implement thumbnail list UI with selection callback.
5. Add telemetry hooks (counts/errors) for diagnostics.

## Todo list
- [x] Implement watcher adapter with readiness checks.
- [x] Add gallery domain/store.
- [x] Render panel + selection interactions.
- [ ] Add tests for duplicate and partial-write scenarios.

## Success Criteria
- New image in inbox appears in UI within target SLA (<=2s after file complete).
- Partial copy/write does not crash or create broken entry.
- Duplicate events do not duplicate thumbnails.

## Risk Assessment
- Risk: race condition on network/USB camera writes. Likelihood: High, Impact: High.
  - Mitigation: readiness probe + retry with max timeout.
- Risk: memory growth from unbounded thumbnails. Likelihood: Medium, Impact: Medium.
  - Mitigation: thumbnail caching limits + lazy loading.

## Security Considerations
- Restrict ingest to image MIME/extensions only.
- Ignore hidden/system files to reduce accidental exposure.

## Next Steps
- Provide stable asset IDs for 2x2 slot assignment.

## Test Matrix
- Unit: extension filter, dedup logic, sort ordering.
- Integration: watcher event simulation including delayed file readiness.
- E2E: drop 10 images quickly and verify ordered gallery population.

## Rollback Plan
- Disable watcher initialization behind feature flag and fall back to static empty gallery shell.

## Backwards Compatibility
- No persistent storage introduced; safe rollback to pre-ingest shell.
