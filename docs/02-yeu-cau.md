# 2. Yêu cầu hệ thống

## 2.1. Yêu cầu chức năng

| Mã | Yêu cầu | Use case | Giai đoạn |
|---|---|---|---|
| FR01 | Đăng nhập bằng Google hoặc email + mật khẩu; đăng ký, quên mật khẩu, đăng xuất | UC01 | 1 |
| FR02 | Lần đầu đăng nhập phải hoàn thành hồ sơ: tên hiển thị, khu vực, ít nhất 1 môn kèm trình độ | UC02 | 1 |
| FR03 | Người chơi lưu thông tin ngân hàng (mã ngân hàng, số tài khoản, tên chủ tài khoản) để nhận tiền | UC02 | 1 |
| FR04 | Xem danh sách kèo sắp diễn ra, lọc theo môn, quận, ngày, trình độ, còn chỗ | UC03 | 1 |
| FR05 | Xem chi tiết kèo: thông tin, chủ kèo + uy tín, danh sách người đã vào, tiền mỗi người | UC04 | 1 |
| FR06 | Tạo kèo với các trường ở mục 2.2 | UC05 | 1 |
| FR07 | Xin vào kèo; kèo `auto` được nhận ngay, kèo `manual` chờ duyệt | UC06 | 1 |
| FR08 | Chủ kèo duyệt / từ chối yêu cầu, xóa người khỏi kèo | UC07 | 1 |
| FR09 | Người chơi rời kèo hoặc hủy yêu cầu đang chờ | UC08 | 1 |
| FR10 | Chủ kèo sửa thông tin hoặc hủy kèo | UC09 | 1 |
| FR11 | Hiển thị số tiền mỗi người và mã VietQR của chủ kèo; người chơi tự đánh dấu "đã chuyển" | UC10 | 1 |
| FR12 | Thông báo trong app khi có người xin vào, được duyệt, bị từ chối, kèo bị sửa/hủy | UC11 | 1 |
| FR13 | Nhắc giờ bằng local notification trước giờ bắt đầu 2 giờ | UC11 | 1 |
| FR14 | "Kèo của tôi": các kèo đã tạo và đã tham gia, chia sắp tới / đã qua | UC03 | 1 |
| FR15 | Bản đồ kèo trong bán kính 1–20 km quanh vị trí hiện tại | UC12 | 2 |
| FR16 | Chat nhóm giữa các thành viên đã được duyệt của kèo | UC13 | 2 |
| FR17 | Chủ kèo điểm danh (có mặt / vắng) sau khi kèo kết thúc | UC14 | 2 |
| FR18 | Thành viên có mặt đánh giá nhau 1–5 sao + thẻ (đúng giờ, fair-play, vui vẻ…) | UC15 | 2 |
| FR19 | Hiển thị điểm uy tín, số trận đã chơi, số lần vắng trên hồ sơ | UC16 | 2 |
| FR20 | Báo cáo người chơi hoặc kèo vi phạm | UC17 | 2 |
| FR21 | Admin xem danh sách báo cáo, khóa / mở khóa tài khoản, ẩn kèo | UC18 | 2 |

## 2.2. Thông tin của một kèo

| Trường | Bắt buộc | Ghi chú |
|---|---|---|
| Môn | ✔ | Bóng đá, cầu lông, bóng rổ, pickleball, tennis |
| Thể thức | ✔ | Phụ thuộc môn, vd bóng đá: 5v5 / 7v7 / 11v11; cầu lông: đơn / đôi |
| Tổng số người chơi | ✔ | Gợi ý theo thể thức, chủ kèo chỉnh được |
| Số chỗ cần tuyển | ✔ | Số người cần tìm qua app (1 → tổng số người − 1) |
| Thời gian bắt đầu / kết thúc | ✔ | |
| Địa điểm | ✔ | Tên sân, địa chỉ, tọa độ (chọn trên bản đồ hoặc từ danh sách sân), quận |
| Trình độ | ✔ | Khoảng từ – đến: Mới chơi / Trung bình / Khá / Giỏi |
| Tổng tiền sân | | 0 = miễn phí |
| Chế độ duyệt | ✔ | Duyệt tay (mặc định) / Tự động |
| Uy tín tối thiểu | | Không bắt buộc, vd ≥ 3.5 |
| Ghi chú | | Tối đa 500 ký tự (màu áo, gửi xe…) |

## 2.3. Quy tắc nghiệp vụ

