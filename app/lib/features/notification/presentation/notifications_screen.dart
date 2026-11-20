import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../auth/application/auth_providers.dart';
import '../../discover/presentation/widgets/home_bottom_nav.dart';
import '../application/notification_providers.dart';
import '../domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _onTab(BuildContext context, String title) {
    switch (title) {
      case 'Khám phá':
        context.go(Routes.home);
      case 'Kèo của tôi':
        context.go(Routes.myMatches);
      case 'Hồ sơ':
        context.go(Routes.profile);
      case 'Tạo kèo':
        context.push(Routes.createMatch);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final repo = ref.read(notificationRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: HomeBottomNav(active: 'Thông báo', onTap: (t) => _onTab(context, t)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 12, 8, 16),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Thông báo',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                if (uid != null && unread > 0)
                  TextButton(
                    onPressed: () => repo.markAllRead(uid),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Đọc hết', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('Không tải được thông báo', style: TextStyle(color: AppColors.muted)),
              ),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.muted),
                        SizedBox(height: 8),
                        Text('Chưa có thông báo nào', style: TextStyle(color: AppColors.muted)),
                      ]),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                      itemBuilder: (_, i) => _Tile(
                        n: list[i],
                        onTap: () {
                          if (uid != null && !list[i].read) repo.markRead(uid, list[i].id);
                          context.push(Routes.match(list[i].matchId));
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.n, required this.onTap});

  final AppNotification n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (n.type) {
      NotificationType.joinRequested => (Icons.person_add_alt_1_rounded, AppColors.badminton),
      NotificationType.memberJoined || NotificationType.joinApproved => (Icons.check_circle_rounded, AppColors.primaryDark),
      NotificationType.matchLocked => (Icons.lock_rounded, AppColors.primaryDark),
      NotificationType.joinRejected || NotificationType.removed => (Icons.block_rounded, AppColors.muted),
      NotificationType.memberLeft => (Icons.logout_rounded, AppColors.warning),
      NotificationType.matchCancelled => (Icons.event_busy_rounded, AppColors.danger),
      NotificationType.matchUpdated => (Icons.edit_calendar_rounded, AppColors.accent),
    };
    return Material(
      color: n.read ? Colors.transparent : AppColors.primarySoft.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.text,
                        style: TextStyle(fontSize: 14, fontWeight: n.read ? FontWeight.w400 : FontWeight.w600, height: 1.35)),
                    const SizedBox(height: 4),
                    Text(n.createdAt == null ? 'Vừa xong' : formatTimeAgo(n.createdAt!, DateTime.now()),
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              if (!n.read)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 8),
                  child: CircleAvatar(radius: 4, backgroundColor: AppColors.primaryDark),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
