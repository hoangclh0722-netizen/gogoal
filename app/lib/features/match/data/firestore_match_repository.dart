import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide GeoPoint;
import 'package:cloud_firestore/cloud_firestore.dart' as fs show GeoPoint;

import '../../notification/domain/app_notification.dart';
import '../domain/entities/geo_point.dart';
import '../domain/entities/match.dart';
import '../domain/entities/match_repository.dart';

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository(this._db, this._notifier);

  final FirebaseFirestore _db;
  final NotificationRepository _notifier;

  // Báo cho người trong kèo sau khi chủ kèo hủy/sửa/chốt; lỗi gửi không làm hỏng hành động chính
  void _notifyMembers(Match m, NotificationType type, List<String> statuses) {
    unawaited(() async {
      final snap = await _db.collection('matches').doc(m.id).collection('participants').where('status', whereIn: statuses).get();
      await _notifier.send(
        to: snap.docs.map((d) => d.id),
        type: type,
        matchId: m.id,
        matchTitle: m.title,
        actorId: m.hostId,
        actorName: m.host.displayName,
      );
    }()
        .catchError((_) {}));
  }

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
  Future<void> cancel(Match match, String reason) async {
    await _db.collection('matches').doc(match.id).update({
      'status': 'cancelled',
      'cancelReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
    _notifyMembers(match, NotificationType.matchCancelled, ['approved', 'pending']);
  }

  @override
  Future<({int hosted, int cancelled})> hostedStats(String uid) async {
    final mine = _db.collection('matches').where('hostId', isEqualTo: uid);
    // Rules không cho đọc kèo bị ẩn nên phải lọc status ngay trong truy vấn
    final [hosted, cancelled] = await Future.wait([
      mine.where('status', whereIn: ['active', 'cancelled']).count().get(),
      mine.where('status', isEqualTo: 'cancelled').count().get(),
    ]);
    return (hosted: hosted.count ?? 0, cancelled: cancelled.count ?? 0);
  }

  @override
  Future<List<MyMatch>> myMatches(String uid) async {
    final hosted = _db.collection('matches').where('hostId', isEqualTo: uid).get();
    final joined = _db.collectionGroup('participants').where('uid', isEqualTo: uid).get();
    final result = [
      for (final d in (await hosted).docs)
        if (d.data()['status'] != 'hidden') MyMatch(_toMatch(d), MyRole.host),
    ];

    final roles = {
      for (final p in (await joined).docs)
        if (p.data()['status'] case 'approved' || 'pending')
          p.reference.parent.parent!.id: p.data()['status'] == 'approved' ? MyRole.approved : MyRole.pending,
    };
    final docs = await Future.wait(roles.keys.map((id) async {
      try {
        return await _db.collection('matches').doc(id).get();
      } on FirebaseException {
        return null; // kèo bị ẩn
      }
    }));
    for (final d in docs) {
      if (d != null && d.exists) result.add(MyMatch(_toMatch(d), roles[d.id]!));
    }

    final have = result.map((m) => m.match.id).toSet();
    final watched = await _db.collection('users').doc(uid).collection('watching').get();
    final extra = await Future.wait(watched.docs.where((w) => !have.contains(w.id)).map((w) async {
      try {
        return await _db.collection('matches').doc(w.id).get();
      } on FirebaseException {
        return null;
      }
    }));
    for (final d in extra) {
      if (d != null && d.exists && d.data()!['status'] != 'hidden') result.add(MyMatch(_toMatch(d), MyRole.watching));
    }
    return result;
  }

  DocumentReference<Map<String, dynamic>> _watchRef(String uid, String matchId) =>
      _db.collection('users').doc(uid).collection('watching').doc(matchId);

  @override
  Stream<bool> watchIsWatching(String uid, String matchId) => _watchRef(uid, matchId).snapshots().map((d) => d.exists);

  @override
  Future<void> setWatching(String uid, Match match, bool on) {
    final ref = _watchRef(uid, match.id);
    final write = on
        ? ref.set({
            'matchId': match.id,
            'matchStartAt': Timestamp.fromDate(match.startAt),
            'createdAt': FieldValue.serverTimestamp(),
          })
        : ref.delete();
    return write.timeout(const Duration(seconds: 10));
  }

  @override
  Future<List<Match>> sameTime(Match m) async {
    const window = Duration(hours: 1);
    final snap = await _db
        .collection('matches')
        .where('status', isEqualTo: 'active')
        .where('sportId', isEqualTo: m.sportId)
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(m.startAt.subtract(window)))
        .where('startAt', isLessThanOrEqualTo: Timestamp.fromDate(m.startAt.add(window)))
        .orderBy('startAt')
        .limit(20)
        .get();
    final now = DateTime.now();
    return snap.docs
        .map(_toMatch)
        .where((x) => x.id != m.id && !x.isFull && !x.locked && !x.deadlinePassed(now) && x.startAt.isAfter(now))
        .toList();
  }

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
    return _db.collection('matches').doc(id).set({
      'hostId': hostId,
      'host': {'displayName': host.displayName, 'avatarUrl': host.avatarUrl, 'rep': host.rep},
      'sportId': m.sportId,
      'slotsFilled': 0,
      'isFull': false,
      'locked': false,
      ..._editable(m),
      'minReputation': null,
      'status': 'active',
      'cancelReason': null,
      'attendanceTakenAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
  }

  @override
  Future<void> setLocked(Match match, bool locked) async {
    final ref = _db.collection('matches').doc(match.id);
    final batch = _db.batch()..update(ref, {'locked': locked, 'updatedAt': FieldValue.serverTimestamp()});
    if (locked) {
      final pending = await ref.collection('participants').where('status', isEqualTo: 'pending').get();
      for (final p in pending.docs) {
        batch.update(p.reference, {'status': 'rejected', 'updatedAt': FieldValue.serverTimestamp()});
      }
    }
    await batch.commit().timeout(const Duration(seconds: 10));
    if (locked) _notifyMembers(match, NotificationType.matchLocked, ['approved']);
  }

  @override
  Future<void> update(Match old, MatchDraft m) async {
    await _db.collection('matches').doc(old.id).update({
      ..._editable(m),
      'isFull': old.slotsFilled >= m.slotsNeeded,
    }).timeout(const Duration(seconds: 10));
    final moved = old.startAt != m.startAt || old.endAt != m.endAt || old.venue.id != m.venue.id;
    if (moved) _notifyMembers(old, NotificationType.matchUpdated, ['approved']);
  }

  /// Các trường chủ kèo nhập, dùng chung cho tạo và sửa kèo.
  Map<String, Object?> _editable(MatchDraft m) {
    final v = m.venue;
    return {
      'title': m.title,
      'format': m.format,
      'playersTotal': m.playersTotal,
      'slotsNeeded': m.slotsNeeded,
      'slotsMin': m.slotsMin,
      'joinDeadline': m.joinDeadline == null ? null : Timestamp.fromDate(m.joinDeadline!),
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
      'note': m.note,
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
      levelMin: i('levelMin'),
      levelMax: i('levelMax'),
      startAt: (d['startAt'] as Timestamp).toDate(),
      endAt: (d['endAt'] as Timestamp).toDate(),
      venue: Venue(
        name: venue['name'] as String,
        district: venue['district'] as String,
        address: venue['address'] as String? ?? '',
        id: venue['venueId'] as String? ?? '',
      ),
      geo: GeoPoint(point.latitude, point.longitude),
      district: d['district'] as String,
      costTotal: i('costTotal'),
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
      locked: d['locked'] as bool? ?? false,
      joinDeadline: (d['joinDeadline'] as Timestamp?)?.toDate(),
      slotsMin: (d['slotsMin'] as num?)?.toInt(),
      attendanceTakenAt: (d['attendanceTakenAt'] as Timestamp?)?.toDate(),
    );
  }
}