| Mã | Quy tắc |
|---|---|
| BR01 | Thời gian bắt đầu phải sau hiện tại ít nhất 30 phút và không quá 30 ngày; thời lượng 30 phút – 4 giờ |
| BR02 | **Tiền mỗi người** = làm tròn lên đến 1.000đ của (tổng tiền sân ÷ tổng số người chơi) |
| BR03 | Chỉ xin vào được khi kèo còn chỗ, chưa bắt đầu, chưa bị hủy, trình độ người chơi ở môn đó nằm trong khoảng yêu cầu và uy tín ≥ mức tối thiểu |
| BR04 | Một người không thể xin vào kèo của chính mình, và không có 2 yêu cầu cùng lúc cho một kèo |
| BR05 | Khi xin vào kèo trùng giờ với một kèo đã được duyệt khác, app hiển thị cảnh báo (không chặn) |
| BR06 | Kèo **đủ người** khi số chỗ đã nhận = số chỗ cần tuyển; khi đó không nhận thêm yêu cầu |
| BR07 | Rời kèo trong vòng 3 giờ trước giờ bắt đầu được tính là **rời muộn** |
| BR08 | Chủ kèo hủy kèo đã có người trong vòng 3 giờ trước giờ bắt đầu được tính là **hủy muộn** |
| BR09 | Chủ kèo điểm danh trong vòng 24 giờ sau giờ kết thúc; người không được điểm danh mặc định là có mặt |
| BR10 | Đánh giá mở trong 48 giờ sau giờ kết thúc; chỉ người có mặt mới được đánh giá; mỗi người chấm mỗi người khác tối đa 1 lần trong một kèo |
| BR11 | **Điểm uy tín** (thang 1–5) = trung bình sao có làm mượt − phạt (công thức ở mục 2.4) |
| BR12 | Sửa kèo: không được giảm số chỗ xuống thấp hơn số người đã nhận; đổi giờ hoặc địa điểm phải thông báo cho mọi thành viên |
| BR13 | Tài khoản bị khóa không tạo kèo, xin vào kèo, chat hay đánh giá được |
| BR14 | Mỗi người chỉ báo cáo một đối tượng một lần trong cùng một kèo |

## 2.4. Công thức điểm uy tín

Dùng trung bình Bayes để người mới không bị lệch điểm vì 1–2 đánh giá:

```
              tổng_sao + C × m
điểm_gốc = ─────────────────────        C = 5 (số đánh giá "ảo"), m = 4.0 (điểm khởi đầu)
             số_đánh_giá + C

uy_tín = clamp(điểm_gốc − 0.3 × số_lần_vắng − 0.1 × số_lần_rời_muộn − 0.2 × số_lần_hủy_muộn, 1, 5)
```

Người mới có uy tín 4.0. Ví dụ: 10 đánh giá, tổng 46 sao, vắng 1 lần → (46 + 20) / 15 − 0.3 = **4.1**.

Uy tín được tính ở client từ các trường thống kê lưu trong tài liệu người dùng, xem [04-co-so-du-lieu.md](04-co-so-du-lieu.md).

## 2.5. Yêu cầu phi chức năng

| Mã | Nhóm | Yêu cầu |
|---|---|---|
| NFR01 | Nền tảng | Android 8.0+ (API 26), iOS 15+ |
| NFR02 | Hiệu năng | Màn hình danh sách kèo tải trong ≤ 2 giây với 4G; phân trang 20 kèo / lần |
| NFR03 | Chi phí | Nằm trong hạn mức gói Spark: dùng cache offline của Firestore, phân trang, không lắng nghe realtime những màn hình không cần |
| NFR04 | Bảo mật | Mọi quy tắc nghiệp vụ quan trọng (BR03, BR06, BR10, BR13, BR14) được kiểm tra lại trong Firestore Security Rules, không chỉ ở client |
| NFR05 | Quyền riêng tư | Số tài khoản ngân hàng chỉ hiển thị cho thành viên đã được duyệt của kèo; email không hiển thị công khai |
| NFR06 | Khả dụng | Giao diện tiếng Việt, hỗ trợ chế độ sáng / tối, cỡ chữ hệ thống |
| NFR07 | Ngoại tuyến | Xem lại kèo của tôi khi mất mạng (cache Firestore) |
| NFR08 | Bảo trì | Clean Architecture, phủ unit test ≥ 70% cho tầng domain, `flutter analyze` không lỗi |
| NFR09 | Mở rộng | Thêm môn mới chỉ cần thêm một lớp con của `Sport`, không sửa code ở nơi khác |
