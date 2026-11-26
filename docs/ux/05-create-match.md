# S09 – Tạo kèo

Một màn cuộn, mở từ nút "+" ở thanh dưới (khách phải đăng nhập trước). Đăng xong mở thẳng Chi tiết kèo vừa tạo.

## Các trường

| Trường | Cách nhập | Ràng buộc |
|---|---|---|
| Môn | 5 ô môn, chọn sẵn môn đầu tiên trong hồ sơ | Bắt buộc |
| Thể thức | Chip theo môn, chọn xong điền sẵn tổng số người | Bóng đá: sân 5/7/11 · Bóng rổ: 3x3, 5v5 · Cầu lông, Pickleball, Tennis: đơn/đôi |
| Tên kèo | Ô chữ, tự ghép "Môn + thể thức" cho tới khi người dùng sửa | 1–60 ký tự |
| Số chỗ cần tuyển | Nút − / + | 1 đến tổng số người − 1 (chủ kèo chiếm 1 chỗ) |
| Ngày, giờ bắt đầu | Date picker, time picker | Sau hiện tại ít nhất 30 phút, trong vòng 30 ngày (BR01) |
| Thời lượng | Chip 1 giờ / 1,5 giờ / 2 giờ / 3 giờ | Mặc định 2 giờ |
| Sân | Bảng chọn danh sách sân có môn đã chọn, không có thì thêm sân mới ([12-add-venue](12-add-venue.md)) | Bắt buộc |
| Trình độ | Thanh kéo khoảng Mới chơi – Giỏi | Mặc định cả 4 mức |
| Tổng tiền sân | Ô số (đồng), hiện ngay "≈ X đ/người" (BR02) | ≥ 0, 0 = miễn phí |
| Tự động nhận người | Công tắc | Mặc định tắt (duyệt tay) |
| Ghi chú | Ô chữ nhiều dòng | ≤ 500 ký tự |

## Trạng thái và lỗi

| Tình huống | Hiển thị |
|---|---|
| Thiếu sân hoặc tên kèo trống | Nút "Đăng kèo" xám |
| Giờ bắt đầu chưa đủ 30 phút tới | Chữ đỏ dưới ô giờ "Giờ bắt đầu phải sau bây giờ ít nhất 30 phút" |
| Đang lưu | Nút "Đang đăng…", khóa bấm |
| Mất mạng / lỗi lưu | Chữ đỏ trên nút "Không đăng được kèo, thử lại", giữ nguyên dữ liệu (E3) |

## Sửa kèo (UC09)

Mở từ nút "Sửa" ở màn Quản lý kèo (chỉ khi kèo chưa bắt đầu, chưa hủy). Dùng lại màn này với dữ liệu điền sẵn, tiêu đề "Sửa kèo", nút "Lưu thay đổi".

- Không đổi được môn (chỉ hiện môn hiện tại).
- Số chỗ cần tuyển không giảm dưới số người đã nhận; thể thức nào quá ít người so với số đã nhận thì báo và không cho chọn.
- Lưu xong quay về Quản lý kèo, hiện "Đã lưu thay đổi". Tiền mỗi người và "đủ người" tính lại theo dữ liệu mới.

## Để sau

- Báo cho thành viên khi đổi giờ hoặc sân (chờ lát Thông báo).
- Nhắc bổ sung tài khoản ngân hàng khi có thu tiền (10a), bản sao `private/payment`.
- Uy tín tối thiểu.
- Nút chia sẻ link sau khi đăng.
