# 7. Kế hoạch & danh sách task

## 7.1. Lộ trình 8 tuần

| Tuần | Chủ đề | Task | Kết quả cuối tuần |
|---|---|---|---|
| 0 | Thiết kế | T00 | Bản Figma các màn hình giai đoạn 1 |
| 1 | Nền móng | T01–T04 | App chạy được, có theme, điều hướng, kết nối emulator |
| 2 | Đăng nhập & hồ sơ | T05–T08 | Đăng nhập email/Google/Facebook, hoàn thành hồ sơ |
| 3 | Tạo & tìm kèo | T09–T11 | Tạo kèo, xem danh sách, lọc |
| 4 | Tham gia kèo | T12–T14 | Xin vào, duyệt, rời, sửa/hủy kèo |
| 5 | Hoàn thiện giai đoạn 1 | T15–T18 | Thông báo, thanh toán QR, kèo của tôi. **Demo giai đoạn 1, cho bạn bè dùng thử** |
| 6 | Bản đồ & chat | T19–T20 | Kèo gần tôi, chat nhóm |
| 7 | Uy tín | T21–T22 | Điểm danh, đánh giá GG, hồ sơ công khai, báo cáo |
| 8 | Hoàn thiện | T23–T25 | Admin, icon, CI, bản APK, báo cáo đồ án |

**Nguyên tắc làm việc**
- Mỗi task làm trên một nhánh Git riêng (`feat/t05-auth`), xong thì merge vào `main`.
- Một task chỉ "xong" khi đạt mọi tiêu chí *Hoàn thành khi*, `flutter analyze` sạch và test chạy qua.
- Cập nhật [00-decisions.md](00-decisions.md) khi có quyết định mới phát sinh.
- Nếu trễ tiến độ, cắt theo thứ tự: T23 (admin) → T19 (bản đồ) → T20 (chat). Không cắt T13 (tham gia kèo), vì đó là lõi của app.

---

## Tuần 0 – Thiết kế

### T00 · Thiết kế Figma các màn hình giai đoạn 1 *(bạn tự làm)*
- **Đầu vào:** [06-man-hinh-figma.md](06-man-hinh-figma.md)
- **Hoàn thành khi:** có các màn S01–S16 ở chế độ sáng; có component `MatchCard`, `SportChip`, `LevelBadge`, `BottomNav`; logo và icon đã chốt.

## Tuần 1 – Nền móng

### T01 · Khởi tạo dự án Flutter
- **Hoàn thành khi:** chạy `flutter create --org vn.gogoal --project-name gogoal app`; có cấu trúc thư mục như mục 5.3; đã thêm các package ở mục 5.9; bật `flutter_lints` chặt; app chạy được trên Android emulator.

### T02 · Firebase & Emulator
- **Hoàn thành khi:** có project Firebase `gogoal-prod`; chạy `flutterfire configure` sinh `firebase_options.dart`; `firebase/firebase.json` cấu hình emulator Auth (9099) + Firestore (8080) + UI; app chạy với `--dart-define=ENV=dev` kết nối được emulator.

### T03 · Theme, router, khung giao diện
- **Hoàn thành khi:** có `AppTheme` sáng/tối dùng token mục 6.1, font Be Vietnam Pro; `go_router` có các route chính (trang giữ chỗ); bottom navigation 5 mục; widget dùng chung: `PrimaryButton`, `AppAvatar`, `EmptyState`, `SportChip`.

### T04 · Lớp nền tảng của domain
- **Hoàn thành khi:** có `Result<T>`, `Failure` (sealed), `Clock` + `SystemClock` + `FixedClock` (dùng khi test), value object `Money` (BR02: làm tròn lên 1.000đ), `TimeRange` (`overlaps`), `GeoLocation`; test đầy đủ.

## Tuần 2 – Đăng nhập & hồ sơ

### T05 · Đăng nhập (UC01)
- **Hoàn thành khi:** đăng nhập Google, Facebook, đăng ký/đăng nhập email, quên mật khẩu, đăng xuất; xử lý trùng email bằng liên kết tài khoản (UC01-E4); router chuyển hướng: chưa đăng nhập → S03, chưa đủ hồ sơ → S05; lỗi Firebase được chuyển thành thông báo tiếng Việt.

### T06 · Domain thể thao
- **Hoàn thành khi:** `Sport` (sealed) + 5 lớp con, `MatchFormat`, `SkillLevel` (so sánh được, có nhãn tiếng Việt); `Sport.fromId`; test.

### T07 · Hồ sơ người chơi (UC02)
- **Hoàn thành khi:** `Player`, `Reputation` (công thức BR11, có test), `BankAccount`; `UserRepository` đọc/ghi `users/{uid}` và `users/{uid}/private/profile`; màn S05 (3 bước), S15, S16; tạo document user khi đăng nhập lần đầu.

### T08 · Security Rules cho users + test rules
- **Hoàn thành khi:** rules cho `users`, `private/profile`, `notifications`; người khác chỉ được sửa `stats`/`tagCounts` theo luật; không ai tự sửa `role`/`banned`; có test bằng `@firebase/rules-unit-testing` chạy trên emulator.

## Tuần 3 – Tạo & tìm kèo

