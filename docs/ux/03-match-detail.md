# UX – Chi tiết kèo, xin vào, rời kèo (S08)

Trạng thái: đã chốt (05/11/2026). Thiết kế: [Figma](https://www.figma.com/design/VWNTYmdK4H0Br5EjhFqdUJ).

## Chia phần để làm và commit dần
1. Xem chi tiết kèo + nút hành động theo trạng thái.
2. Xin vào (bảng xác nhận + lời nhắn).
3. Hủy yêu cầu / Rời kèo.
4. Danh sách thành viên (chỉ người trong kèo thấy).

## Luồng
- Home: bấm thẻ kèo → Chi tiết kèo. Nút "Xin vào" trên thẻ cũng mở Chi tiết kèo, việc xin vào làm ở đó.
- Home không đổi: ai cũng xem được kèo của cả 5 môn. Chỉ được **xin vào** kèo của môn đã chọn trong hồ sơ.
- Khách bấm "Đăng nhập để tham gia" → Đăng nhập (lần đầu thì Hoàn thành hồ sơ) → quay lại Chi tiết kèo, nút đổi theo trạng thái mới. Không tự gửi yêu cầu.

## Nội dung màn
Từ trên xuống:
- Đầu màn: nút quay lại, icon và màu của môn, tên kèo, thể thức (vd "Sân 5 · 10 người").
- **Thời gian:** thứ, ngày, giờ bắt đầu – giờ kết thúc.
- **Địa điểm:** tên sân, địa chỉ, quận, khoảng cách (nếu có vị trí), nút "Chỉ đường" mở app Google Maps trên máy.
- **Trình độ:** khoảng yêu cầu, vd "Trung bình – Khá".
- **Tiền mỗi người:** vd "17.000đ", hoặc "Miễn phí".
- **Số chỗ:** "Còn 2 chỗ" + thanh tiến độ đã nhận / cần tuyển.
- **Cách nhận người:** "Chủ kèo duyệt" hoặc "Vào ngay".
- **Ghi chú của chủ kèo** (nếu có).
- **Chủ kèo:** avatar, tên, uy tín (chưa có thì "Chưa có đánh giá").
- **Thành viên** (phần 4): người trong kèo (chủ kèo + người đã được nhận) thấy tên và avatar. Người khác chỉ thấy số, vd "4 người đã vào", kèm dòng "Chỉ thành viên trong kèo xem được danh sách".
- **Thanh dưới cùng:** tiền mỗi người + nút hành động.

## Nút hành động theo trạng thái
| Ai / tình huống | Hiển thị |
|---|---|
| Khách | Nút "Đăng nhập để tham gia" |
| Đủ điều kiện | Nút cam "Xin vào" |
| Chưa chọn môn này trong hồ sơ | Nút xám + "Bạn chưa chọn môn này trong hồ sơ" |
| Trình độ không khớp | Nút xám + "Kèo dành cho Trung bình – Khá, bạn đang là Mới chơi" |
| Kèo đã đủ người | Nút xám "Đã đủ người" |
| Kèo đã bắt đầu / đã kết thúc | Nút xám "Kèo đã bắt đầu" |
| Kèo đã hủy | Băng đỏ "Kèo đã bị hủy" trên đầu màn, không có nút |
| Đã gửi yêu cầu, chờ duyệt | "Đang chờ chủ kèo duyệt" + nút viền "Hủy yêu cầu" (phần 3) |
| Đã được nhận | "Bạn đã ở trong kèo" + nút viền "Rời kèo" (phần 3). "Thanh toán", "Chat" hiện "Sắp có" |
| Bị từ chối | "Chủ kèo đã từ chối yêu cầu", không có nút |
| Đã tự rời / bị mời ra | "Bạn đã rời kèo" / "Bạn đã bị mời ra khỏi kèo", không có nút |
| Chủ kèo xem kèo của mình | "Kèo của bạn" + nút "Quản lý kèo" (hiện "Sắp có", làm ở S11) |

Thứ tự kiểm tra khi có nhiều lý do: đã hủy → đã bắt đầu → là chủ kèo → đã có yêu cầu → đã đủ người → chưa chọn môn → sai trình độ.

## Xin vào (phần 2)
Bấm "Xin vào" → bảng trượt lên:
- Tóm tắt: tên kèo, giờ, sân, tiền mỗi người.
- Ô "Lời nhắn cho chủ kèo" (không bắt buộc, ≤ 200 ký tự), vd "Mình đi 2 người".
- Nút "Gửi yêu cầu" (kèo duyệt tay) hoặc "Vào kèo" (kèo vào ngay).

Gửi xong: kèo duyệt tay → "Đang chờ chủ kèo duyệt"; kèo vào ngay → "Bạn đã ở trong kèo", số chỗ giảm 1.

## Hủy yêu cầu / Rời kèo (phần 3)
- "Hủy yêu cầu": hộp xác nhận "Hủy yêu cầu tham gia?" Không / Hủy yêu cầu.
- "Rời kèo": hộp xác nhận "Rời khỏi kèo này?" Ở lại / Rời kèo. Số chỗ tăng lại 1.

## Trạng thái và lỗi
| Tình huống | Hiển thị |
|---|---|
| Đang tải | Khung xám (skeleton) |
| Mất mạng | Màn "Không kết nối được" + nút "Thử lại" |
| Kèo không tồn tại / bị ẩn | "Kèo này không còn" + nút "Về trang chủ" |
| Kèo vừa đủ người lúc gửi | "Kèo vừa đủ người", tải lại chi tiết |
| Đang gửi | Nút hiện vòng xoay, khóa bấm lần hai |

## Để sau
- Cảnh báo trùng giờ (BR05): làm cùng "Kèo của tôi" (S13).
- Rời muộn trong 3 giờ trước giờ đá bị trừ uy tín (BR07): làm cùng phần uy tín giai đoạn 2. Hiện tại rời lúc nào cũng như nhau.
- Uy tín tối thiểu của kèo (BR03): làm cùng phần uy tín giai đoạn 2. Hiện tại bỏ qua.
- Xin lại sau khi tự rời hoặc bị từ chối: chưa chốt. Hiện tại không xin lại được.
- Bản đồ thu nhỏ trong màn: hiện chỉ có nút "Chỉ đường".
