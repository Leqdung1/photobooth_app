# Context
- USB transfer là integration nhạy platform; cần test + rollback rõ trước khi code merge.

# Overview
- Date: 2026-05-16
- Priority: high
- Status: pending

# Key Insights
- Unit tests chủ yếu cover contract mapping; integration test cần manual matrix trên Windows thật.
- Rollback đơn giản nhất: disable auto-transfer feature flag nhưng giữ export core.

# Requirements
- Test matrix đủ 3 tầng: unit, integration (mock adapter), E2E manual.
- Backward compatibility: project chạy bình thường kể cả không có điện thoại.
- Rollback runbook: cách tắt feature trong 1 commit/release.

# Architecture
- Verification flow:
  1) Unit test domain models + status mapping.
  2) Integration test orchestration `_handleExport` path (mock transfer outcomes).
  3) Manual E2E trên 4 case chính.

# Related code files
- `test/export/phone_transfer_result_test.dart` — **create**.
- `test/export/windows_android_transfer_service_test.dart` — **create**.
- `test/export/export_flow_transfer_integration_test.dart` — **create/modify**.
- `plans/260516-1600-usb-android-export-transfer/reports/manual-e2e-checklist.md` — **create**.

# Implementation Steps
1. Viết test cases cho status matrix và error mapping.
2. Mock transfer service để verify message merge logic trong export flow.
3. Tạo manual checklist: device connected/disconnected/locked/multi-device.
4. Viết rollback note: tắt toggle mặc định + bypass service call.

# Todo list
- [ ] Hoàn thành test matrix 3 tầng
- [ ] Tạo manual E2E checklist
- [ ] Soạn rollback + release note

# Success Criteria
- Có test chứng minh: export fail không gọi transfer; export success gọi transfer đúng 1 lần.
- Manual checklist pass ít nhất: No-device, Device-ready, Permission-denied, Transfer-timeout.
- Có rollback procedure thực thi được <30 phút, không ảnh hưởng export core.

# Risk Assessment
- High: thiếu test integration dẫn lỗi runtime ngoài hiện trường (L: medium, I: high).
  - Mitigation: bắt buộc pass checklist manual trước release.
- Medium: rollback chậm vì coupling trong `main.dart` (L: medium, I: medium).
  - Mitigation: giữ orchestration sau feature flag/toggle tách biệt.

# Security Considerations
- Kiểm tra không ghi nhầm vào thư mục hệ thống thiết bị.
- Không lưu persistent identifier nhạy cảm của thiết bị nếu chưa cần.

# Next Steps
- Handoff cho cook để triển khai theo thứ tự phase + verification commands.
