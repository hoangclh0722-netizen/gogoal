# Theo dõi kèo và Tìm kèo cùng giờ

Mục tiêu: kèo đang chờ có dấu hiệu bể thì người chơi có sẵn phương án khác, mà không giữ chỗ ở hai kèo cùng lúc.

## Theo dõi kèo

- Chi tiết kèo (người đã đăng nhập, không phải chủ kèo, chưa ở trong kèo): nút ngôi sao ở góc phải header. Bấm để theo dõi / bỏ theo dõi, hiện thông báo ngắn.
- Theo dõi **không chiếm chỗ**, không tính vào số người, chủ kèo không thấy.
- Kèo của tôi → tab Sắp tới có thêm mục **Đang theo dõi** bên dưới, thẻ có nhãn "Theo dõi" và nhãn tình trạng. Kèo đã bắt đầu thì không hiện.
- Lưu ở `users/{uid}/watching/{matchId}`, chỉ chính chủ đọc/ghi.

## Tìm kèo cùng giờ

- Hiện ở Chi tiết kèo khi kèo **có nguy cơ bể** hoặc **đã bể**, cho người đang ở trong kèo hoặc đang chờ duyệt.
- Mục "Kèo cùng giờ": tối đa 3 kèo cùng môn, giờ bắt đầu lệch không quá 1 tiếng, còn nhận người (chưa đủ, chưa chốt, chưa qua hạn chốt), gần mình nhất trước. Bấm để mở chi tiết, ở đó xin vào hoặc theo dõi.
- Không có kèo nào thì hiện "Chưa có kèo nào cùng giờ".

## Nhắc nhường chỗ kèo trùng giờ

Chi tiết kèo B (mình đã được nhận, kèo chưa bắt đầu): nếu mình còn ở kèo A trùng giờ (đã vào hoặc đang chờ duyệt, kèo A chưa hủy) thì hiện dải vàng "Bạn còn ở “A” cùng giờ. Nhường chỗ cho người khác nhé?" kèm nút **Rời kèo** / **Hủy** (có hộp xác nhận). Rời xong dải tự mất.

## Để sau

- Thông báo khi kèo đang theo dõi sắp đủ người hoặc kèo chính có nguy cơ bể.
