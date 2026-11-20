# S14 – Thông báo trong app

Không có server (gói Spark) nên app của **người làm hành động** ghi thông báo vào `users/{người nhận}/notifications`, sau khi hành động đã thành công. Gửi lỗi thì bỏ qua, không làm hỏng hành động chính.

| Hành động | Người nhận | Nội dung |
|---|---|---|
| Xin vào kèo duyệt tay | Chủ kèo | "An xin vào “Đá bóng 5 người”" |
| Vào kèo tự động | Chủ kèo | "An đã vào …" |
| Chủ kèo nhận / từ chối / mời ra | Người đó | "Bạn đã được nhận vào …" / "Chủ kèo đã từ chối …" / "Bạn đã được mời ra khỏi …" |
| Rời kèo | Chủ kèo | "An đã rời …" |
| Hủy kèo | Thành viên + người chờ duyệt | "… đã bị hủy, tìm kèo khác cùng giờ nhé" |
| Sửa giờ hoặc sân | Thành viên | "… vừa đổi giờ hoặc sân" |
| Chốt kèo | Thành viên | "… đã chốt, hẹn gặp ở sân" |

Màn Thông báo (tab thứ tư): danh sách mới nhất trước (50 cái), chưa đọc có nền xanh nhạt và chấm xanh, bấm để mở Chi tiết kèo và đánh dấu đã đọc, nút "Đọc hết". Số chưa đọc hiện ở chuông trang chủ và tab Thông báo.

Rules: chỉ tạo được 9 loại đã định nghĩa, `actorId` là chính mình, không gửi cho chính mình, không thêm trường lạ; người nhận chỉ đổi được `read`.

## Để sau

- Thông báo đẩy khi app đóng (cần server hoặc Cloud Functions).
- Nhắc trước hạn chốt và trước giờ đá bằng thông báo trên máy.
