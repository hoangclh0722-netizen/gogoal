enum NotificationType {
  joinRequested('join_requested'),
  memberJoined('member_joined'),
  joinApproved('join_approved'),
  joinRejected('join_rejected'),
  removed('removed'),
  memberLeft('member_left'),
  matchCancelled('match_cancelled'),
  matchUpdated('match_updated'),
  matchLocked('match_locked');

  const NotificationType(this.key);

  /// Giá trị lưu trong Firestore.
  final String key;

  static NotificationType? fromKey(String key) => values.where((t) => t.key == key).firstOrNull;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.matchId,
    required this.matchTitle,
    required this.actorName,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String matchId;
  final String matchTitle;
  final String actorName;
  final bool read;
  final DateTime? createdAt;

  String get text {
    final t = '“$matchTitle”';
    return switch (type) {
      NotificationType.joinRequested => '$actorName xin vào $t',
      NotificationType.memberJoined => '$actorName đã vào $t',
      NotificationType.joinApproved => 'Bạn đã được nhận vào $t',
      NotificationType.joinRejected => 'Chủ kèo đã từ chối yêu cầu vào $t',
      NotificationType.removed => 'Bạn đã được mời ra khỏi $t',
      NotificationType.memberLeft => '$actorName đã rời $t',
      NotificationType.matchCancelled => '$t đã bị hủy, tìm kèo khác cùng giờ nhé',
      NotificationType.matchUpdated => '$t vừa đổi giờ hoặc sân',
      NotificationType.matchLocked => '$t đã chốt, hẹn gặp ở sân',
    };
  }
}

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchMine(String uid);

  Stream<int> watchUnread(String uid);

  Future<void> markRead(String uid, String id);

  Future<void> markAllRead(String uid);

  /// Gửi cho từng người trong [to], bỏ qua chính người gửi.
  Future<void> send({
    required Iterable<String> to,
    required NotificationType type,
    required String matchId,
    required String matchTitle,
    required String actorId,
    required String actorName,
  });
}
