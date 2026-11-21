# S13 – Chat trong kèo (UC13)

- Mở từ Chi tiết kèo: thành viên đã được nhận bấm **Chat**; chủ kèo có nút **Chat** cạnh "Quản lý kèo".
- Màn chat: tiêu đề là tên kèo + giờ đá. 50 tin gần nhất, tin mới ở dưới, tự cập nhật khi có tin mới.
  - Tin của mình: bong bóng xanh bên phải. Tin người khác: bong bóng trắng bên trái, có tên người gửi khi đổi người.
  - Giờ gửi dưới mỗi tin; tin đang chờ server hiện "Đang gửi…".
- Ô nhập tối đa 1000 ký tự, nút gửi xám khi chưa nhập. Gửi lỗi thì báo "Không gửi được, thử lại" và giữ nguyên chữ.
- Quá 24 giờ sau giờ kết thúc: thay ô nhập bằng dòng "Chat đã đóng…", vẫn đọc được tin cũ.
- Người ngoài, người đang chờ duyệt không đọc được chat (rules chặn).

Rules: `matches/{id}/messages/{msgId}` chỉ chủ kèo và thành viên `approved` đọc/tạo; `senderId` là chính mình, `senderName` khớp hồ sơ, 1–1000 ký tự, giờ server; không sửa, không xóa.

## Để sau

- Thông báo khi có tin mới (cần đếm tin chưa đọc theo từng người).
- Gửi ảnh, ghim tin của chủ kèo.
