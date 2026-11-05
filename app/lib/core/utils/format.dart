import 'package:intl/intl.dart';

final _money = NumberFormat.decimalPattern('vi');

String formatMoney(int vnd) => '${_money.format(vnd)}đ';

String formatDistance(double meters) {
  if (meters < 1000) return '${(meters / 10).round() * 10} m';
  final km = meters / 1000;
  if (km >= 100) return '${km.round()} km';
  return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}

const _weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

String _hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String formatMatchTime(DateTime t, DateTime now) {
  final hm = _hm(t);
  final today = DateTime(now.year, now.month, now.day);
  final days = DateTime(t.year, t.month, t.day).difference(today).inDays;
  if (days == 0) return '$hm hôm nay';
  if (days == 1) return '$hm ngày mai';
  return '$hm ${_weekdays[t.weekday - 1]}, ${t.day}/${t.month}';
}

/// "Thứ 4, 12/11 · 19:00 – 20:30"
String formatTimeRange(DateTime start, DateTime end) =>
    '${_weekdays[start.weekday - 1]}, ${start.day}/${start.month} · ${_hm(start)} – ${_hm(end)}';

String formatLabel(String format) => switch (format) {
      '5v5' => 'Sân 5',
      '7v7' => 'Sân 7',
      '11v11' => 'Sân 11',
      'singles' => 'Đánh đơn',
      'doubles' => 'Đánh đôi',
      _ => format,
    };

const skillLevels = ['Mới chơi', 'Trung bình', 'Khá', 'Giỏi'];

String formatLevelRange(int min, int max) =>
    min == max ? skillLevels[min - 1] : '${skillLevels[min - 1]} – ${skillLevels[max - 1]}';
