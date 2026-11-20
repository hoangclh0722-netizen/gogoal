import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_notification.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _box(String uid) => _db.collection('users').doc(uid).collection('notifications');

  @override
  Stream<List<AppNotification>> watchMine(String uid) =>
      _box(uid).orderBy('createdAt', descending: true).limit(50).snapshots().map((s) => [
            for (final d in s.docs)
              if (NotificationType.fromKey(d.data()['type'] as String) case final type?)
                AppNotification(
                  id: d.id,
                  type: type,
                  matchId: d.data()['matchId'] as String,
                  matchTitle: d.data()['matchTitle'] as String,
                  actorName: d.data()['actorName'] as String,
                  read: d.data()['read'] as bool,
                  createdAt: (d.data()['createdAt'] as Timestamp?)?.toDate(),
                ),
          ]);

  @override
  Stream<int> watchUnread(String uid) =>
      _box(uid).where('read', isEqualTo: false).snapshots().map((s) => s.size);

  @override
  Future<void> markRead(String uid, String id) => _box(uid).doc(id).update({'read': true});

  @override
  Future<void> markAllRead(String uid) async {
    final unread = await _box(uid).where('read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in unread.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  @override
  Future<void> send({
    required Iterable<String> to,
    required NotificationType type,
    required String matchId,
    required String matchTitle,
    required String actorId,
    required String actorName,
  }) async {
    final batch = _db.batch();
    for (final uid in to.toSet()..remove(actorId)) {
      batch.set(_box(uid).doc(), {
        'type': type.key,
        'matchId': matchId,
        'matchTitle': matchTitle,
        'actorId': actorId,
        'actorName': actorName,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
