import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/match.dart';
import '../domain/entities/participant.dart';

class FirestoreParticipantRepository implements ParticipantRepository {
  FirestoreParticipantRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<ParticipantStatus?> watchMyStatus(String matchId, String uid) => _db
      .doc('matches/$matchId/participants/$uid')
      .snapshots()
      .map((s) => s.exists ? ParticipantStatus.values.byName(s.data()!['status'] as String) : null);

  @override
  Future<void> requestJoin({
    required Match match,
    required String uid,
    required String displayName,
    required String? avatarUrl,
    required int level,
    String? message,
  }) async {
    final matchRef = _db.doc('matches/${match.id}');
    final ref = matchRef.collection('participants').doc(uid);
    final data = {
      'uid': uid,
      'matchId': match.id,
      'matchStartAt': Timestamp.fromDate(match.startAt),
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'level': level,
      'status': match.autoApprove ? 'approved' : 'pending',
      'message': message,
      'paid': false,
      'paidConfirmed': false,
      'attended': null,
      'requestedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      if (!match.autoApprove) {
        await ref.set(data).timeout(const Duration(seconds: 10));
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
      }).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const JoinException(JoinError.network);
    } on FirebaseException catch (e) {
      throw JoinException(e.code == 'unavailable' ? JoinError.network : JoinError.denied);
    }
  }

  @override
  Future<void> leave({required Match match, required String uid, required ParticipantStatus current}) async {
    final matchRef = _db.doc('matches/${match.id}');
    final ref = matchRef.collection('participants').doc(uid);
    final left = {'status': 'left', 'updatedAt': FieldValue.serverTimestamp()};
    try {
      if (current == ParticipantStatus.pending) {
        await ref.update(left).timeout(const Duration(seconds: 10));
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
      }).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const JoinException(JoinError.network);
    } on FirebaseException catch (e) {
      throw JoinException(e.code == 'unavailable' ? JoinError.network : JoinError.denied);
    }
  }
}
