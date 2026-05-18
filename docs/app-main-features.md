# Danh sách chức năng chính của app (phục vụ làm lại UI)

## 1) Quản lý thư mục ảnh đầu vào (Inbox)
- Hiển thị thư mục nhận ảnh hiện tại trên thanh trên cùng.
- Cho phép đổi thư mục Inbox bằng nút **"Đổi thư mục"**.
- Lưu cấu hình thư mục đã chọn để dùng lại cho lần mở app sau.

## 22) Gallery ảnh (panel trái)
- Hiển thị danh sách ảnh theo thời gian (mới nhất trước).
- Hiển thị thumbnail, tên file, thời gian ảnh.
- Cho phép chọn ảnh để gán vào ô đang chọn trong khung ghép.

##334) Composer ghép ảnh theo template
- Có chọn **template khung** (hiện tại có preset, mặc định 1x2).
- Có lưới slot để gán ảnh vào từng ô.
- Chọn slot đang thao tác.
- Xóa ảnh theo từng slot.
- Reset toàn bộ slot.

## 5) Preview trước khi xuất
- Tạo preview ảnh ghép.
- Mở dialog xem trước kết quả export.

## 6) Export ảnh final
- Ghép ảnh theo layout hiện tại.
- Xuất file ảnh final vào thư mục exports.
- Tránh overwrite bằng cơ chế đặt tên phù hợp (theo service export).

## 7) In ảnh sau export (Windows Print)
- Tuỳ chọn bật/tắt **"In sau export"**.
- Khi bật: sau khi export sẽ gọi luồng in Windows.

## 8) Chuyển ảnh sang điện thoại Android
- Tuỳ chọn bật/tắt **"Gửi sang điện thoại"**.
- Khi bật: tự thử chuyển file export sang Android qua USB (MTP/File Transfer).

## 9) Trạng thái và thông báo vận hành
- Hiển thị trạng thái khởi tạo, đổi thư mục, preview/export.
- Hiển thị lỗi watcher, lỗi export, lỗi in, kết quả transfer.

---

## Gợi ý nhóm màn hình khi redesign UI
1. **Workspace Screen**: Gallery + Composer + Preview + Export actions (màn hình chính hiện tại).
2. **Input Source Settings**: cấu hình thư mục nhận ảnh / trạng thái watcher.
3. **Output & Device Settings**: in ấn, chuyển điện thoại, thư mục export.
4. **Template Picker**: quản lý/chọn bố cục frame.

---
