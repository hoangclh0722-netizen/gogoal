# GoGoal (GG – Good Game)

Ứng dụng kết nối cộng đồng thể thao: tạo và tìm kèo bóng đá, cầu lông, bóng rổ, pickleball… tại TP.HCM.

## Cấu trúc

```
gogoal/
├── docs/       # Tài liệu dự án: use case, CSDL, kiến trúc, task, prompt Figma
│   └── assets/ # Logo, icon, sơ đồ
├── app/        # Ứng dụng Flutter
└── firebase/   # Security rules, Cloud Functions, cấu hình emulator
```

## Công nghệ

- Flutter (iOS + Android), Riverpod, Clean Architecture
- Firebase: Auth, Firestore, Cloud Messaging, Cloud Functions, Emulator Suite
- Google Maps + geohash cho tìm kèo gần

Tài liệu đầy đủ: [docs/README.md](docs/README.md).
