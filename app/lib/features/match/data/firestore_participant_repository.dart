import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notification/domain/app_notification.dart';
import '../../profile/domain/user_profile.dart';
import '../domain/entities/match.dart';
import '../domain/entities/participant.dart';

class FirestoreParticipantRepository implements ParticipantRepository {
  FirestoreParticipantRepository(this._db, this._notifier);

  final FirebaseFirestore _db;
  final NotificationRepository _notifier;

  // Thông báo gửi kèm sau khi hành động đã xong; lỗi gửi không làm hỏng hành động chính
  void _notify(Match m, NotificationType type, {required String to, required String actorId, required String actorName}) {
    unawaited(_notifier
        .send(to: [to], type: type, matchId: m.id, matchTitle: m.title, actorId: actorId, actorName: actorName)
        .catchError((_) {}));
  }

  @override
  Stream<ParticipantStatus?> watchMyStatus(String matchId, String uid) => _db
      .doc('matches/$matchId/participants/$uid')
      .snapshots()
      .map((s) => s.exists ? ParticipantStatus.values.byName(s.data()!['status'] as String) : null);

  @override
  Stream<List<Member>> watchMembers(String matchId) => _db
      .collection('matches/$matchId/participants')
      .where('status', isEqualTo: 'approved')
      .snapshots()
      .map((s) => s.docs.map((d) {
            final p = d.data();
            return Member(
              uid: d.id,
              displayName: p['displayName'] as String,
              level: (p['level'] as num).toInt(),
              avatarUrl: p['avatarUrl'] as String?,
            );
          }).toList());

  @override
  Future<void> requestJoin({required Match match, required UserProfile profile, String? message}) => _run(() async {
    final uid = profile.uid;
    final displayName = profile.displayName;
    final matchRef = _db.doc('matches/${match.id}');
    final ref = matchRef.collection('participants').doc(uid);
    final data = {
      'uid': uid,
      'matchId': match.id,
      'matchStartAt': Timestamp.fromDate(match.startAt),
      'displayName': displayName,
      'avatarUrl': profile.avatarUrl,
      'level': profile.sports[match.sportId]!,
      'status': match.autoApprove ? 'approved' : 'pending',
      'message': message,
      'paid': false,
      'paidConfirmed': false,
      'attended': null,
      'requestedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!match.autoApprove) {
      await ref.set(data);
      _notify(match, NotificationType.joinRequested, to: match.hostId, actorId: uid, actorName: displayName);
      return;
    }
    // Hai người cùng giành chỗ cuối: transaction đọc lại số chỗ, người đến sau thấy đã đủ
    await _db.runTransaction((tx) async {
      final d = (await tx.get(matchRef)).data()!;
      final filled = (d['slotsFilled'] as num).toInt();
      final needed = (d['slotsNeeded'] as num).toInt();
      if (filled >= needed) throw const JoinException(JoinError.full);
      tx.set(ref, data);
      tx.update(matchRef, {
        'slotsFilled': filled + 1,
        'isFull': filled + 1 >= needed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    _notify(match, NotificationType.memberJoined, to: match.hostId, actorId: uid, actorName: displayName);
  });

  @override
  Future<void> leave({required Match match, required String uid, required ParticipantStatus current}) => _run(() async {
    final matchRef = _db.doc('matches/${match.id}');
    final ref = matchRef.collection('participants').doc(uid);
    final left = {'status': 'left', 'updatedAt': FieldValue.serverTimestamp()};
    final name = (await ref.get()).data()?['displayName'] as String? ?? '';
    if (current == ParticipantStatus.pending) {
      await ref.update(left);
      return;
    }
    await _db.runTransaction((tx) async {
      final filled = ((await tx.get(matchRef)).data()!['slotsFilled'] as num).toInt();
      tx.update(ref, left);
      tx.update(matchRef, {
        'slotsFilled': filled - 1,
        'isFull': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    _notify(match, NotificationType.memberLeft, to: match.hostId, actorId: uid, actorName: name);
  });

  @override
  Stream<List<JoinRequest>> watchRequests(String matchId) => _db
      .collection('matches/$matchId/participants')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) {
        final list = s.docs.map((d) {
          final p = d.data();
          return JoinRequest(
            uid: d.id,
            displayName: p['displayName'] as String,
            level: (p['level'] as num).toInt(),
            avatarUrl: p['avatarUrl'] as String?,
            message: p['message'] as String?,
            // null trong lúc chờ server ghi giờ
            requestedAt: (p['requestedAt'] as Timestamp?)?.toDate(),
          );
        }).toList();
        list.sort((a, b) => (a.requestedAt ?? DateTime.now()).compareTo(b.requestedAt ?? DateTime.now()));
        return list;
      });

  @override
  Future<void> approve({required Match match, required String uid}) => _run(() async {
        final matchRef = _db.doc('matches/${match.id}');
        final ref = matchRef.collection('participants').doc(uid);
        await _db.runTransaction((tx) async {
          final d = (await tx.get(matchRef)).data()!;
          final p = await tx.get(ref);
          if (p.data()?['status'] != 'pending') throw const JoinException(JoinError.denied);
          final filled = (d['slotsFilled'] as num).toInt();
          final needed = (d['slotsNeeded'] as num).toInt();
          if (filled >= needed) throw const JoinException(JoinError.full);
          tx.update(ref, {'status': 'approved', 'updatedAt': FieldValue.serverTimestamp()});
          tx.update(matchRef, {
            'slotsFilled': filled + 1,
            'isFull': filled + 1 >= needed,
            'changedMember': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
        _notify(match, NotificationType.joinApproved, to: uid, actorId: match.hostId, actorName: match.host.displayName);
      });

  @override
  Future<void> reject({required Match match, required String uid}) => _run(() async {
        await _db
            .doc('matches/${match.id}/participants/$uid')
            .update({'status': 'rejected', 'updatedAt': FieldValue.serverTimestamp()});
        _notify(match, NotificationType.joinRejected, to: uid, actorId: match.hostId, actorName: match.host.displayName);
      });

  @override
  Future<void> remove({required Match match, required String uid}) => _run(() async {
        final matchRef = _db.doc('matches/${match.id}');
        final ref = matchRef.collection('participants').doc(uid);
        await _db.runTransaction((tx) async {
          final filled = ((await tx.get(matchRef)).data()!['slotsFilled'] as num).toInt();
          if ((await tx.get(ref)).data()?['status'] != 'approved') throw const JoinException(JoinError.denied);
          tx.update(ref, {'status': 'removed', 'updatedAt': FieldValue.serverTimestamp()});
          tx.update(matchRef, {
            'slotsFilled': filled - 1,
            'isFull': false,
            'changedMember': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
        _notify(match, NotificationType.removed, to: uid, actorId: match.hostId, actorName: match.host.displayName);
      });

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const JoinException(JoinError.network);
    } on FirebaseException catch (e) {
      throw JoinException(e.code == 'unavailable' ? JoinError.network : JoinError.denied);
    }
  }
}
