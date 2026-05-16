# Context
- `main.dart` hiện có export + optional print pipeline (`lib/main.dart:139-167`).
- `export_actions.dart` có UI controls cho print; chưa có toggle USB transfer.

# Overview
- Date: 2026-05-16
- Priority: high
- Status: pending

# Key Insights
- Tích hợp nên theo thứ tự: export thành công -> transfer auto -> (tùy policy) print hoặc print song song.
- UX cần tách bạch: “export thành công nhưng transfer thất bại” thay vì fail toàn bộ.

# Requirements
- Thêm flag `autoTransferToPhone` bật mặc định cho Android workflow.
- Mở rộng status message để hiển thị 2 lớp kết quả: export + transfer.
- Không thay đổi contract của `ExportService` hiện tại (giảm blast radius).

# Architecture
- Data flow mới trong `_handleExport()`:
  1) Export PNG -> lấy `result.filePath`.
  2) Nếu success && autoTransfer: gọi `PhoneTransferService.transfer(filePath)`.
  3) Build message tổng hợp theo matrix.
  4) Tiếp tục nhánh print (nếu bật) không phụ thuộc transfer.
- Message matrix (sample):
  - Export OK + Transfer OK + Print OK.
  - Export OK + Transfer SKIPPED (no device).
  - Export OK + Transfer FAILED (permission/mtp).
  - Export FAIL (dừng các bước sau).

# Related code files
- `lib/main.dart` — **modify** — add transfer service, toggle state, orchestration.
- `lib/features/export/presentation/export_actions.dart` — **modify** — thêm switch “Gửi sang điện thoại”.
- `lib/core/config/app_paths.dart` — **modify (optional)** — tinh chỉnh `phoneSyncHint` cho dual mode OneDrive+USB.

# Implementation Steps
1. Inject `PhoneTransferService` vào stateful page.
2. Thêm UI switch và tooltip hướng dẫn điều kiện MTP (unlock + File Transfer mode).
3. Cập nhật `_handleExport` sequencing + status merge logic.
4. Thêm debug logs (assert-only) cho diagnosis.

# Todo list
- [ ] Thêm state + UI control auto transfer
- [ ] Tích hợp transfer orchestration vào `_handleExport`
- [ ] Chuẩn hóa status message matrix

# Success Criteria
- Operator bật/tắt được auto-transfer ngay trên UI.
- Export flow không regress: vẫn tạo file output, vẫn in nếu bật.
- Status message phân biệt rõ success/failed/skipped cho transfer.

# Risk Assessment
- Medium: chuỗi thao tác dài làm UI message khó hiểu (L: medium, I: medium).
  - Mitigation: chuẩn hóa template thông báo theo matrix.
- Medium: transfer timeout khiến user nghĩ app treo (L: medium, I: medium).
  - Mitigation: loading state riêng hoặc message “Đang gửi sang điện thoại…”.

# Security Considerations
- Không hiển thị full path nhạy cảm quá dài trong UI công khai nếu không cần.
- Không cho user nhập đích tự do trong phase này (giảm misuse).

# Next Steps
- Sang Phase 04 hoàn thiện test matrix + rollback/fallback playbook.
