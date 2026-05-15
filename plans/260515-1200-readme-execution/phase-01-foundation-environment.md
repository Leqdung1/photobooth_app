# Phase 01 — Foundation & environment contract

## Context
README defines Windows-local workflow with inbox/exports folders and no backend (`README.md:5-16`, `README.md:67-75`). Current app is template only (`lib/main.dart:1-125`).

## Overview
- Date: 2026-05-15
- Priority: High
- Status: completed

## Key Insights
- Biggest early failure mode: ambiguous runtime folders across machines.
- Need deterministic config before watcher/export logic to avoid invalid paths.

## Requirements
- Add required dependencies listed by README (watcher/path/path_provider/image libs) with vetted versions.
- Define local folder contract and startup validation (inbox, exports, templates optional).
- Replace sample app shell with desktop-first scaffold ready for feature injection.

## Architecture
Data flow:
1) App startup reads config (default root + optional override).
2) Validate/create required folders.
3) Emit normalized absolute paths for ingest/export modules.
Output: typed environment object consumed by later phases.

## Related code files
- `pubspec.yaml` — modify — add runtime deps. Depends on this phase only.
- `lib/main.dart` — modify — replace counter scaffold with app shell/bootstrap.
- `lib/core/config/app_paths.dart` — create — path model + normalization helpers.
- `lib/core/config/startup_validator.dart` — create — folder checks/create policy.
- `README.md` — modify — operator setup/run instructions aligned to actual implementation.

## Implementation Steps
1. Add dependencies and run lockfile refresh.
2. Introduce app path config model with explicit Windows examples.
3. Implement startup validator (exists/create/error reporting contract).
4. Wire bootstrap into app entry point and render minimal shell with error banner state.
5. Update README setup instructions to match runtime behavior.

## Todo list
- [x] Add and pin MVP dependencies in `pubspec.yaml`.
- [x] Create typed config/validation modules.
- [x] Replace demo UI with feature-ready shell.
- [x] Document setup + fallback behaviors in README.

## Success Criteria
- App launches without counter demo UI.
- Missing folder scenarios produce actionable error state, not crash.
- Required directories exist or are auto-created per policy.

## Risk Assessment
- Risk: invalid path permissions on Windows kiosk PCs. Likelihood: Medium, Impact: High.
  - Mitigation: explicit permission/error messages + non-destructive fallback prompt.
- Risk: dependency conflicts with Flutter SDK. Likelihood: Low, Impact: Medium.
  - Mitigation: lock tested versions; record tested Flutter version.

## Security Considerations
- Treat configured root path as untrusted input; normalize and reject traversal-like malformed values.
- Avoid logging sensitive full user profile paths in production logs.

## Next Steps
- Handoff validated path contract to ingest phase.

## Test Matrix
- Unit: path normalization and folder policy decisions.
- Integration: app startup with missing/existing folders.
- E2E: Windows launch smoke with configured root.

## Rollback Plan
- Revert to prior bootstrap and dependency set via single commit rollback.
- Preserve no data migrations in this phase, so rollback is low-impact.

## Backwards Compatibility
- Existing users (none/prototype) keep default behavior; no persisted schema changes.
