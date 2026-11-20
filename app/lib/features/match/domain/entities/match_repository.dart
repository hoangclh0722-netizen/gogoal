import 'match.dart';

abstract interface class MatchRepository {
  Future<List<Match>> upcomingMatches({Duration within = const Duration(days: 7)});

  /// null khi kèo không tồn tại hoặc đã bị ẩn.
  Stream<Match?> watchMatch(String id);

  /// Chủ kèo hủy kèo chưa bắt đầu. Phạt hủy muộn (BR08) để giai đoạn 2.
  Future<void> cancel(String id, String reason);

  /// Chốt kèo thì các yêu cầu đang chờ bị từ chối cùng lúc; mở lại thì chỉ đổi cờ.
  Future<void> setLocked(String id, bool locked);

  /// Kèo mình tạo, đã vào, đang chờ duyệt và đang theo dõi.
  Future<List<MyMatch>> myMatches(String uid);

  Stream<bool> watchIsWatching(String uid, String matchId);

  /// Theo dõi kèo không chiếm chỗ, chỉ lưu ở hồ sơ riêng của người chơi.
  Future<void> setWatching(String uid, Match match, bool on);

  /// Kèo cùng môn, bắt đầu lệch không quá 1 giờ, còn nhận người.
  Future<List<Match>> sameTime(Match match);

  Future<List<VenueOption>> venues(String sportId);

  /// Id sinh trước để bấm "thử lại" sau khi mất mạng không tạo ra hai kèo.
  String newId();

  Future<void> create(String id, MatchDraft draft, {required String hostId, required Host host});

  /// Chủ kèo sửa kèo chưa bắt đầu; [slotsFilled] để tính lại isFull. Môn không đổi được.
  Future<void> update(String id, MatchDraft draft, {required int slotsFilled});
}
