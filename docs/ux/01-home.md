# UX – Mở app & Khám phá (S01, S02, S06)

Trạng thái: đã duyệt (24/10/2026). UI đã dựng trên Figma, xem [ui/01-home.md](../ui/01-home.md).

## Luồng lần đầu (Khách)
Mở app → xin quyền vị trí → giới thiệu 2 slide → Home (xem tự do).
Bấm Xin vào / Tạo kèo / Thông báo / Hồ sơ → Đăng nhập → quay lại đúng chỗ vừa bấm.
Lần sau vào thẳng Home. Đã đăng nhập mà hồ sơ chưa đủ thì sang S05.

- Từ chối vị trí: app vẫn chạy, xếp theo giờ, hiện thanh nhắc [Bật vị trí].
- Giới thiệu: (1) Tìm kèo gần bạn, (2) Tạo kèo, gom đủ người. Có Bỏ qua / Tiếp tục.

## Khung Home (S06)
Header (logo, chuông; Khách thấy nút Đăng nhập) → dòng vị trí/quận (bấm đổi quận) → ô tìm kiếm + nút bộ lọc S07 → hàng icon môn (Tất cả, bóng đá, cầu lông, bóng rổ, pickleball, tennis) → chip thời gian (Hôm nay, Ngày mai, Cuối tuần) → danh sách thẻ kèo → tab bar (Khám phá, Kèo của tôi, +Tạo kèo, Thông báo, Hồ sơ).

Thẻ kèo: môn + tên, khoảng cách, giờ + quận, trình độ, tiền/người, số chỗ còn, avatar chủ kèo, nút [Xin vào].

## Quy tắc
- Mặc định xếp gần tôi nhất; không có vị trí thì xếp bắt đầu sớm nhất.
- Chỉ hiện kèo còn mở, chưa bắt đầu. Kèo đủ người vẫn hiện, mờ, nút "Đã đủ".
- Chạm thẻ → S08. Khách xem được, chỉ bị chặn khi bấm Xin vào.

## Trạng thái
| Trạng thái | Hiển thị | Hành động |
|---|---|---|
| Đang tải | 3 thẻ xám (skeleton) | – |
| Không có kèo | "Chưa có kèo nào gần bạn" | [Tạo kèo] [Xóa bộ lọc] |
| Mất mạng | "Không kết nối được" | [Thử lại] |
| Từ chối vị trí | Thanh nhắc trên danh sách | [Bật vị trí] |
| Hết danh sách | "Bạn đã xem hết" | – |
