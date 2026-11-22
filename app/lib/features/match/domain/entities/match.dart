import 'geo_point.dart';
import 'join_eligibility.dart';
import 'participant.dart';

enum MatchStatus { active, cancelled, hidden }

/// Tình trạng kèo trước giờ đá, tính từ dữ liệu hiện có (không lưu xuống Firestore).
enum MatchHealth { confirmed, recruiting, atRisk, cancelled }

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
    required this.levelMin,
    required this.levelMax,
    required this.startAt,
    required this.endAt,
    required this.venue,
    required this.geo,
    required this.district,
    required this.costTotal,
    required this.costPerPerson,
    required this.host,
    required this.hostId,
    this.autoApprove = false,
    this.note,
    this.status = MatchStatus.active,
    this.locked = false,
    this.joinDeadline,
    int? slotsMin,
    this.attendanceTakenAt,
  }) : slotsMin = slotsMin ?? slotsNeeded;

  final String id;
  final String title;
  final String sportId;
  final String format;
  final int playersTotal;
  final int slotsNeeded;
  final int slotsFilled;
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

  /// Chủ kèo đã chốt, không nhận thêm người.
  final bool locked;

  /// Qua mốc này kèo dừng nhận người; null là nhận tới giờ đá.
  final DateTime? joinDeadline;

  /// Cần ít nhất bấy nhiêu người qua app thì kèo mới đá được.
  final int slotsMin;

  int get missing => slotsMin - slotsFilled;

  /// null khi kèo đã bắt đầu.
  MatchHealth? health(DateTime now) {
    if (status == MatchStatus.cancelled) return MatchHealth.cancelled;
    if (!startAt.isAfter(now)) return null;
    if (locked || isFull) return MatchHealth.confirmed;
    if (missing <= 0) return MatchHealth.recruiting;
    // Chưa đủ tối thiểu mà sắp tới hạn chốt (hoặc sắp đá nếu không đặt hạn) thì báo nguy cơ bể
    final cutoff = joinDeadline ?? startAt;
    final warnBefore = joinDeadline != null ? const Duration(hours: 12) : const Duration(hours: 3);
    return cutoff.difference(now) < warnBefore ? MatchHealth.atRisk : MatchHealth.recruiting;
  }

  /// Thời điểm chủ kèo điểm danh; null là chưa điểm danh.
  final DateTime? attendanceTakenAt;

  /// BR09: chủ kèo điểm danh trong 24 giờ sau giờ kết thúc, một lần.
  bool canTakeAttendance(DateTime now) =>
      status == MatchStatus.active &&
      attendanceTakenAt == null &&
      now.isAfter(endAt) &&
      now.isBefore(endAt.add(const Duration(hours: 24)));

  /// BR10: đánh giá mở trong 48 giờ sau giờ kết thúc, sau khi đã điểm danh.
  bool canRate(DateTime now) =>
      status == MatchStatus.active &&
      attendanceTakenAt != null &&
      now.isAfter(endAt) &&
      now.isBefore(endAt.add(const Duration(hours: 48)));

  bool deadlinePassed(DateTime now) => joinDeadline != null && !now.isBefore(joinDeadline!);

  int get slotsLeft => slotsNeeded - slotsFilled;

  /// Firestore vẫn lưu isFull để truy vấn "còn chỗ", còn trong app thì tính từ số chỗ.
  bool get isFull => slotsFilled >= slotsNeeded;

  double? distanceFrom(GeoPoint? origin) => origin?.distanceTo(geo);

  /// BR03, BR04: người chơi [uid] có xin vào được không. Uy tín tối thiểu để giai đoạn 2.
  JoinEligibility checkEligibility({
    required String uid,
    required Map<String, int> sports,
    required ParticipantStatus? myStatus,
    required DateTime now,
  }) {
    if (status == MatchStatus.cancelled) return const MatchCancelled();
    // Chủ kèo và người đã trong kèo vẫn cần thao tác sau giờ đá (chat, điểm danh, đánh giá)
    if (hostId == uid) return const IsHost();
    if (myStatus != null) return AlreadyRequested(myStatus);
    if (!startAt.isAfter(now)) return const MatchStarted();
    if (locked) return const MatchLocked();
    if (deadlinePassed(now)) return const DeadlinePassed();
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
    required this.slotsMin,
    this.joinDeadline,
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
  final int slotsMin;
  final DateTime? joinDeadline;
  final String? note;

  // BR02: làm tròn lên nghìn đồng
  int get costPerPerson => (costTotal / playersTotal / 1000).ceil() * 1000;
}

enum MyRole { host, approved, pending, watching }

/// Một dòng trong "Kèo của tôi": kèo kèm vai trò của mình trong kèo.
class MyMatch {
  const MyMatch(this.match, this.role);

  final Match match;
  final MyRole role;
}
