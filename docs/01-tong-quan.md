# 1. Tổng quan dự án GoGoal

## 1.1. Bối cảnh và vấn đề

Người chơi thể thao phong trào ở TP.HCM (bóng đá sân 5/7, cầu lông, bóng rổ, pickleball…) thường xuyên gặp các tình huống:

- **Thiếu người phút chót**: đã thuê sân nhưng thiếu 1–3 người, phải đăng bài lên nhiều nhóm Facebook/Zalo và chờ phản hồi.
- **Muốn chơi nhưng không có nhóm**: người mới chuyển đến, đi làm xa nhà, không biết kèo nào phù hợp trình độ.
- **Bùng kèo**: người nhận lời rồi không đến, không có cơ chế đánh giá hay ràng buộc.
- **Chia tiền sân lộn xộn**: phải tính tay, nhắn số tài khoản từng người.

Các nhóm Facebook/Zalo hiện nay không có bộ lọc theo môn, giờ, khu vực, trình độ; thông tin trôi nhanh và không có lịch sử uy tín.

## 1.2. Giải pháp

**GoGoal** (viết tắt **GG** – *Good Game*) là ứng dụng di động giúp người chơi:

1. **Tạo kèo** trong vài chạm: môn, thể thức, thời gian, địa điểm, số chỗ cần tuyển, trình độ, tiền sân.
2. **Tìm kèo** theo môn, khu vực, thời gian, trình độ, hoặc trên bản đồ quanh vị trí hiện tại.
3. **Xin vào / duyệt** người chơi, có chế độ tự động duyệt.
4. **Chia tiền minh bạch**: app tính số tiền mỗi người và hiển thị mã VietQR của chủ kèo.
5. **Xây dựng uy tín**: điểm danh, đánh giá "GG" sau trận, giảm tình trạng bùng kèo.

**Slogan đề xuất:** *"Lên kèo, GoGoal!"*

## 1.3. Đối tượng người dùng

| Persona | Mô tả | Nhu cầu chính |
|---|---|---|
| **Minh – chủ kèo** (24 tuổi, nhân viên văn phòng) | Tuần nào cũng thuê sân 5 đá tối thứ 4, thường thiếu 2–3 người | Đăng kèo nhanh, lọc được người đúng trình độ, thu tiền dễ |
| **Lan – người chơi lẻ** (21 tuổi, sinh viên) | Mới học cầu lông, ngại vào nhóm toàn người giỏi | Tìm kèo trình độ thấp, gần trường, giá rẻ |
| **Tuấn – người mới đến thành phố** (27 tuổi) | Chơi bóng rổ, chưa quen ai | Tìm kèo gần nhà, xem uy tín người tổ chức |
| **Quản trị viên** | Người vận hành app | Xử lý báo cáo vi phạm, khóa tài khoản xấu |

## 1.4. Mục tiêu

**Mục tiêu đồ án**
- Ứng dụng Flutter chạy được trên Android (và iOS nếu có thiết bị), demo đầy đủ luồng tạo kèo → xin vào → duyệt → điểm danh → đánh giá.
- Tài liệu đầy đủ: use case, thiết kế CSDL, kiến trúc, sơ đồ lớp OOP, sơ đồ tuần tự, sơ đồ trạng thái.
- Code tổ chức theo OOP và Clean Architecture, có unit test cho tầng domain.

**Mục tiêu sản phẩm (sau đồ án)**
- 100 người dùng thật ở 1–2 quận trong tháng đầu thử nghiệm.
- Tỉ lệ kèo đủ người ≥ 60%; tỉ lệ bùng kèo < 10%.

## 1.5. Phạm vi

### Trong phạm vi MVP

| Giai đoạn | Tính năng |
|---|---|
| **Giai đoạn 1** (tuần 1–5) | Đăng nhập Google / email · Hồ sơ người chơi (môn, trình độ, tài khoản ngân hàng) · Tạo / sửa / hủy kèo · Danh sách & lọc kèo · Chi tiết kèo · Xin vào / rời kèo · Duyệt tay hoặc tự động · Chia tiền + VietQR · Thông báo trong app · Nhắc giờ bằng local notification |
| **Giai đoạn 2** (tuần 6–8) | Bản đồ kèo gần tôi · Chat trong kèo · Điểm danh · Đánh giá "GG" & điểm uy tín · Báo cáo vi phạm · Admin tối giản trong app |

### Ngoài phạm vi MVP

- Đăng nhập số điện thoại (OTP), Facebook, Zalo
- Thông báo đẩy khi app đã đóng (cần server)
- Thanh toán trong app (MoMo, VNPay), giữ tiền đặt cọc
- Đặt sân trực tiếp với chủ sân, lập đội cố định, giải đấu
- Upload ảnh đại diện tùy chỉnh
- Phiên bản web

## 1.6. Ràng buộc

| Ràng buộc | Ảnh hưởng |
|---|---|
| Một người phát triển, mới bắt đầu, 1–2 tháng | Ưu tiên dịch vụ có sẵn (Firebase), phạm vi gọn, chia giai đoạn rõ |
| Firebase gói **Spark** (miễn phí) | Không có Cloud Functions, Cloud Storage, SMS OTP. Logic nghiệp vụ chạy ở client, được bảo vệ bằng Security Rules. Hạn mức Firestore: 50.000 lượt đọc, 20.000 lượt ghi mỗi ngày |
| Khu vực: TP.HCM | Dữ liệu quận/huyện, tọa độ mặc định theo TP.HCM |

## 1.7. Công nghệ tóm tắt

| Thành phần | Công nghệ |
|---|---|
| Ứng dụng | Flutter 3.x, Dart 3 |
| Quản lý state / DI | Riverpod |
| Điều hướng | go_router |
| Backend | Firebase Authentication, Cloud Firestore (gói Spark) |
| Bản đồ & vị trí | google_maps_flutter, geolocator, geoflutterfire_plus (geohash) |
| Thông báo | Thông báo trong app (Firestore) + flutter_local_notifications |
| Mã QR chuyển khoản | Chuẩn VietQR (sinh ảnh qua img.vietqr.io) |
| Phát triển & kiểm thử | Firebase Emulator Suite, flutter_test, mocktail |
| CI | GitHub Actions (analyze + test) |

Chi tiết xem [05-kien-truc.md](05-kien-truc.md).
