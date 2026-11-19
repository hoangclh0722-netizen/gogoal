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

  @override
  Stream<Match?> watchMatch(String id) async* {
    try {
      await for (final doc in _db.collection('matches').doc(id).snapshots()) {
        yield doc.exists && doc.data()!['status'] != 'hidden' ? _toMatch(doc) : null;
      }
    } on FirebaseException catch (e) {
      // Kèo bị ẩn thì rules chặn đọc
      if (e.code != 'permission-denied') rethrow;
      yield null;
    }
  }

  @override
  Future<void> cancel(String id, String reason) => _db.collection('matches').doc(id).update({
        'status': 'cancelled',
        'cancelReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));

  @override
  Future<List<VenueOption>> venues(String sportId) async {
    final snap = await _db.collection('venues').where('sportIds', arrayContains: sportId).get();
    final list = snap.docs.map((doc) {
      final d = doc.data();
      final point = (d['geo'] as Map<String, dynamic>)['geopoint'] as fs.GeoPoint;
      return VenueOption(
        id: doc.id,
        venue: Venue(name: d['name'] as String, district: d['district'] as String, address: d['address'] as String? ?? ''),
        geo: GeoPoint(point.latitude, point.longitude),
      );
    }).toList();
    return list..sort((a, b) => a.venue.name.compareTo(b.venue.name));
  }

  @override
  String newId() => _db.collection('matches').doc().id;

  @override
  Future<void> create(String id, MatchDraft m, {required String hostId, required Host host}) {
    final v = m.venue;
    return _db.collection('matches').doc(id).set({
      'hostId': hostId,
      'host': {'displayName': host.displayName, 'avatarUrl': host.avatarUrl, 'rep': host.rep},
      'title': m.title,
      'sportId': m.sportId,
      'format': m.format,
      'playersTotal': m.playersTotal,
      'slotsNeeded': m.slotsNeeded,
      'slotsFilled': 0,
      'isFull': false,
      'levelMin': m.levelMin,
      'levelMax': m.levelMax,
      'levels': [for (var l = m.levelMin; l <= m.levelMax; l++) l],
      'startAt': Timestamp.fromDate(m.startAt),
      'endAt': Timestamp.fromDate(m.endAt),
      'venue': {'venueId': v.id, 'name': v.venue.name, 'address': v.venue.address, 'district': v.venue.district},
      'geo': {'geohash': _geohash(v.geo.lat, v.geo.lng), 'geopoint': fs.GeoPoint(v.geo.lat, v.geo.lng)},
      'district': v.venue.district,
      'costTotal': m.costTotal,
      'costPerPerson': m.costPerPerson,
      'approvalMode': m.autoApprove ? 'auto' : 'manual',
      'minReputation': null,
      'note': m.note,
      'status': 'active',
      'cancelReason': null,
      'attendanceTakenAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
  }

  static String _geohash(double lat, double lng, [int length = 9]) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var latR = [-90.0, 90.0], lngR = [-180.0, 180.0];
    var hash = '', bit = 0, ch = 0, even = true;
    while (hash.length < length) {
      final r = even ? lngR : latR;
      final v = even ? lng : lat;
      final mid = (r[0] + r[1]) / 2;
      if (v >= mid) {
        ch |= 16 >> bit;
        r[0] = mid;
      } else {
        r[1] = mid;
      }
      even = !even;
      if (++bit == 5) {
        hash += base32[ch];
        bit = 0;
        ch = 0;
      }
    }
    return hash;
  }

  Match _toMatch(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
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
      endAt: (d['endAt'] as Timestamp?)?.toDate(),
      venue: Venue(
        name: venue['name'] as String,
        district: venue['district'] as String,
        address: venue['address'] as String? ?? '',
      ),
      geo: GeoPoint(point.latitude, point.longitude),
      district: d['district'] as String,
      costPerPerson: i('costPerPerson'),
      host: Host(
        displayName: host['displayName'] as String,
        rep: (host['rep'] as num).toDouble(),
        avatarUrl: host['avatarUrl'] as String?,
      ),
      hostId: d['hostId'] as String,
      autoApprove: d['approvalMode'] == 'auto',
      note: d['note'] as String?,
      status: MatchStatus.values.byName(d['status'] as String),
    );
  }
}
