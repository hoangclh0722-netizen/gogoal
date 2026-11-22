import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/rating.dart';

class FirestoreRatingRepository implements RatingRepository {
  FirestoreRatingRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<Set<String>> ratedBy(String matchId, String fromUid) async {
    final snap = await _db
        .collection('ratings')
        .where('matchId', isEqualTo: matchId)
        .where('fromUid', isEqualTo: fromUid)
        .get();
    return {for (final d in snap.docs) d.data()['toUid'] as String};
  }

  @override
  Future<void> submit({required String matchId, required String fromUid, required List<RatingDraft> ratings}) {
    final batch = _db.batch();
    for (final r in ratings) {
      // Id cố định để mỗi người chỉ chấm một người một lần trong một kèo
      final id = '${matchId}_${fromUid}_${r.toUid}';
      batch
        ..set(_db.collection('ratings').doc(id), {
          'matchId': matchId,
          'fromUid': fromUid,
          'toUid': r.toUid,
          'stars': r.stars,
          'tags': [for (final t in r.tags) t.key],
          'createdAt': FieldValue.serverTimestamp(),
        })
        ..update(_db.collection('users').doc(r.toUid), {
          'stats.ratingSum': FieldValue.increment(r.stars),
          'stats.ratingCount': FieldValue.increment(1),
          'statsRating': id,
        });
    }
    return batch.commit().timeout(const Duration(seconds: 10));
  }

  @override
  Future<Map<RatingTag, int>> tagCounts(String uid) async {
    final snap = await _db.collection('ratings').where('toUid', isEqualTo: uid).limit(200).get();
    final counts = <RatingTag, int>{};
    for (final d in snap.docs) {
      for (final key in (d.data()['tags'] as List).cast<String>()) {
        final tag = RatingTag.fromKey(key);
        if (tag != null) counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }
}
