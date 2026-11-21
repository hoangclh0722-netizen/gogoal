class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;

  /// null trong lúc chờ server ghi giờ.
  final DateTime? createdAt;
}

abstract interface class ChatRepository {
  /// 50 tin gần nhất, mới nhất trước.
  Stream<List<ChatMessage>> watch(String matchId);

  Future<void> send({required String matchId, required String uid, required String name, required String text});
}
