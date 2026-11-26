# Thêm sân mới

Chủ kèo không thấy sân mình đá trong danh sách thì tự thêm, không phải chờ admin. Sân thêm xong dùng được ngay cho mọi người, kèm nhãn "Do người dùng thêm" tới khi admin xác nhận.

## Luồng

1. Tạo kèo → bấm ô Sân → bảng Chọn sân.
2. Cuối bảng có nút "Không thấy sân? Thêm sân mới" (luôn hiện, kể cả khi danh sách trống).
3. Mở màn Thêm sân (toàn màn hình). Lưu xong quay về Tạo kèo với sân mới đã được chọn.

## Màn Thêm sân

| Phần | Cách nhập | Ràng buộc |
|---|---|---|
| Vị trí | Bản đồ OpenStreetMap, ghim cố định giữa bản đồ, kéo bản đồ để đặt ghim đúng sân. Mở sẵn ở vị trí hiện tại (không có quyền vị trí thì ở trung tâm TP.HCM). Nút "Vị trí của tôi" | Trong lãnh thổ Việt Nam |
| Tên sân | Ô chữ | 2–60 ký tự |
| Địa chỉ | Ô chữ, ví dụ "12 Phan Văn Trị" | 1–120 ký tự |
| Quận | Danh sách quận như hồ sơ | Bắt buộc |
| Môn | Chip chọn nhiều, chọn sẵn môn đang tạo kèo và không bỏ được môn đó | Ít nhất 1 môn |

Ghi công bản đồ "© OpenStreetMap" ở góc bản đồ (điều kiện dùng ô bản đồ OSM).

## Chống trùng

Khi ghim cách một sân đã có (cùng môn) dưới 200 m, hiện dải vàng phía trên ô Tên sân: "Gần đây đã có **Sân bóng Tao Đàn** (120 m). Có phải sân này?" kèm nút "Chọn sân này" (quay về Tạo kèo với sân đó). Không chặn lưu, vì hai sân có thể sát nhau thật.

## Trạng thái và lỗi

| Tình huống | Hiển thị |
|---|---|
| Thiếu tên, địa chỉ hoặc quận | Nút "Lưu sân" xám |
| Đang lưu | Nút "Đang lưu…", khóa bấm |
| Mất mạng / lỗi lưu | Chữ đỏ trên nút "Không lưu được sân, thử lại", giữ nguyên dữ liệu |

## Dữ liệu và quyền

- `venues/{id}` do người dùng tạo có thêm `createdBy` (uid) và `verified: false`. Sân admin nạp sẵn không có hai trường này, coi như đã xác nhận.
- Ai đã hoàn thành hồ sơ và không bị khóa thì được tạo sân. Không ai ngoài admin được sửa hay xóa sân.
- Trong bảng Chọn sân, sân `verified == false` có nhãn nhỏ "Do người dùng thêm".

## Để sau

- Màn admin duyệt, gộp sân trùng, xóa sân rác.
- Người dùng đề xuất sửa tên / vị trí sân.
- Thêm môn cho sân đã có (hiện chỉ admin sửa được).
- Giới hạn số sân một người thêm mỗi ngày.
