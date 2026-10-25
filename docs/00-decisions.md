# Các quyết định đã chốt

> Ghi lại những gì đã thống nhất trước khi viết tài liệu chi tiết. Cập nhật mỗi khi có quyết định mới.

## Sản phẩm

| Hạng mục | Quyết định |
|---|---|
| Tên | **GoGoal**, viết tắt **GG** (Good Game) |
| Trọng tâm MVP | Tạo / tìm kèo |
| Môn thể thao | Bóng đá (sân 5/7/11), cầu lông, bóng rổ, pickleball/tennis |
| Khu vực ban đầu | TP.HCM |
| Tính năng kèo | Trình độ, chia tiền sân, tìm kèo gần (bản đồ), uy tín/đánh giá, thông báo & chat |
| Thanh toán | Chỉ hiển thị số tiền mỗi người + mã VietQR của chủ kèo, chuyển khoản ngoài app |
| Đăng nhập | Giai đoạn 1: **email + mật khẩu, Google, Facebook**. Không làm số điện thoại (OTP) và Zalo |
| Mục tiêu | Đồ án + hướng tới sản phẩm thật |
| Thời gian | 1–2 tháng cho MVP |

## Phân giai đoạn

- **Giai đoạn 1 (tuần 1–5):** đăng nhập, hồ sơ, tạo/tìm kèo, xin vào & duyệt, chia tiền + QR, thông báo đẩy
- **Giai đoạn 2 (tuần 6–8):** bản đồ kèo gần, chat trong kèo, điểm danh, đánh giá & uy tín, báo cáo vi phạm
- **Sau MVP:** lập đội, đặt sân, thông báo đẩy khi app đóng

## Kỹ thuật

- Flutter + Riverpod, Clean Architecture chia theo tính năng (domain / data / presentation)
- Áp dụng OOP: đóng gói (`Match.canJoin`), trừu tượng (`MatchRepository`), kế thừa (`Sport` → `Football`…), đa hình (Strategy theo môn)
- Firebase **gói Spark (miễn phí)**: Auth, Firestore, Emulator Suite. **Không dùng Cloud Functions** (cần gói Blaze)
  - Số chỗ (`slotsFilled`), duyệt người vào: transaction phía app + security rules kiểm tra tính hợp lệ
  - Uy tín: tính từ `ratings` bằng transaction, rules giới hạn mỗi người chấm 1 lần / người / kèo
  - Thông báo: in-app (lắng nghe Firestore) + local notification để nhắc giờ. Push khi app đóng: để sau (có thể dùng Cloudflare Worker miễn phí gọi FCM)
  - Ảnh đại diện: dùng ảnh từ tài khoản Google/Facebook hoặc avatar mặc định; upload ảnh qua dịch vụ ngoài (vd Cloudinary) nếu cần, vì Cloud Storage yêu cầu Blaze
  - Đăng nhập số điện thoại: không làm (SMS OTP yêu cầu liên kết tài khoản thanh toán từ 09/2024, và người dùng không cần)
- Facebook Login: cần tạo app trên Meta for Developers; ở chế độ Development chỉ tài khoản được thêm làm tester đăng nhập được (đủ cho demo đồ án); muốn mở cho mọi người phải chuyển Live, cần URL chính sách quyền riêng tư và hướng dẫn xóa dữ liệu
- Một email chỉ gắn với một tài khoản: nếu đăng nhập Facebook trùng email với tài khoản email/Google có sẵn, app yêu cầu đăng nhập bằng cách cũ rồi liên kết (account linking)
- Docker: trường không bắt buộc; không dùng trong MVP

## Quản trị & duyệt kèo

- **Admin tối giản trong app**: user có `role: admin` thấy thêm màn hình danh sách báo cáo và nút khóa tài khoản
- **Chế độ duyệt kèo**: chủ kèo tự chọn khi tạo kèo — `manual` (mặc định) hoặc `auto`

## Tài liệu báo cáo

- Trường không có mẫu bắt buộc. Tài liệu vẫn phải có: use case (sơ đồ + đặc tả), ERD / thiết kế CSDL, sơ đồ lớp (OOP), sơ đồ tuần tự, sơ đồ trạng thái, kiến trúc

## Thương hiệu

- Màu: xanh lá `#22C55E`, cam `#F97316`, nền tối `#0F172A`
- Logo chữ: hướng theo bản nháp `assets/brand/drafts/v1-wordmark.png` (cần chỉnh: bóng nhỏ lại, chữ màu `#0F172A`)
- Icon: làm lại, tránh kiểu chữ G lồng nhau (giống logo Gucci)

## Câu hỏi còn mở

- [x] Admin có làm trong MVP không? → Admin tối giản trong app
- [x] Chế độ duyệt kèo → chủ kèo tự chọn, mặc định duyệt tay
- [x] Gói Firebase → Spark miễn phí
- [x] Yêu cầu trường → không có, nhưng báo cáo cần đủ UML + CSDL
- [x] Package ID → `vn.gogoal.app`
