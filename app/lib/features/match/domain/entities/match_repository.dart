import 'match.dart';

abstract interface class MatchRepository {
  Future<List<Match>> upcomingMatches({Duration within = const Duration(days: 7)});

  /// null khi kèo không tồn tại hoặc đã bị ẩn.
  Stream<Match?> watchMatch(String id);

  /// Chủ kèo hủy kèo chưa bắt đầu. Phạt hủy muộn (BR08) để giai đoạn 2.
  Future<void> cancel(String id, String reason);
}
