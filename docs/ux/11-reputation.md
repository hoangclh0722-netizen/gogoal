# Hệ thống uy tín: điểm danh, đánh giá, hồ sơ công khai (UC14–UC16)

Thay cho thu tiền trước, uy tín là cách chính để hạn chế bùng kèo. Không có server nên mọi thống kê được ghi cùng một batch với hành động gây ra nó, rules kiểm tra bằng `getAfter()`.

## Phần 1 – Điểm danh (UC14, BR09)

- Mở được khi kèo đã kết thúc và chưa quá 24 giờ, kèo chưa hủy, chưa điểm danh.
- Lúc kết thúc, máy chủ kèo nhắc "Điểm danh trận vừa rồi" (nhắc giờ trên máy).
- Quản lý kèo hiện thanh "Trận đã xong · Điểm danh"; bấm mở danh sách thành viên đã được nhận, mặc định **Có mặt**, bấm để đổi sang **Vắng**. Nút "Xác nhận điểm danh" (hộp xác nhận vì không sửa lại được).
- Ghi cùng lúc: `participants/*.attended`, `users/*.stats.matchesPlayed` hoặc `noShows` + 1 (kể cả chủ kèo: +1 trận), `matches/{id}.attendanceTakenAt`.
- Quá 24 giờ chưa điểm danh: không ai bị tính vắng (theo BR09 coi như có mặt), nhưng cũng không ai được cộng trận.

## Phần 2 – Đánh giá (UC15, BR10)

- Mở trong 48 giờ sau giờ kết thúc, sau khi đã điểm danh, cho người **có mặt** và chủ kèo.
- Chi tiết kèo hiện nút "GG! Đánh giá đồng đội". Màn đánh giá liệt kê những người có mặt khác (cả chủ kèo), ai đã chấm rồi thì ẩn.
- Mỗi người: 1–5 sao (bắt buộc) + thẻ tùy chọn: Đúng giờ, Fair-play, Vui vẻ, Chơi hay. Có thể bỏ qua người nào đó.
- Ghi cùng lúc: `ratings/{matchId}_{from}_{to}` + `users/{to}.stats.ratingSum` + sao, `ratingCount` + 1. Mỗi người chấm mỗi người tối đa 1 lần mỗi kèo (id cố định).

## Phần 3 – Uy tín và hồ sơ công khai (UC16, BR11)

- Điểm uy tín theo công thức BR11 (đã có). Thêm **độ tin cậy** = trận đã chơi ÷ (trận đã chơi + lần vắng), chỉ hiện khi đã có ít nhất 1 trận.
- Bấm vào chủ kèo hoặc thành viên ở Chi tiết kèo / Quản lý kèo → hồ sơ công khai: tên, quận, uy tín, độ tin cậy, số trận, số lần vắng, thẻ được nhận nhiều nhất, môn và trình độ, "Đã tổ chức N kèo · hủy M".

## Để sau

- Khiếu nại khi bị đánh dấu vắng (24 giờ).
- Phạt rời muộn / hủy muộn (BR07, BR08) và tạm khóa xin vào khi vắng nhiều lần.
