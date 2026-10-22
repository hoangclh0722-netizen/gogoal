# Tài liệu dự án GoGoal

| # | Tài liệu | Nội dung |
|---|---|---|
| 0 | [Các quyết định đã chốt](00-decisions.md) | Tóm tắt mọi quyết định sản phẩm và kỹ thuật |
| 1 | [Tổng quan](01-tong-quan.md) | Vấn đề, giải pháp, người dùng, mục tiêu, phạm vi, ràng buộc |
| 2 | [Yêu cầu](02-yeu-cau.md) | Yêu cầu chức năng, quy tắc nghiệp vụ, công thức uy tín, yêu cầu phi chức năng |
| 3 | [Use case](03-use-case.md) | Tác nhân, sơ đồ use case, đặc tả 18 use case, sơ đồ hoạt động |
| 4 | [Cơ sở dữ liệu](04-co-so-du-lieu.md) | ERD, cấu trúc Firestore, sơ đồ trạng thái, chỉ mục, Security Rules, hạn mức |
| 5 | [Kiến trúc](05-kien-truc.md) | Clean Architecture, cấu trúc thư mục, OOP & SOLID, sơ đồ lớp, sơ đồ tuần tự, code mẫu |
| 6 | [Màn hình & Figma](06-man-hinh-figma.md) | Design tokens, danh sách màn hình, luồng màn hình, prompt thiết kế |
| 7 | [Kế hoạch & task](07-ke-hoach-task.md) | Lộ trình 8 tuần, 25 task kèm tiêu chí hoàn thành và prompt |
| 8 | [Kiểm thử & triển khai](08-kiem-thu-trien-khai.md) | Chiến lược test, test case, CI, phát hành, rủi ro |

## Xem sơ đồ

- **Mermaid** (ERD, sơ đồ lớp, tuần tự, trạng thái, hoạt động): hiển thị trực tiếp trên GitHub. Trong VS Code, cài extension *Markdown Preview Mermaid Support*. Để xuất ảnh cho báo cáo, dùng [mermaid.live](https://mermaid.live).
- **PlantUML** (sơ đồ use case): cài extension *PlantUML* trong VS Code, hoặc dán vào [plantuml.com](https://www.plantuml.com/plantuml).

## Ánh xạ sang báo cáo đồ án

| Chương báo cáo | Lấy từ |
|---|---|
| Chương 1 – Tổng quan | 01 |
| Chương 2 – Phân tích yêu cầu | 02, 03 |
| Chương 3 – Thiết kế hệ thống | 04, 05, 06 |
| Chương 4 – Cài đặt & kiểm thử | 05 (code mẫu), 07, 08 |
| Chương 5 – Kết luận & hướng phát triển | 01 (ngoài phạm vi), 08 (rủi ro) |
