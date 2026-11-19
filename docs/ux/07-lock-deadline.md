# Chốt kèo và hạn chốt người

Mục tiêu: người chơi biết sớm kèo có thành không để còn tìm kèo khác, chủ kèo kịp hủy sân mà không mất cọc. Tiền sân do người chơi tự giải quyết ngoài app; app chỉ báo giá mỗi người (nút "Thanh toán" tạm ẩn, code và rules giữ nguyên).

## Phần 1 – Chốt kèo

- Ở Quản lý kèo có thanh trạng thái trên hai tab:
  - Đang nhận người: "Đang nhận người · đã nhận 3/6" + nút **Chốt kèo**.
  - Đã chốt: "Đã chốt · không nhận thêm người" + nút **Mở lại** (chỉ khi kèo chưa bắt đầu).
- Bấm Chốt kèo → hộp xác nhận. Nếu còn yêu cầu chờ duyệt: "N yêu cầu đang chờ sẽ bị từ chối". Xác nhận → kèo `locked = true`, các yêu cầu `pending` chuyển `rejected` trong cùng một batch.
- Kèo đã chốt: không ai xin vào được (rules chặn). Thẻ ở Khám phá mờ, nút "Đã chốt". Chi tiết kèo: nút xám "Kèo đã chốt".

## Phần 2 – Hạn chốt người và số người tối thiểu

Ở màn Tạo/Sửa kèo, thẻ "Số người" thêm:

| Trường | Cách nhập | Ràng buộc |
|---|---|---|
| Cần ít nhất | Nút − / + | 1 đến số chỗ cần tuyển, mặc định bằng số chỗ cần tuyển |
| Hạn chốt người | Chip: 2 giờ trước · Tối hôm trước (20:00) · Tự chọn · Không đặt | Trước giờ đá ít nhất 30 phút, sau bây giờ. Kèo đá sau hơn 6 giờ nữa thì bắt buộc đặt hạn (không có chip "Không đặt") |

Dưới chip hiện "Chốt lúc 20:00 T7, 22/11 · nên đặt trước hạn hủy sân miễn phí".

Khi qua hạn:

- Kèo tự dừng nhận người (rules chặn theo `joinDeadline`), thẻ Khám phá "Hết hạn nhận".
- Chủ kèo mở Quản lý kèo mà kèo chưa chốt và chưa đủ số tối thiểu → hộp "Kèo chưa đủ người. Bạn có đủ người ngoài app không?":
  - **Vẫn đá** → chốt kèo.
  - **Gia hạn** → mở Sửa kèo.
  - **Hủy kèo** → bảng chọn lý do như cũ.
- Đã đủ tối thiểu mà chưa chốt → chỉ nhắc bằng thanh trạng thái "Đã qua hạn, bấm Chốt kèo để báo mọi người".

Chi tiết kèo hiện dòng "Hạn chốt người: 20:00 T7, 22/11".

## Để sau

- Nhãn tình trạng kèo (Đã chốt / Đang tìm người / Có nguy cơ bể / Bể).
- Tìm kèo cùng giờ, Theo dõi kèo.
- Nhắc trước hạn chốt bằng thông báo trên máy.
- Hàng chờ cho kèo đủ người.
