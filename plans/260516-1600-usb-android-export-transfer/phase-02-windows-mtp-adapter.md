# Context
- Cần bridge từ Flutter desktop (Windows) sang Android device cắm cáp (MTP/File Transfer).
- Không có code USB transfer hiện hữu trong `lib/features/export/application` ngoài in và export.

# Overview
- Date: 2026-05-16
- Priority: high
- Status: pending

# Key Insights
- Có thể cần package/plugin Windows để enumerate Portable Devices hoặc shell automation.
- Độ ổn định phụ thuộc trạng thái máy: unlock màn hình, mode File Transfer, quyền truy cập.
- Luồng nên timeout nhanh (ví dụ 3-5s discovery, 10-15s copy) để không treo UI export.

# Requirements
- Device discovery: tìm ít nhất 1 Android device writable.
- Destination resolve: đảm bảo thư mục đích tồn tại hoặc tạo được.
- Copy operation: atomic best-effort, trả status chi tiết.
- Structured logging cho debug tại hiện trường.

# Architecture
- Components:
  - `WindowsAndroidTransferService implements PhoneTransferService`
  - `WindowsDeviceDiscovery` (internal helper)
  - `WindowsMtpCopyAdapter` (internal helper)
- Data flow:
  1) `transfer(request)` gọi discovery.
  2) Nếu 0 devices → `skipped(NO_DEVICE)`.
  3) Nếu >1 devices → chọn rule deterministic (first writable / preferred by cached id).
  4) Copy file + verify size>0 tại đích.
  5) Trả `success/failed`.

# Related code files
- `lib/features/export/application/windows_android_transfer_service.dart` — **create** — service chính.
- `lib/features/export/application/windows_device_discovery.dart` — **create** — tách discovery.
- `lib/features/export/application/windows_mtp_copy_adapter.dart` — **create** — copy/verify.
- `pubspec.yaml` — **modify (optional)** — thêm dependency nếu chọn plugin.

# Implementation Steps
1. Khảo sát 1 approach khả thi nhất (plugin native hoặc shell COM bridge), tránh over-engineering.
2. Implement discovery abstraction + fake adapter cho test.
3. Implement copy + timeout + retry nhẹ (1 lần).
4. Chuẩn hóa mapping exception -> `errorCode`.

# Todo list
- [ ] Chốt công nghệ discovery/copy trên Windows
- [ ] Thiết kế timeout/retry policy
- [ ] Thiết kế verify-after-copy

# Success Criteria
- Service trả được 3 trạng thái deterministic trong mọi nhánh lỗi chính.
- Không block UI thread; mọi I/O async.
- Khi Android không sẵn sàng, lỗi user-facing rõ ràng, không crash.

# Risk Assessment
- High: plugin Windows không hỗ trợ MTP ổn định (L: high, I: high).
  - Mitigation: abstraction layer + fallback mode (skip + hướng dẫn thao tác thủ công).
- Medium: nhiều thiết bị cùng cắm gây chọn sai đích (L: medium, I: medium).
  - Mitigation: rule chọn thiết bị minh bạch + hiển thị deviceName đã gửi.

# Security Considerations
- Không execute shell command với input chưa sanitize.
- Validate source file tồn tại và extension png/jpg trước copy.
- Giới hạn quyền chỉ ghi vào thư mục media thường dùng.

# Next Steps
- Sang Phase 03 tích hợp service vào `_handleExport` và UI controls.
