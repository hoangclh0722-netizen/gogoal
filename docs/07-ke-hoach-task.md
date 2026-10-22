# 7. Kế hoạch & danh sách task

## 7.1. Lộ trình 8 tuần

| Tuần | Chủ đề | Task | Kết quả cuối tuần |
|---|---|---|---|
| 0 | Thiết kế | T00 | Bản Figma các màn hình giai đoạn 1 |
| 1 | Nền móng | T01–T04 | App chạy được, có theme, điều hướng, kết nối emulator |
| 2 | Đăng nhập & hồ sơ | T05–T08 | Đăng nhập Google/email, hoàn thành hồ sơ |
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

## 7.2. Mẫu prompt giao task cho Claude

```
Làm task <MÃ TASK> trong docs/07-ke-hoach-task.md.
Trước khi code, đọc: docs/00-decisions.md, docs/05-kien-truc.md và các mục liên quan
trong docs/04-co-so-du-lieu.md, docs/03-use-case.md.
Yêu cầu:
- Tạo nhánh feat/<mã-task>-<tên-ngắn>.
- Theo đúng cấu trúc thư mục và tầng (domain/data/presentation) trong 05-kien-truc.md.
- Viết unit test cho tầng domain; chạy flutter analyze và flutter test.
- Giải thích ngắn những gì bạn làm để tôi học được, đặc biệt các điểm OOP.
- Không commit; tóm tắt thay đổi để tôi xem trước.
```

Mỗi task bên dưới có một **prompt riêng** bổ sung chi tiết. Hãy dán prompt mẫu ở trên, kèm prompt của task.

---

## Tuần 0 – Thiết kế

### T00 · Thiết kế Figma các màn hình giai đoạn 1 *(bạn tự làm)*
- **Đầu vào:** [06-man-hinh-figma.md](06-man-hinh-figma.md)
- **Hoàn thành khi:** có các màn S01–S16 ở chế độ sáng; có component `MatchCard`, `SportChip`, `LevelBadge`, `BottomNav`; logo và icon đã chốt.

## Tuần 1 – Nền móng

### T01 · Khởi tạo dự án Flutter
- **Hoàn thành khi:** chạy `flutter create --org vn.gogoal --project-name gogoal app`; có cấu trúc thư mục như mục 5.3; đã thêm các package ở mục 5.9; bật `flutter_lints` chặt; app chạy được trên Android emulator.
```
Prompt T01: Khởi tạo app Flutter trong thư mục app/ với org vn.gogoal, project name gogoal,
chỉ Android + iOS. Tạo khung thư mục lib/core và lib/features theo 05-kien-truc.md (file trống
có chú thích mục đích). Thêm các package ở mục 5.9 bằng flutter pub add.
Cấu hình analysis_options.yaml chặt. Hướng dẫn tôi chạy app trên emulator.
```

### T02 · Firebase & Emulator
- **Hoàn thành khi:** có project Firebase `gogoal-prod`; chạy `flutterfire configure` sinh `firebase_options.dart`; `firebase/firebase.json` cấu hình emulator Auth (9099) + Firestore (8080) + UI; app chạy với `--dart-define=ENV=dev` kết nối được emulator.
```
Prompt T02: Hướng dẫn tôi từng bước tạo project Firebase (gói Spark), bật Authentication
(Google, Email/Password) và Firestore (vùng asia-southeast1). Sau đó cấu hình FlutterFire,
thư mục firebase/ với firebase.json, firestore.rules (tạm khoá hết), firestore.indexes.json,
và code trong main.dart để chọn emulator khi ENV=dev. Viết script chạy emulator.
```

### T03 · Theme, router, khung giao diện
- **Hoàn thành khi:** có `AppTheme` sáng/tối dùng token mục 6.1, font Be Vietnam Pro; `go_router` có các route chính (trang giữ chỗ); bottom navigation 5 mục; widget dùng chung: `PrimaryButton`, `AppAvatar`, `EmptyState`, `SportChip`.
```
Prompt T03: Tạo theme theo design tokens trong docs/06-man-hinh-figma.md mục 6.1, router
go_router với ShellRoute cho bottom navigation 5 mục (màn hình tạm), và các widget dùng chung.
Giải thích cách ThemeExtension lưu màu theo môn.
```

### T04 · Lớp nền tảng của domain
- **Hoàn thành khi:** có `Result<T>`, `Failure` (sealed), `Clock` + `SystemClock` + `FixedClock` (dùng khi test), value object `Money` (BR02: làm tròn lên 1.000đ), `TimeRange` (`overlaps`), `GeoLocation`; test đầy đủ.
```
Prompt T04: Viết các lớp trong lib/core: Result<T> (sealed: Success/Error), Failure (sealed),
Clock, Money (splitBy làm tròn lên 1.000đ theo BR02, format "60.000đ"), TimeRange (overlaps),
GeoLocation. Viết unit test cho từng lớp. Giải thích vì sao dùng value object và sealed class.
```

## Tuần 2 – Đăng nhập & hồ sơ

