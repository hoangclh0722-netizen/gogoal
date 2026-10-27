import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _db.collection('users').doc(uid);

  @override
  Stream<UserProfile?> watch(String uid) => _doc(uid).snapshots().map((s) => _toProfile(uid, s.data()));

  @override
  Future<UserProfile?> fetch(String uid) async => _toProfile(uid, (await _doc(uid).get()).data());

  @override
  Future<void> create(UserProfile p) => _doc(p.uid).set({
        ..._editable(p),
        'bio': null,
        'role': 'user',
        'banned': false,
        'stats': {'ratingSum': 0, 'ratingCount': 0, 'matchesPlayed': 0, 'noShows': 0, 'lateLeaves': 0, 'lateCancels': 0},
        'tagCounts': <String, int>{},
        'createdAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> update(UserProfile p) => _doc(p.uid).update(_editable(p));

  Map<String, dynamic> _editable(UserProfile p) => {
        'displayName': p.displayName.trim(),
        'avatarUrl': p.avatarUrl,
        'district': p.district,
        'sports': p.sports,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UserProfile? _toProfile(String uid, Map<String, dynamic>? d) {
    if (d == null || d['profileCompleted'] != true) return null;
    final stats = (d['stats'] as Map<String, dynamic>?) ?? const {};
    int s(String key) => (stats[key] as num?)?.toInt() ?? 0;
    return UserProfile(
      uid: uid,
      displayName: d['displayName'] as String,
      district: d['district'] as String,
      sports: (d['sports'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt())),
      avatarUrl: d['avatarUrl'] as String?,
      ratingSum: s('ratingSum'),
      ratingCount: s('ratingCount'),
      matchesPlayed: s('matchesPlayed'),
      noShows: s('noShows'),
      lateLeaves: s('lateLeaves'),
      lateCancels: s('lateCancels'),
    );
  }
}
