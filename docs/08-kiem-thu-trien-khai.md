# 8. Kiểm thử, triển khai & rủi ro

## 8.1. Chiến lược kiểm thử

| Loại | Phạm vi | Công cụ | Mục tiêu |
|---|---|---|---|
| **Unit test** | Tầng domain: entity, value object, use case | `flutter_test`, `mocktail` | Phủ ≥ 70% domain; mọi quy tắc BR có test |
| **Widget test** | Các widget và màn hình quan trọng (MatchCard, S08, S09) | `flutter_test` + `ProviderScope` override | Hiển thị đúng theo state |
| **Repository test** | Chuyển đổi Model ↔ Entity, truy vấn | `fake_cloud_firestore` | Đúng cấu trúc dữ liệu ở mục 4.2 |
| **Rules test** | `firestore.rules` | `@firebase/rules-unit-testing` + Emulator | Mỗi rule có test "cho phép" và "từ chối" |
| **Kiểm thử thủ công** | Luồng đầu–cuối trên thiết bị thật | Bảng test case 8.2 | Chạy trước mỗi lần demo |
| **Thử nghiệm người dùng** | 5–10 người bạn, sau tuần 5 và tuần 8 | Google Form góp ý | Tìm lỗi trải nghiệm |

Ví dụ unit test cho quy tắc nghiệp vụ:

```dart
test('không cho xin vào khi kèo đã đủ người', () {
  final clock = FixedClock(DateTime(2026, 10, 23, 17));
  final match = buildMatch(slotsNeeded: 3, slotsFilled: 3,
      start: DateTime(2026, 10, 23, 19));

  expect(match.checkEligibility(buildPlayer(), clock), isA<MatchFull>());
});
```

## 8.2. Test case thủ công chính

| Mã | Use case | Bước | Kết quả mong đợi |
|---|---|---|---|
| TC01 | UC01 | Đăng nhập Google lần đầu | Vào màn hoàn thành hồ sơ |
| TC02 | UC01 | Đăng nhập email sai mật khẩu | Báo "Email hoặc mật khẩu không đúng" |
| TC03 | UC05 | Tạo kèo bắt đầu sau 10 phút | Báo lỗi BR01 |
| TC04 | UC05 | Tạo kèo 600.000đ, 10 người | Hiển thị 60.000đ/người |
| TC05 | UC06 | Xin vào kèo duyệt tay | Trạng thái "Đang chờ duyệt", chủ kèo nhận thông báo |
| TC06 | UC06 | Hai máy cùng xin chỗ cuối của kèo tự động | Chỉ một máy vào được, máy kia báo "Kèo vừa đủ người" |
| TC07 | UC06 | Người trình độ Mới chơi xin vào kèo Khá–Giỏi | Báo lỗi trình độ |
| TC08 | UC07 | Chủ kèo nhận người khi kèo đã đủ | Không cho nhận |
| TC09 | UC08 | Rời kèo 2 giờ trước giờ đá | Cảnh báo trừ uy tín; `lateLeaves` + 1 |
| TC10 | UC09 | Hủy kèo có thành viên | Mọi thành viên nhận thông báo hủy |
| TC11 | UC10 | Thành viên mở thanh toán | QR đúng ngân hàng, số tiền, nội dung |
| TC12 | UC10 | Người không phải thành viên đọc `private/payment` (qua code) | Bị từ chối (permission-denied) |
| TC13 | UC14 | Chủ kèo điểm danh 1 người vắng | Uy tín người đó giảm 0.3 |
| TC14 | UC15 | Đánh giá cùng một người hai lần | Lần hai bị chặn |
| TC15 | UC18 | Admin khóa tài khoản | Người bị khóa không tạo/xin vào kèo được |

## 8.3. Tích hợp liên tục (CI)

`.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  flutter:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: app } }
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed lib test
      - run: flutter analyze
      - run: flutter test --coverage

  rules:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: firebase/rules-test } }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: 21 }
      - run: npm ci
      - run: npx firebase-tools emulators:exec --only firestore --project demo-gogoal "npm test"
```

## 8.4. Triển khai

| Bước | Lệnh / việc làm |
|---|---|
| Triển khai rules & chỉ mục | `firebase deploy --only firestore:rules,firestore:indexes --project gogoal-prod` |
| Tạo khóa ký Android | `keytool -genkey ... upload-keystore.jks` (không commit file này) |
| Build APK để demo | `flutter build apk --release --dart-define=ENV=prod` |
| Build để đưa lên Google Play | `flutter build appbundle --release --dart-define=ENV=prod` |
| Phát hành thử | Google Play Console → *Internal testing* (phí đăng ký tài khoản nhà phát triển 25 USD, trả một lần). Hoặc gửi file APK trực tiếp |
| iOS (nếu có máy Mac) | `flutter build ipa` → TestFlight (cần tài khoản Apple Developer 99 USD/năm). Có thể để sau đồ án |
| Google Maps API key | Giới hạn key theo package `vn.gogoal.app` + SHA-1; đặt cảnh báo hạn mức trong Google Cloud |

## 8.5. Rủi ro & cách giảm thiểu

| Rủi ro | Khả năng | Ảnh hưởng | Giảm thiểu |
|---|---|---|---|
| Trễ tiến độ do mới học Flutter | Cao | Cao | Ưu tiên giai đoạn 1; cắt T23 → T19 → T20; giao task chi tiết cho Claude và học qua code mẫu |
| Logic ở client bị gian lận | Trung bình | Trung bình | Security Rules + rules test; khi có người dùng thật, chuyển logic quan trọng sang server (Blaze) |
| Vượt hạn mức Spark | Thấp (giai đoạn đầu) | Trung bình | Phân trang, cache, tránh lắng nghe realtime không cần thiết; theo dõi trong Firebase Console |
| Không có thông báo đẩy khi app đóng | Chắc chắn | Trung bình | Nhắc giờ bằng local notification; thông báo chưa đọc hiện khi mở app; giai đoạn sau thêm Cloudflare Worker + FCM |
| "Con gà – quả trứng": ít kèo nên ít người dùng | Cao | Cao | Tập trung 1–2 quận và nhóm bạn bè có sẵn; chủ động tạo kèo thật hằng tuần |
| Lừa đảo tiền sân | Thấp | Cao | Chỉ hiển thị QR cho thành viên đã duyệt; báo cáo vi phạm; uy tín |
| Logo trùng thương hiệu khác | Thấp | Trung bình | Không dùng kiểu chữ G lồng nhau; tra cứu trước khi phát hành |
| Google Maps phát sinh phí | Thấp | Thấp | Gói miễn phí hằng tháng của Maps SDK đủ cho thử nghiệm; giới hạn key |
