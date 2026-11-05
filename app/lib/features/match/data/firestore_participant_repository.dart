import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/participant.dart';

class FirestoreParticipantRepository implements ParticipantRepository {
  FirestoreParticipantRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<ParticipantStatus?> watchMyStatus(String matchId, String uid) => _db
      .doc('matches/$matchId/participants/$uid')
      .snapshots()
      .map((s) => s.exists ? ParticipantStatus.values.byName(s.data()!['status'] as String) : null);
}
