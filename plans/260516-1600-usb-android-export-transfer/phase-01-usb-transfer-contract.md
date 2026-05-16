# Context
- User confirmed target: **Android qua cáp USB**.
- User wants: **Auto copy ngay sau Export**.
- Existing behavior: export PNG thành công vào OneDrive `PhotoBoothSync` / local exports (`lib/core/config/app_paths.dart:22-36`, `lib/features/export/application/export_service.dart:38-52`).

# Overview
- Date: 2026-05-16
- Priority: high
- Status: pending

# Key Insights
- MTP Android trên Windows thường không expose như drive letter; cần adapter chuyên biệt thay vì `File.copy` trực tiếp.
- Export local phải luôn là source of truth; USB transfer chỉ là bước best-effort hậu export.
- Hệ hiện có đã có pattern status message sau export (`lib/main.dart:139-167`) để gắn kết quả transfer.

# Requirements
- Thêm contract chuẩn cho kết quả transfer: success/failed/skipped + reason + target device/folder.
- Transfer không được chặn hoặc rollback export file local.
- Nếu không phát hiện thiết bị Android hợp lệ: trả trạng thái `skipped` với thông điệp hành động cho operator.

# Architecture
- Data flow:
  1) `ExportService.export` tạo file PNG (input: `ExportRequest`, output: `ExportResult.filePath`).
  2) `PhoneTransferOrchestrator` nhận `filePath` + policy auto-transfer.
  3) Adapter Windows-MTP cố gắng resolve thiết bị + folder đích (`Pictures/PhotoBooth` mặc định).
  4) Kết quả trả về UI message gộp (export + transfer + print).
- Contracts đề xuất:
  - `PhoneTransferRequest{sourceFilePath, preferredRelativeTargetDir}`
  - `PhoneTransferResult{status, targetPath?, deviceName?, errorCode, message}`
  - `PhoneTransferStatus = success | skipped | failed`

# Related code files
- `lib/features/export/domain/export_request.dart` — **read-only** — giữ contract export hiện tại.
- `lib/features/export/domain/phone_transfer_result.dart` — **create** — model kết quả transfer.
- `lib/features/export/domain/phone_transfer_request.dart` — **create** — model input transfer.
- `lib/main.dart` — **modify (later phase)** — nối orchestration vào hậu export.

# Implementation Steps
1. Định nghĩa enum/status + error taxonomy (NO_DEVICE, PERMISSION_DENIED, TARGET_NOT_FOUND, TRANSFER_IO).
2. Định nghĩa request/result immutable models cho luồng transfer.
3. Định nghĩa interface `PhoneTransferService` cho platform adapter.
4. Gắn default target folder policy (Android `Pictures/PhotoBooth`) + fallback behavior.

# Todo list
- [ ] Chốt transfer status/error taxonomy
- [ ] Chốt interface service + contracts
- [ ] Chốt target-folder policy trên Android

# Success Criteria
- Có contract rõ ràng đủ để implement adapter mà không sửa ngược export domain.
- Mọi trạng thái transfer map được thành UI message cụ thể.
- Không phát sinh dependency vòng giữa export domain và platform layer.

# Risk Assessment
- Risk: taxonomy thiếu trường hợp lỗi MTP (Likelihood: medium, Impact: medium).
  - Mitigation: chuẩn hóa errorCode mở rộng + log raw error.
- Risk: target folder policy không tồn tại trên vài máy (L: high, I: medium).
  - Mitigation: create-if-possible, else fallback root camera folder + message rõ.

# Security Considerations
- Chỉ copy từ file app vừa export; không cho path tùy ý từ UI.
- Sanitize relative target path, cấm traversal (`..`).
- Không log dữ liệu nhạy cảm ngoài device name/path kỹ thuật.

# Next Steps
- Sang Phase 02 triển khai adapter discovery/copy theo contract này.