### T09 · Entity Match & điều kiện tham gia
- **Hoàn thành khi:** `Match`, `Venue`, `MatchStatus`, `DisplayStatus`, `ApprovalMode`, `JoinEligibility` (sealed); `displayStatus(clock)`, `checkEligibility`, `costPerPerson`, `isLateCancel`; test phủ mọi nhánh BR01, BR03, BR06, BR08.

### T10 · Tạo kèo (UC05)
- **Hoàn thành khi:** `MatchRepository` + `FirestoreMatchRepository.create` (batch: match + private/payment); use case `CreateMatch` kiểm tra BR01; màn S09 (3 bước) và S10 (giai đoạn 1: chọn từ danh sách sân + nhập địa chỉ tay; bản đồ ghim là phần thêm); rules tạo kèo + test; seed khoảng 20 sân vào emulator.

### T11 · Khám phá & lọc (UC03)
- **Hoàn thành khi:** màn S06 + S07; truy vấn và phân trang theo mục 4.4; `firestore.indexes.json` có đủ chỉ mục; trạng thái trống, đang tải, lỗi, ngoại tuyến.

## Tuần 4 – Tham gia kèo

### T12 · Chi tiết kèo (UC04)
- **Hoàn thành khi:** màn S08 với 3 biến thể nút theo vai trò; danh sách thành viên realtime; chia sẻ link kèo.

### T13 · Xin vào / duyệt / rời (UC06, UC07, UC08)
- **Hoàn thành khi:** `ParticipantRepository` với transaction theo mục 4.5; use case `RequestJoinMatch`, `ApproveParticipant`, `RejectParticipant`, `RemoveParticipant`, `LeaveMatch`; cảnh báo trùng giờ (BR05); rules + rules test, gồm trường hợp hai người tranh chỗ cuối.

### T14 · Quản lý, sửa, hủy kèo (UC07, UC09)
- **Hoàn thành khi:** màn S11 (tab chờ duyệt / thành viên); sửa kèo theo BR12; hủy kèo kèm lý do, cảnh báo hủy muộn (BR08).

## Tuần 5 – Hoàn thiện giai đoạn 1

### T15 · Thông báo (UC11)
- **Hoàn thành khi:** các thao tác ở T13/T14 tạo notification cho người nhận; màn S14; số chưa đọc trên tab; banner khi app đang mở; local notification nhắc trước giờ đá 2 giờ, hủy lịch khi rời kèo hoặc kèo bị hủy.

### T16 · Thanh toán VietQR (UC10)
- **Hoàn thành khi:** `VietQrService` sinh URL ảnh QR (`img.vietqr.io`) có số tiền và nội dung `GG <mã> <tên>`; màn S12; người chơi đánh dấu "đã chuyển"; chủ kèo xác nhận trong S11.

### T17 · Kèo của tôi
- **Hoàn thành khi:** màn S13 với truy vấn collection group `participants` và `matches` theo `hostId`; chia "Sắp tới / Đã qua".

### T18 · Ổn định & thử nghiệm giai đoạn 1
- **Hoàn thành khi:** sửa lỗi tồn đọng; triển khai rules + indexes lên `gogoal-prod`; build APK; 5–10 người bạn dùng thử và ghi lại góp ý vào `docs/feedback.md`.

## Tuần 6 – Bản đồ & chat

### T19 · Kèo gần tôi (UC12)
- **Hoàn thành khi:** màn S17; xin quyền vị trí; truy vấn `subscribeWithin` theo bán kính; marker theo màu môn; xử lý khi bị từ chối quyền.

### T20 · Chat trong kèo (UC13)
- **Hoàn thành khi:** màn S18; 50 tin gần nhất + tải thêm; rules chỉ cho thành viên đọc/ghi; khóa gửi sau 24 giờ kể từ giờ kết thúc.

## Tuần 7 – Uy tín

### T21 · Điểm danh & đánh giá (UC14, UC15, UC16)
- **Hoàn thành khi:** màn S19, S20; batch ghi theo mục 4.5; rules kiểm tra thời hạn (BR09, BR10) và chống chấm trùng; uy tín hiển thị đúng công thức BR11.

### T22 · Hồ sơ công khai & báo cáo (UC16, UC17)
- **Hoàn thành khi:** màn S21, S22; rules BR14 (id báo cáo xác định để chống trùng).

## Tuần 8 – Hoàn thiện

### T23 · Quản trị (UC18)
- **Hoàn thành khi:** mục "Quản trị" chỉ hiện với admin; màn S23; khóa/mở khóa tài khoản, ẩn kèo; rules chỉ admin được ghi `banned`, `role`, `status = hidden`.

### T24 · Icon, splash, hoàn thiện giao diện
- **Hoàn thành khi:** `flutter_launcher_icons` + `flutter_native_splash` với logo đã chốt; kiểm tra chế độ tối; rà lại chữ tiếng Việt và các trạng thái trống/lỗi.

### T25 · CI, phát hành, báo cáo
- **Hoàn thành khi:** GitHub Actions chạy `analyze` + `test` + rules test ở mỗi push; build APK release đã ký; xuất các sơ đồ trong `docs/` ra ảnh; hoàn thiện báo cáo đồ án.
