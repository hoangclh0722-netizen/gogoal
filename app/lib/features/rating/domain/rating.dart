enum RatingTag {
  onTime('on_time', 'Đúng giờ'),
  fairPlay('fair_play', 'Fair-play'),
  friendly('friendly', 'Vui vẻ'),
  skilled('skilled', 'Chơi hay');

  const RatingTag(this.key, this.label);

  /// Giá trị lưu trong Firestore.
  final String key;
  final String label;

  static RatingTag? fromKey(String key) => values.where((t) => t.key == key).firstOrNull;
}

class RatingDraft {
  const RatingDraft({required this.toUid, required this.stars, required this.tags});

  final String toUid;
  final int stars;
  final Set<RatingTag> tags;
}

abstract interface class RatingRepository {
  /// uid những người [fromUid] đã chấm trong kèo [matchId].
  Future<Set<String>> ratedBy(String matchId, String fromUid);

  /// Ghi đánh giá và cộng sao cho từng người được chấm trong một batch (BR10).
  Future<void> submit({required String matchId, required String fromUid, required List<RatingDraft> ratings});

  /// Số lần nhận mỗi thẻ của [uid], để hiện thẻ nổi bật ở hồ sơ.
  Future<Map<RatingTag, int>> tagCounts(String uid);
}
