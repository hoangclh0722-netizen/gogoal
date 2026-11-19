import 'match.dart';

abstract interface class MatchRepository {
  Future<List<Match>> upcomingMatches({Duration within = const Duration(days: 7)});

  /// null khi kèo không tồn tại hoặc đã bị ẩn.
  Stream<Match?> watchMatch(String id);

  /// Chủ kèo hủy kèo chưa bắt đầu. Phạt hủy muộn (BR08) để giai đoạn 2.
  Future<void> cancel(String id, String reason);

  Future<List<VenueOption>> venues(String sportId);

  /// Id sinh trước để bấm "thử lại" sau khi mất mạng không tạo ra hai kèo.
  String newId();

  Future<void> create(String id, MatchDraft draft, {required String hostId, required Host host});
}
