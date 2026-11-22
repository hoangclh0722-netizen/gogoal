import '../../../profile/domain/user_profile.dart';
import 'match.dart';

enum ParticipantStatus { pending, approved, rejected, left, removed }

/// Phần chung của một người trong kèo, chép từ hồ sơ lúc xin vào.
abstract class Participant {
  const Participant({required this.uid, required this.displayName, required this.level, this.avatarUrl});

  final String uid;
  final String displayName;
  final int level;
  final String? avatarUrl;
}

/// Người đã được nhận vào kèo.
class Member extends Participant {
  const Member({required super.uid, required super.displayName, required super.level, super.avatarUrl, this.attended});

  /// null là chưa điểm danh.
  final bool? attended;
}

/// Yêu cầu đang chờ chủ kèo duyệt.
class JoinRequest extends Participant {
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
  Future<void> requestJoin({required Match match, required UserProfile profile, String? message});

  /// Hủy yêu cầu đang chờ, hoặc rời kèo đã được nhận (trả lại một chỗ).
  Future<void> leave({required Match match, required String uid, required ParticipantStatus current});

  /// Yêu cầu đang chờ duyệt, cũ nhất trước. Chỉ chủ kèo đọc được.
  Stream<List<JoinRequest>> watchRequests(String matchId);

  /// Chủ kèo nhận người: participant → approved và giữ thêm một chỗ.
  Future<void> approve({required Match match, required String uid});

  Future<void> reject({required Match match, required String uid});

  /// Chủ kèo mời thành viên ra: participant → removed và trả lại một chỗ.
  Future<void> remove({required Match match, required String uid});

  /// Chủ kèo điểm danh (UC14): [present] là uid → có mặt hay không, cho mọi thành viên đã được nhận.
  Future<void> takeAttendance({required Match match, required Map<String, bool> present});
}
