import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../../auth/application/auth_providers.dart';
import '../data/firestore_notification_repository.dart';
import '../domain/app_notification.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => FirestoreNotificationRepository(appFirestore));

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(authStateProvider.select((s) => s.value?.uid));
  if (uid == null) return Stream.value(const []);
  return ref.watch(notificationRepositoryProvider).watchMine(uid);
});

final unreadCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider.select((s) => s.value?.uid));
  if (uid == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).watchUnread(uid);
});
