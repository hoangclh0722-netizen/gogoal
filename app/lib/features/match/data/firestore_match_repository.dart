import 'package:cloud_firestore/cloud_firestore.dart' hide GeoPoint;
import 'package:cloud_firestore/cloud_firestore.dart' as fs show GeoPoint;

import '../domain/entities/geo_point.dart';
import '../domain/entities/match.dart';
import '../domain/entities/match_repository.dart';

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<List<Match>> upcomingMatches({Duration within = const Duration(days: 7)}) async {
    final now = DateTime.now();
    final snap = await _db
        .collection('matches')
        .where('status', isEqualTo: 'active')
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('startAt', isLessThan: Timestamp.fromDate(now.add(within)))
        .orderBy('startAt')
        .limit(50)
        // Đọc thẳng từ server để mất mạng thì báo lỗi thay vì trả cache rỗng
        .get(const GetOptions(source: Source.server));
    return snap.docs.map(_toMatch).toList();
  }

  Match _toMatch(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final venue = d['venue'] as Map<String, dynamic>;
    final host = d['host'] as Map<String, dynamic>;
    final point = (d['geo'] as Map<String, dynamic>)['geopoint'] as fs.GeoPoint;
    int i(String key) => (d[key] as num).toInt();

    return Match(
      id: doc.id,
      title: d['title'] as String,
      sportId: d['sportId'] as String,
      format: d['format'] as String,
      playersTotal: i('playersTotal'),
      slotsNeeded: i('slotsNeeded'),
      slotsFilled: i('slotsFilled'),
      isFull: d['isFull'] as bool,
      levelMin: i('levelMin'),
      levelMax: i('levelMax'),
      startAt: (d['startAt'] as Timestamp).toDate(),
      venue: Venue(name: venue['name'] as String, district: venue['district'] as String),
      geo: GeoPoint(point.latitude, point.longitude),
      district: d['district'] as String,
      costPerPerson: i('costPerPerson'),
      host: Host(displayName: host['displayName'] as String, rep: (host['rep'] as num).toDouble()),
    );
  }
}
