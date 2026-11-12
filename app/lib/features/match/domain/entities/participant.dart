import 'match.dart';

enum ParticipantStatus { pending, approved, rejected, left, removed }

enum JoinError { full, denied, network }

class JoinException implements Exception {
  const JoinException(this.error);

  final JoinError error;
}

abstract interface class ParticipantRepository {
  /// Trạng thái của [uid] trong kèo, null nếu chưa từng xin vào.
  Stream<ParticipantStatus?> watchMyStatus(String matchId, String uid);

  /// Kèo duyệt tay: tạo yêu cầu chờ duyệt. Kèo vào ngay: vào luôn và giữ một chỗ.
  Future<void> requestJoin({
    required Match match,
    required String uid,
    required String displayName,
    required String? avatarUrl,
    required int level,
    String? message,
  });

  /// Hủy yêu cầu đang chờ, hoặc rời kèo đã được nhận (trả lại một chỗ).
  Future<void> leave({required Match match, required String uid, required ParticipantStatus current});
}
