import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/chat_message.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _box(String matchId) =>
      _db.collection('matches').doc(matchId).collection('messages');

  @override
  Stream<List<ChatMessage>> watch(String matchId) =>
      _box(matchId).orderBy('createdAt', descending: true).limit(50).snapshots().map((s) => [
            for (final d in s.docs)
              ChatMessage(
                id: d.id,
                senderId: d.data()['senderId'] as String,
                senderName: d.data()['senderName'] as String,
                text: d.data()['text'] as String,
                createdAt: (d.data()['createdAt'] as Timestamp?)?.toDate(),
              ),
          ]);

  @override
  Future<void> send({required String matchId, required String uid, required String name, required String text}) =>
      _box(matchId).add({
        'senderId': uid,
        'senderName': name,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
}
