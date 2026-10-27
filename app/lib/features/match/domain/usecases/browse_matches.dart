import '../../../../core/utils/district.dart';
import '../entities/geo_point.dart';
import '../entities/match.dart';

enum TimeFilter { today, tomorrow, weekend }

class MatchFilter {
  const MatchFilter({this.sportId, this.time, this.query = ''});

  final String? sportId;
  final TimeFilter? time;
  final String query;

  bool get isActive => sportId != null || time != null || query.trim().isNotEmpty;

  MatchFilter copyWith({
    String? Function()? sportId,
    TimeFilter? Function()? time,
    String? query,
  }) =>
      MatchFilter(
        sportId: sportId != null ? sportId() : this.sportId,
        time: time != null ? time() : this.time,
        query: query ?? this.query,
      );
}

List<Match> browseMatches(
  List<Match> matches, {
  required MatchFilter filter,
  required DateTime now,
  GeoPoint? origin,
}) {
  final query = _fold(filter.query.trim());
  final result = matches.where((m) {
    if (filter.sportId != null && m.sportId != filter.sportId) return false;
    if (filter.time != null && !_inTimeFilter(m.startAt, filter.time!, now)) return false;
    if (query.isEmpty) return true;
    return _fold(m.venue.name).contains(query) || _fold(districtName(m.district)).contains(query);
  }).toList();

  if (origin != null) {
    result.sort((a, b) => a.distanceFrom(origin)!.compareTo(b.distanceFrom(origin)!));
  } else {
    result.sort((a, b) => a.startAt.compareTo(b.startAt));
  }
  return result;
}

bool _inTimeFilter(DateTime t, TimeFilter filter, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  switch (filter) {
    case TimeFilter.today:
      return day == today;
    case TimeFilter.tomorrow:
      return day == today.add(const Duration(days: 1));
    case TimeFilter.weekend:
      return t.weekday >= DateTime.saturday;
  }
}

const _accents = {
  'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a', 'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
  'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a', 'đ': 'd',
  'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e', 'ê': 'e', 'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
  'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
  'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o', 'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
  'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
  'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u', 'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
  'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
};

String _fold(String s) {
  final lower = s.toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    buf.write(_accents[ch] ?? ch);
  }
  return buf.toString();
}
