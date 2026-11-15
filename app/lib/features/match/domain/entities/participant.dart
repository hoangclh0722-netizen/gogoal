import 'match.dart';

enum ParticipantStatus { pending, approved, rejected, left, removed }

class Member {
  const Member({required this.uid, required this.displayName, required this.level, this.avatarUrl});

  final String uid;
  final String displayName;
  final int level;
  final String? avatarUrl;
}

class JoinRequest extends Member {
  const JoinRequest({
    required super.uid,
    required super.displayName,
    required super.level,
    super.avatarUrl,
    this.message,
    this.requestedAt,
  });

  final String? message;
  final DateTime? requestedAt;
}

enum JoinError { full, denied, network }

class JoinException implements Exception {
  const JoinException(this.error);

  final JoinError error;
}

abstract interface class ParticipantRepository {
  /// Trạng thái của [uid] trong kèo, null nếu chưa từng xin vào.
  Stream<ParticipantStatus?> watchMyStatus(String matchId, String uid);

  /// Thành viên đã được nhận. Chỉ chủ kèo và thành viên mới đọc được (rules).
  Stream<List<Member>> watchMembers(String matchId);

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

  /// Yêu cầu đang chờ duyệt, cũ nhất trước. Chỉ chủ kèo đọc được.
  Stream<List<JoinRequest>> watchRequests(String matchId);

  /// Chủ kèo nhận người: participant → approved và giữ thêm một chỗ.
  Future<void> approve({required Match match, required String uid});

  Future<void> reject({required Match match, required String uid});
}