### T05 · Đăng nhập (UC01)
- **Hoàn thành khi:** đăng nhập Google, đăng ký/đăng nhập email, quên mật khẩu, đăng xuất; router chuyển hướng: chưa đăng nhập → S03, chưa đủ hồ sơ → S05; lỗi Firebase được chuyển thành thông báo tiếng Việt.
```
Prompt T05: Làm feature auth theo UC01: AuthRepository (abstract) + FirebaseAuthRepository,
AppUser entity, AuthController (Riverpod), màn hình S03/S04 theo prompt Figma.
Router guard theo trạng thái đăng nhập và profileCompleted. Test controller bằng fake repository.
```

### T06 · Domain thể thao
- **Hoàn thành khi:** `Sport` (sealed) + 5 lớp con, `MatchFormat`, `SkillLevel` (so sánh được, có nhãn tiếng Việt); `Sport.fromId`; test.
```
Prompt T06: Làm features/sport/domain theo mục 5.5–5.6: Sport sealed với Football, Badminton,
Basketball, Pickleball, Tennis; MatchFormat; SkillLevel enum có compareTo và label.
Viết test, và giải thích kế thừa + đa hình qua ví dụ này để tôi đưa vào báo cáo.
```

### T07 · Hồ sơ người chơi (UC02)
- **Hoàn thành khi:** `Player`, `Reputation` (công thức BR11, có test), `BankAccount`; `UserRepository` đọc/ghi `users/{uid}` và `users/{uid}/private/profile`; màn S05 (3 bước), S15, S16; tạo document user khi đăng nhập lần đầu.
```
Prompt T07: Làm feature profile theo UC02 và 04-co-so-du-lieu.md (users, private/profile).
Gồm entity Player, Reputation (BR11, test nhiều trường hợp), BankAccount với danh sách ngân hàng
VietQR phổ biến; UserModel ↔ Player mapper; màn S05, S15, S16.
```

### T08 · Security Rules cho users + test rules
- **Hoàn thành khi:** rules cho `users`, `private/profile`, `notifications`; người khác chỉ được sửa `stats`/`tagCounts` theo luật; không ai tự sửa `role`/`banned`; có test bằng `@firebase/rules-unit-testing` chạy trên emulator.
```
Prompt T08: Viết firestore.rules cho users/** theo 04-co-so-du-lieu.md mục 4.6, và thư mục
firebase/rules-test (Node + Jest/Vitest + @firebase/rules-unit-testing) với các test
cho phép/từ chối. Giải thích từng rule.
```

## Tuần 3 – Tạo & tìm kèo

### T09 · Entity Match & điều kiện tham gia
- **Hoàn thành khi:** `Match`, `Venue`, `MatchStatus`, `DisplayStatus`, `ApprovalMode`, `JoinEligibility` (sealed); `displayStatus(clock)`, `checkEligibility`, `costPerPerson`, `isLateCancel`; test phủ mọi nhánh BR01, BR03, BR06, BR08.
```
Prompt T09: Làm features/match/domain/entities theo mục 5.5–5.6 và các quy tắc BR01–BR08.
Dùng FixedClock trong test để kiểm tra các trạng thái thời gian. Test phủ mọi nhánh của checkEligibility.
```

### T10 · Tạo kèo (UC05)
- **Hoàn thành khi:** `MatchRepository` + `FirestoreMatchRepository.create` (batch: match + private/payment); use case `CreateMatch` kiểm tra BR01; màn S09 (3 bước) và S10 (giai đoạn 1: chọn từ danh sách sân + nhập địa chỉ tay; bản đồ ghim là phần thêm); rules tạo kèo + test; seed khoảng 20 sân vào emulator.
```
Prompt T10: Làm UC05: MatchModel (fromFirestore/toFirestore, tính levels[], geo bằng geoflutterfire_plus),
FirestoreMatchRepository.create, use case CreateMatch, màn S09/S10. Viết rules + rules test cho tạo kèo.
Tạo script seed venues TP.HCM cho emulator.
```

### T11 · Khám phá & lọc (UC03)
- **Hoàn thành khi:** màn S06 + S07; truy vấn và phân trang theo mục 4.4; `firestore.indexes.json` có đủ chỉ mục; trạng thái trống, đang tải, lỗi, ngoại tuyến.
```
Prompt T11: Làm UC03: watchMatches(MatchFilter) có phân trang 20, các chỉ mục ở 04 mục 4.4,
DiscoverController, màn S06 với MatchCard và bottom sheet S07. Nhóm danh sách theo "Hôm nay/Ngày mai/…".
```

## Tuần 4 – Tham gia kèo

### T12 · Chi tiết kèo (UC04)
- **Hoàn thành khi:** màn S08 với 3 biến thể nút theo vai trò; danh sách thành viên realtime; chia sẻ link kèo.

### T13 · Xin vào / duyệt / rời (UC06, UC07, UC08)
- **Hoàn thành khi:** `ParticipantRepository` với transaction theo mục 4.5; use case `RequestJoinMatch`, `ApproveParticipant`, `RejectParticipant`, `RemoveParticipant`, `LeaveMatch`; cảnh báo trùng giờ (BR05); rules + rules test, gồm trường hợp hai người tranh chỗ cuối.
```
Prompt T13: Làm UC06–UC08 theo sơ đồ tuần tự 5.7 và bảng 4.5. Mọi thay đổi slotsFilled phải
nằm trong transaction và được rules kiểm tra bằng getAfter. Viết rules test cho: tự vào kèo auto,
vào khi đủ người, duyệt khi đủ, người lạ sửa slotsFilled, rời muộn.
```

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
