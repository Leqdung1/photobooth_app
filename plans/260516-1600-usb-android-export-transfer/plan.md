---
title: Android USB auto-transfer after export
date: 2026-05-16 16:00
status: in_progress
priority: high
blocks: []
blockedBy: []
---

# Plan Overview

Scope mode: **HOLD** (giữ OneDrive export hiện tại, thêm luồng copy tự động sang Android qua cáp khi khả dụng).
Mode: **--hard** (Windows + MTP có rủi ro tương thích và lỗi runtime).

## Scope challenge summary
- Reusable code: export pipeline đã ổn định (`ExportService.export`), trạng thái UI export, startup validation, app paths.
- Minimum changes: thêm service phát hiện thiết bị Android + copy file sau export + trạng thái UI rõ ràng.
- Complexity: medium-high (MTP trên Windows không phải filesystem chuẩn, lỗi quyền/thư mục thường gặp).
- Not in scope: iPhone USB copy, Wi‑Fi transfer, background daemon sync, sửa luồng in.

## Cross-Plan Dependencies
- Đã rà `plans/260515-1200-readme-execution` và `plans/260516-1015-multi-frame-selector` (đều completed).
- Overlap vùng `lib/main.dart` + export flow; không có active blocker.

## Phases
1. [Phase 01 - USB transfer contract & platform constraints](./phase-01-usb-transfer-contract.md) — completed
2. [Phase 02 - Windows Android device discovery + copy adapter](./phase-02-windows-mtp-adapter.md) — in_progress
3. [Phase 03 - Export flow integration + UX states](./phase-03-export-integration-ux.md) — completed
4. [Phase 04 - Test matrix, fallback, rollback hardening](./phase-04-tests-fallback-rollback.md) — pending

## Dependency graph
- P1 unblocks toàn bộ (contract + lỗi chuẩn hóa).
- P2 depends on P1.
- P3 depends on P1+P2.
- P4 depends on P2+P3.

## File ownership matrix
- P1: `lib/features/export/domain/*` (new), `lib/core/config/app_paths.dart`.
- P2: `lib/features/export/application/windows_*transfer*.dart` (new), optional `pubspec.yaml` nếu thêm package.
- P3: `lib/main.dart`, `lib/features/export/presentation/export_actions.dart`.
- P4: `test/export/*`, docs plan/report only.

## Success definition
- Sau export thành công, app tự thử gửi ảnh mới sang Android đang cắm cáp (không chặn export local).
- Nếu không có thiết bị hoặc copy fail: user thấy thông báo lỗi rõ + file vẫn tồn tại ở OneDrive/exports.
- Không làm hỏng luồng in hiện tại (`printAfterExport`) và không crash UI.

## Model override note
- Nếu cần chiều sâu planning/review: dùng `internal.model.plan`.
