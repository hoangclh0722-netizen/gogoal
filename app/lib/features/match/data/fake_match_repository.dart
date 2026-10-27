import '../domain/entities/geo_point.dart';
import '../domain/entities/match.dart';
import '../domain/entities/match_repository.dart';

enum FakeScenario { normal, offline }

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({this.scenario = FakeScenario.normal, DateTime? now})
      : _now = now ?? DateTime.now();

  final FakeScenario scenario;
  final DateTime _now;

  @override
  Future<List<Match>> upcomingMatches({Duration within = const Duration(days: 7)}) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (scenario == FakeScenario.offline) throw Exception('offline');
    final limit = _now.add(within);
    return _seed().where((m) => m.startAt.isAfter(_now) && m.startAt.isBefore(limit)).toList();
  }

  DateTime _at(int dayOffset, int hour, [int minute = 0]) {
    final t = DateTime(_now.year, _now.month, _now.day + dayOffset, hour, minute);
    return t.isAfter(_now) ? t : _now.add(Duration(hours: 1 + hour % 3));
  }

  int get _daysToSaturday => (DateTime.saturday - _now.weekday + 7) % 7;

  List<Match> _seed() {
    final sat = _daysToSaturday;
    return [
      Match(
        id: 'm1', title: 'Đá bóng sân 7', sportId: 'football', format: '7v7',
        playersTotal: 14, slotsNeeded: 4, slotsFilled: 1, isFull: false,
        levelMin: 2, levelMax: 3, startAt: _at(0, 19),
        venue: const Venue(name: 'Sân Chảo Lửa', district: 'q1'),
        geo: const GeoPoint(10.7769, 106.7009), district: 'q1',
        costPerPerson: 60000, host: const Host(displayName: 'Minh', rep: 4.8),
      ),
      Match(
        id: 'm2', title: 'Cầu lông đôi nam nữ', sportId: 'badminton', format: 'doubles',
        playersTotal: 4, slotsNeeded: 2, slotsFilled: 0, isFull: false,
        levelMin: 2, levelMax: 4, startAt: _at(0, 20, 30),
        venue: const Venue(name: 'CLB Cầu lông Phú Nhuận', district: 'phu-nhuan'),
        geo: const GeoPoint(10.7993, 106.6803), district: 'phu-nhuan',
        costPerPerson: 45000, host: const Host(displayName: 'Lan', rep: 4.6),
      ),
      Match(
        id: 'm3', title: 'Đá bóng sân 5 giao lưu', sportId: 'football', format: '5v5',
        playersTotal: 10, slotsNeeded: 3, slotsFilled: 3, isFull: true,
        levelMin: 1, levelMax: 2, startAt: _at(0, 21),
        venue: const Venue(name: 'Sân Hoa Lư', district: 'q1'),
        geo: const GeoPoint(10.7897, 106.6962), district: 'q1',
        costPerPerson: 50000, host: const Host(displayName: 'Tuấn', rep: 4.2),
      ),
      Match(
        id: 'm4', title: 'Bóng rổ 3x3 sau giờ làm', sportId: 'basketball', format: '3v3',
        playersTotal: 6, slotsNeeded: 2, slotsFilled: 0, isFull: false,
        levelMin: 2, levelMax: 3, startAt: _at(1, 18),
        venue: const Venue(name: 'Sân bóng rổ Phú Thọ', district: 'q11'),
        geo: const GeoPoint(10.7656, 106.6620), district: 'q11',
        costPerPerson: 30000, host: const Host(displayName: 'Khoa', rep: 4.9),
      ),
      Match(
        id: 'm5', title: 'Pickleball vui vẻ', sportId: 'pickleball', format: 'doubles',
        playersTotal: 4, slotsNeeded: 2, slotsFilled: 1, isFull: false,
        levelMin: 1, levelMax: 2, startAt: _at(1, 19, 30),
        venue: const Venue(name: 'Pickleball Thảo Điền', district: 'thu-duc'),
        geo: const GeoPoint(10.8040, 106.7346), district: 'thu-duc',
        costPerPerson: 70000, host: const Host(displayName: 'Hà', rep: 4.7),
      ),
      Match(
        id: 'm6', title: 'Tennis đánh đơn', sportId: 'tennis', format: 'singles',
        playersTotal: 2, slotsNeeded: 1, slotsFilled: 0, isFull: false,
        levelMin: 3, levelMax: 4, startAt: _at(sat, 7),
        venue: const Venue(name: 'Sân Tennis Tao Đàn', district: 'q1'),
        geo: const GeoPoint(10.7740, 106.6930), district: 'q1',
        costPerPerson: 120000, host: const Host(displayName: 'Phong', rep: 4.5),
      ),
      Match(
        id: 'm7', title: 'Đá bóng sân 11 cuối tuần', sportId: 'football', format: '11v11',
        playersTotal: 22, slotsNeeded: 6, slotsFilled: 2, isFull: false,
        levelMin: 2, levelMax: 4, startAt: _at(sat, 16),
        venue: const Venue(name: 'Sân Thống Nhất', district: 'q10'),
        geo: const GeoPoint(10.7601, 106.6633), district: 'q10',
        costPerPerson: 40000, host: const Host(displayName: 'Dũng', rep: 4.4),
      ),
      Match(
        id: 'm8', title: 'Cầu lông sáng chủ nhật', sportId: 'badminton', format: 'doubles',
        playersTotal: 4, slotsNeeded: 2, slotsFilled: 1, isFull: false,
        levelMin: 1, levelMax: 3, startAt: _at(sat + 1, 8),
        venue: const Venue(name: 'Nhà thi đấu Bình Thạnh', district: 'binh-thanh'),
        geo: const GeoPoint(10.8106, 106.7091), district: 'binh-thanh',
        costPerPerson: 40000, host: const Host(displayName: 'Trang', rep: 4.3),
      ),
      Match(
        id: 'm9', title: 'Bóng rổ nửa sân', sportId: 'basketball', format: '5v5',
        playersTotal: 10, slotsNeeded: 4, slotsFilled: 2, isFull: false,
        levelMin: 3, levelMax: 4, startAt: _at(3, 19),
        venue: const Venue(name: 'CLB Bóng rổ Gò Vấp', district: 'go-vap'),
        geo: const GeoPoint(10.8387, 106.6652), district: 'go-vap',
        costPerPerson: 35000, host: const Host(displayName: 'Nam', rep: 4.1),
      ),
    ];
  }
}
