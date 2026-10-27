const _names = {
  'q1': 'Quận 1', 'q3': 'Quận 3', 'q4': 'Quận 4', 'q5': 'Quận 5', 'q6': 'Quận 6', 'q7': 'Quận 7',
  'q8': 'Quận 8', 'q10': 'Quận 10', 'q11': 'Quận 11', 'q12': 'Quận 12',
  'binh-thanh': 'Bình Thạnh', 'phu-nhuan': 'Phú Nhuận', 'tan-binh': 'Tân Bình', 'tan-phu': 'Tân Phú',
  'go-vap': 'Gò Vấp', 'binh-tan': 'Bình Tân', 'thu-duc': 'Thủ Đức', 'binh-chanh': 'Bình Chánh',
  'nha-be': 'Nhà Bè', 'hoc-mon': 'Hóc Môn', 'cu-chi': 'Củ Chi', 'can-gio': 'Cần Giờ',
};

String districtName(String code) => _names[code] ?? code;

Iterable<String> get districtCodes => _names.keys;
