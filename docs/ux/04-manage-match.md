# UX – Quản lý kèo: duyệt, mời ra, hủy kèo (S11)

Trạng thái: đã chốt nội dung (12/11/2026). Bố cục chốt theo [Figma](https://www.figma.com/design/VWNTYmdK4H0Br5EjhFqdUJ).

## Chia phần để làm và commit dần
1. Màn Quản lý kèo: danh sách chờ duyệt, Nhận / Từ chối; nút ở Chi tiết kèo hiện số yêu cầu chờ.
2. Mời thành viên ra khỏi kèo.
3. Hủy kèo kèm lý do.

## Luồng
- Chủ kèo mở Chi tiết kèo của mình → nút "Quản lý kèo · 2 chờ duyệt" (không có yêu cầu thì chỉ "Quản lý kèo") → màn Quản lý kèo.
- Chỉ chủ kèo vào được màn này. Kèo đã bắt đầu hoặc đã hủy: chỉ xem, không có nút hành động.

## Nội dung màn
- Đầu màn: nút quay lại, tên kèo, giờ, "Đã nhận 2/4". Nút "Hủy kèo" (phần 3).
- **Chờ duyệt:** mỗi yêu cầu một thẻ: ảnh, tên, trình độ ở môn này, uy tín (chưa có thì "Chưa có đánh giá"), lời nhắn (nếu có), thời gian xin ("15 phút trước"). Hai nút: "Từ chối" (viền) và "Nhận" (xanh).
- **Thành viên:** chủ kèo ở đầu (nhãn "Chủ kèo"), sau đó từng thành viên: ảnh, tên, trình độ, nút "Mời ra" (phần 2).
- Không có yêu cầu nào: "Chưa có ai xin vào".

## Hành động
| Hành động | Hỏi lại? | Kết quả |
|---|---|---|
| Nhận | Không | Người chơi → `approved`, số chỗ đã nhận + 1. Kèo đủ người thì nút "Nhận" xám + "Kèo đã đủ người" |
| Từ chối | Không | Người chơi → `rejected`, biến khỏi danh sách chờ |
| Mời ra | Có: "Mời Tuấn ra khỏi kèo?" Hủy / Mời ra | Người chơi → `removed`, số chỗ đã nhận − 1 |
| Hủy kèo | Có: chọn lý do | Kèo → `cancelled`, lưu lý do. Mọi người mở Chi tiết kèo thấy băng "Kèo đã bị hủy" |

Lý do hủy (bắt buộc chọn 1): Trời mưa · Không đủ người · Bận đột xuất · Sân có vấn đề · Khác (tự gõ, ≤ 100 ký tự).

## Trạng thái và lỗi
| Tình huống | Hiển thị |
|---|---|
| Người chơi vừa tự hủy yêu cầu trước khi chủ kèo bấm | Thẻ tự biến mất (danh sách cập nhật trực tiếp) |
| Hai yêu cầu cùng giành chỗ cuối | Chỉ nhận được người bấm trước, người sau báo "Kèo đã đủ người" |
| Mất mạng | "Không kết nối được, thử lại" |
| Đang xử lý | Nút hiện vòng xoay, khóa bấm lần hai |

## Để sau
- Thông báo cho người chơi khi được nhận / bị từ chối / bị mời ra / kèo bị hủy: làm cùng lát Thông báo (S14). Hiện tại người chơi mở lại Chi tiết kèo là thấy trạng thái mới.
- Hủy muộn trong 3 giờ trước giờ đá bị trừ uy tín (BR08): làm cùng phần uy tín giai đoạn 2.
- Sửa kèo (UC09): làm cùng lát Tạo kèo vì dùng chung form.
- Xác nhận đã nhận tiền, điểm danh: làm cùng S12 và giai đoạn 2.
