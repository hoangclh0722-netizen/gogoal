# S16 – Kèo của tôi

Tab thứ hai trên thanh dưới (khách phải đăng nhập trước). Gồm kèo mình tạo, kèo mình đã vào và kèo đang chờ duyệt.

## Bố cục

Header xanh "Kèo của tôi" → hai tab "Sắp tới · N" / "Đã qua" → danh sách thẻ → thanh dưới (tab "Kèo của tôi" sáng).

Mỗi thẻ: vạch màu môn, tên kèo, nhãn vai trò, giờ, sân · quận, số đã nhận/cần tuyển. Bấm thẻ mở Chi tiết kèo; quay lại thì danh sách tải lại.

| Nhãn | Khi nào |
|---|---|
| Chủ kèo | Mình tạo kèo |
| Đã vào | participant `approved` |
| Chờ duyệt | participant `pending` |
| Đã hủy | Kèo `cancelled` (thẻ mờ), ưu tiên hơn các nhãn khác |

Yêu cầu bị từ chối, đã rời hoặc bị mời ra thì không hiện.

- Sắp tới: kèo chưa kết thúc, sớm nhất lên đầu.
- Đã qua: kèo đã kết thúc, gần nhất lên đầu.

## Trạng thái

| Tình huống | Hiển thị |
|---|---|
| Đang tải | Vòng xoay |
| Trống (Sắp tới) | "Chưa có kèo sắp tới" + nút "Tìm kèo" (về Khám phá), "Tạo kèo" |
| Trống (Đã qua) | "Chưa có kèo nào đã qua" |
| Lỗi mạng | "Không tải được kèo của bạn" + "Thử lại" |
| Kéo xuống | Tải lại |

## Để sau

- Tải thêm khi cuộn (hiện lấy hết một lần).
- Lọc theo môn trong "Kèo của tôi".
