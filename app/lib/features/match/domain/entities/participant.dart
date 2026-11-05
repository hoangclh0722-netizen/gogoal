enum ParticipantStatus { pending, approved, rejected, left, removed }

abstract interface class ParticipantRepository {
  /// Trạng thái của [uid] trong kèo, null nếu chưa từng xin vào.
  Stream<ParticipantStatus?> watchMyStatus(String matchId, String uid);
}
