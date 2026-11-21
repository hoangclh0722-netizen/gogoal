import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/router/app_router.dart';
import '../../../core/utils/format.dart';
import '../domain/entities/match.dart';
import 'match_providers.dart';

const _beforeStart = Duration(hours: 2);
const _beforeDeadline = Duration(hours: 1);

/// Nhắc giờ ngay trên máy, không cần server: mỗi lần danh sách "Kèo của tôi" thay đổi thì hẹn lại toàn bộ.
class MatchReminders {
  MatchReminders(this._onOpen);

  final void Function(String matchId) _onOpen;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'match_reminders',
      'Nhắc giờ kèo',
      channelDescription: 'Nhắc trước giờ đá và trước hạn chốt người',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) _onOpen(r.payload!);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    // App đang tắt mà người dùng bấm vào nhắc giờ thì mở thẳng kèo đó
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) && payload != null) _onOpen(payload);
    _ready = true;
  }

  Future<void> sync(List<MyMatch> mine) async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
    final now = DateTime.now();
    for (final (i, item) in mine.indexed) {
      final m = item.match;
      if (m.status != MatchStatus.active || item.role == MyRole.pending || item.role == MyRole.watching) continue;
      await _at(
        id: i * 2,
        when: m.startAt.subtract(_beforeStart),
        now: now,
        title: 'Còn 2 tiếng nữa tới kèo',
        body: '${m.title} lúc ${formatHm(m.startAt)} tại ${m.venue.name}',
        matchId: m.id,
      );
      if (item.role == MyRole.host && m.attendanceTakenAt == null) {
        await _at(
          id: 100000 + i,
          when: m.endAt,
          now: now,
          title: 'Điểm danh trận vừa rồi',
          body: '${m.title}: đánh dấu ai vắng trong 24 giờ để tính uy tín',
          matchId: m.id,
        );
      }
      final deadline = m.joinDeadline;
      if (item.role == MyRole.host && deadline != null && !m.locked) {
        await _at(
          id: i * 2 + 1,
          when: deadline.subtract(_beforeDeadline),
          now: now,
          title: 'Sắp tới hạn chốt người',
          body: '${m.title}: còn 1 tiếng, đang có ${m.slotsFilled}/${m.slotsNeeded} người',
          matchId: m.id,
        );
      }
    }
  }

  Future<void> _at({
    required int id,
    required DateTime when,
    required DateTime now,
    required String title,
    required String body,
    required String matchId,
  }) async {
    if (!when.isAfter(now)) return;
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
      payload: matchId,
    );
  }
}

/// Đặt ở gốc app: theo dõi "Kèo của tôi" và hẹn lại nhắc giờ khi danh sách đổi.
final matchRemindersProvider = Provider<void>((ref) {
  if (kIsWeb) return;
  final reminders = MatchReminders((id) => ref.read(routerProvider).push(Routes.match(id)));
  ref.listen(myMatchesProvider, (_, next) {
    final mine = next.value;
    if (mine != null) reminders.sync(mine).catchError((_) {});
  }, fireImmediately: true);
});
