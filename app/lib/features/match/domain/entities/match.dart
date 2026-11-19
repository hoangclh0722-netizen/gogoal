import 'geo_point.dart';
import 'join_eligibility.dart';
import 'participant.dart';

enum MatchStatus { active, cancelled, hidden }

class Venue {
  const Venue({required this.name, required this.district, this.address = '', this.id = ''});

  /// Rỗng khi sân không nằm trong danh sách `venues`.
  final String id;
  final String name;
  final String district;
  final String address;
}

class Host {
  const Host({required this.displayName, required this.rep, this.avatarUrl});

  final String displayName;
  final double rep;
  final String? avatarUrl;
}

class Match {
  Match({
    required this.id,
    required this.title,
    required this.sportId,
    required this.format,
    required this.playersTotal,
    required this.slotsNeeded,
    required this.slotsFilled,
    required this.isFull,
    required this.levelMin,
    required this.levelMax,
    required this.startAt,
    DateTime? endAt,
    required this.venue,
    required this.geo,
    required this.district,
    required this.costTotal,
    required this.costPerPerson,
    required this.host,
    this.hostId = '',
    this.autoApprove = false,
    this.note,
    this.status = MatchStatus.active,
  }) : endAt = endAt ?? startAt.add(const Duration(hours: 2));

  final String id;
  final String title;
  final String sportId;
  final String format;
  final int playersTotal;
  final int slotsNeeded;
  final int slotsFilled;
  final bool isFull;
  final int levelMin;
  final int levelMax;
  final DateTime startAt;
  final DateTime endAt;
  final Venue venue;
  final GeoPoint geo;
  final String district;
  final int costTotal;
  final int costPerPerson;
  final Host host;
  final String hostId;
  final bool autoApprove;
  final String? note;
  final MatchStatus status;

  int get slotsLeft => slotsNeeded - slotsFilled;

  double? distanceFrom(GeoPoint? origin) => origin?.distanceTo(geo);

  /// BR03, BR04: người chơi [uid] có xin vào được không. Uy tín tối thiểu để giai đoạn 2.
  JoinEligibility checkEligibility({
    required String uid,
    required Map<String, int> sports,
    required ParticipantStatus? myStatus,
    required DateTime now,
  }) {
    if (status == MatchStatus.cancelled) return const MatchCancelled();
    if (!startAt.isAfter(now)) return const MatchStarted();
    if (hostId == uid) return const IsHost();
    if (myStatus != null) return AlreadyRequested(myStatus);
    if (isFull) return const MatchFull();
    final level = sports[sportId];
    if (level == null) return const SportNotInProfile();
    if (level < levelMin || level > levelMax) return LevelMismatch(level);
    return const Eligible();
  }
}

class VenueOption {
  const VenueOption({required this.id, required this.venue, required this.geo});

  final String id;
  final Venue venue;
  final GeoPoint geo;
}

/// Dữ liệu chủ kèo nhập ở màn Tạo kèo.
class MatchDraft {
  const MatchDraft({
    required this.title,
    required this.sportId,
    required this.format,
    required this.playersTotal,
    required this.slotsNeeded,
    required this.levelMin,
    required this.levelMax,
    required this.startAt,
    required this.endAt,
    required this.venue,
    required this.costTotal,
    required this.autoApprove,
    this.note,
  });

  final String title;
  final String sportId;
  final String format;
  final int playersTotal;
  final int slotsNeeded;
  final int levelMin;
  final int levelMax;
  final DateTime startAt;
  final DateTime endAt;
  final VenueOption venue;
  final int costTotal;
  final bool autoApprove;
  final String? note;

  // BR02: làm tròn lên nghìn đồng
  int get costPerPerson => (costTotal / playersTotal / 1000).ceil() * 1000;
}

enum MyRole { host, approved, pending }

/// Một dòng trong "Kèo của tôi": kèo kèm vai trò của mình trong kèo.
class MyMatch {
  const MyMatch(this.match, this.role);

  final Match match;
  final MyRole role;
}
