# UX – Đăng nhập, đăng ký, hồ sơ (S03, S04, S05, S15)

Trạng thái: đã chốt (27/10/2026). Thiết kế: [Figma](https://www.figma.com/design/VWNTYmdK4H0Br5EjhFqdUJ).

## Luồng
Khách bấm Xin vào / Tạo kèo / Thông báo / Hồ sơ → Đăng nhập.
- Đăng nhập thành công, hồ sơ đã đủ → quay lại đúng hành động vừa bấm.
- Lần đầu (chưa có hồ sơ) → Hoàn thành hồ sơ 2 bước → quay lại hành động.
- Đăng nhập → "Chưa có tài khoản? Đăng ký" → Đăng ký → Hoàn thành hồ sơ.
- Quên mật khẩu: **để sau**. Tạm thời bấm "Quên mật khẩu" hiện "Sắp có". Firebase chỉ hỗ trợ gửi link đặt lại; muốn dùng mã OTP như nhiều app khác thì cần server riêng, sẽ cân nhắc ở giai đoạn sau.

## Cách đăng nhập
- Email + mật khẩu, Google.
- Facebook: nút vẫn hiện, bấm báo "Sắp có" (làm ở bước sau).
- Đăng ký email: mật khẩu tối thiểu 8 ký tự, nhập lại phải khớp, tick đồng ý điều khoản. Không bắt xác minh email; Firebase gửi email xác minh, hồ sơ hiện nhắc "Chưa xác minh email".
- Email đã đăng ký bằng cách khác: báo "Email này đã đăng ký bằng <cách>. Hãy đăng nhập bằng cách đó." Chưa gộp tài khoản.

## Hoàn thành hồ sơ (S05) – chỉ hiện lần đầu
Thanh tiến độ "Bước 1/2", "Bước 2/2".
1. **Bạn là ai?** Avatar (ảnh Google, hoặc chữ cái đầu của tên), ô "Tên hiển thị" (2–40 ký tự, Google thì điền sẵn, sửa được), chọn "Quận/Huyện" (danh sách TP.HCM). Nút "Tiếp tục".
2. **Bạn chơi môn gì?** 5 ô môn có icon và màu theo môn, chọn ít nhất 1. Mỗi môn đã chọn hiện 4 mức trình độ: Mới chơi / Trung bình / Khá / Giỏi. Nút "Hoàn tất" chỉ bật khi đã chọn môn và trình độ cho từng môn.

Thông tin ngân hàng không hỏi ở đây; hỏi khi lần đầu tạo kèo có thu tiền.

## Hồ sơ của tôi (S15) – tab Hồ sơ
Avatar, tên, quận · nhắc "Chưa xác minh email" + "Gửi lại" (nếu có) · uy tín (chưa có thì "Chưa có đánh giá") · danh sách môn + trình độ · nút "Sửa hồ sơ" (mở lại S05 với dữ liệu cũ) · nút "Đăng xuất" (hộp xác nhận "Đăng xuất khỏi GoGoal?" Hủy / Đăng xuất). Đăng xuất xong về Home ở chế độ khách.

## Trạng thái và lỗi
| Tình huống | Hiển thị |
|---|---|
| Sai email hoặc mật khẩu | "Email hoặc mật khẩu không đúng" dưới nút Đăng nhập |
| Email sai định dạng | "Email không hợp lệ" dưới ô email |
| Mật khẩu < 8 ký tự | "Mật khẩu cần ít nhất 8 ký tự" dưới ô |
| Nhập lại không khớp | "Mật khẩu nhập lại không khớp" |
| Email đã được dùng | "Email này đã được đăng ký" + link "Đăng nhập" |
| Mất mạng | "Không kết nối được, thử lại" |
| Đang xử lý | Nút hiện vòng xoay, khóa bấm lần hai |
| Hủy chọn tài khoản Google | Không báo gì, ở lại màn Đăng nhập |
