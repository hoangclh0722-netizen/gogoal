import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../discover/presentation/widgets/home_bottom_nav.dart';
import '../../sport/domain/sport.dart';
import '../../sport/presentation/sport_style.dart';
import '../application/match_providers.dart';
import '../domain/entities/match.dart';
import 'health_badge.dart';

class MyMatchesScreen extends ConsumerStatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  ConsumerState<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends ConsumerState<MyMatchesScreen> {
  bool _past = false;

  void _onTab(String title) {
    switch (title) {
      case 'Khám phá':
        context.go(Routes.home);
      case 'Hồ sơ':
        context.go(Routes.profile);
      case 'Tạo kèo':
        _open(Routes.createMatch);
      case 'Thông báo':
        context.push(Routes.comingSoon, extra: title);
    }
  }

  // Quay lại từ chi tiết kèo (có thể vừa rời, vừa hủy) thì tải lại danh sách
  Future<void> _open(String route) async {
    await context.push(route);
    ref.invalidate(myMatchesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myMatchesProvider);
    final now = DateTime.now();
    final all = async.value ?? const <MyMatch>[];
    bool isWatch(MyMatch m) => m.role == MyRole.watching;
    final upcoming = all.where((m) => !isWatch(m) && m.match.endAt.isAfter(now)).toList()
      ..sort((a, b) => a.match.startAt.compareTo(b.match.startAt));
    final past = all.where((m) => !isWatch(m) && !m.match.endAt.isAfter(now)).toList()
      ..sort((a, b) => b.match.startAt.compareTo(a.match.startAt));
    // Kèo theo dõi chỉ có ý nghĩa trước giờ đá
    final watching = _past
        ? const <MyMatch>[]
        : (all.where((m) => isWatch(m) && m.match.startAt.isAfter(now)).toList()
          ..sort((a, b) => a.match.startAt.compareTo(b.match.startAt)));
    final list = _past ? past : upcoming;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: HomeBottomNav(active: 'Kèo của tôi', onTap: _onTab),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kèo của tôi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    _Segment(
                      label: upcoming.isEmpty ? 'Sắp tới' : 'Sắp tới · ${upcoming.length}',
                      selected: !_past,
                      onTap: () => setState(() => _past = false),
                    ),
                    _Segment(label: 'Đã qua', selected: _past, onTap: () => setState(() => _past = true)),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(myMatchesProvider.future),
              child: async.hasValue
                  ? list.isEmpty && watching.isEmpty
                      ? _Empty(
                          past: _past,
                          onFind: () => context.go(Routes.home),
                          onCreate: () => _open(Routes.createMatch),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            for (final m in list) ...[
                              _MyMatchCard(item: m, onTap: () => _open(Routes.match(m.match.id))),
                              const SizedBox(height: 12),
                            ],
                            if (watching.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(top: list.isEmpty ? 0 : 8, bottom: 10),
                                child: const Row(children: [
                                  Icon(Icons.star_rounded, size: 18, color: AppColors.tennis),
                                  SizedBox(width: 6),
                                  Text('Đang theo dõi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  SizedBox(width: 6),
                                  Text('· không chiếm chỗ', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                                ]),
                              ),
                              for (final m in watching) ...[
                                _MyMatchCard(item: m, onTap: () => _open(Routes.match(m.match.id))),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ],
                        )
                  : async.hasError
                      ? ListView(children: [
                          const SizedBox(height: 120),
                          const Center(
                            child: Text('Không tải được kèo của bạn', style: TextStyle(color: AppColors.muted)),
                          ),
                          Center(
                            child: TextButton(
                                onPressed: () => ref.invalidate(myMatchesProvider), child: const Text('Thử lại')),
                          ),
                        ])
                      : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primaryDark : Colors.white,
              )),
        ),
      ),
    );
  }
}

class _MyMatchCard extends StatelessWidget {
  const _MyMatchCard({required this.item, required this.onTap});

  final MyMatch item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = item.match;
    final sport = Sport.fromId(m.sportId);
    final cancelled = m.status == MatchStatus.cancelled;
    final now = DateTime.now();
    final health = m.health(now);
    final detail = healthDetail(m, now);
    final (label, bg, fg) = cancelled
        ? ('Đã hủy', const Color(0xFFFEE2E2), const Color(0xFFB91C1C))
        : switch (item.role) {
            MyRole.host => ('Chủ kèo', const Color(0xFFFEF3C7), const Color(0xFFB45309)),
            MyRole.approved => ('Đã vào', AppColors.primarySoft, AppColors.primaryDark),
            MyRole.pending => ('Chờ duyệt', const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
            MyRole.watching => ('Theo dõi', const Color(0xFFF1F5F9), AppColors.muted),
          };

    return Opacity(
      opacity: cancelled ? 0.6 : 1,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: sport.color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(m.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
                          ),
                        ]),
                        Row(children: [
                          const Icon(Icons.schedule, size: 16, color: AppColors.muted),
                          const SizedBox(width: 6),
                          Text(formatMatchTime(m.startAt, DateTime.now()),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                        Row(children: [
                          const Icon(Icons.place_outlined, size: 16, color: AppColors.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('${m.venue.name} · ${districtName(m.district)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                          ),
                          Text('${m.slotsFilled}/${m.slotsNeeded}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted)),
                        ]),
                        if (health != null && !cancelled)
                          Row(children: [
                            HealthBadge(health),
                            if (detail != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(detail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                              ),
                            ],
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.past, required this.onFind, required this.onCreate});

  final bool past;
  final VoidCallback onFind;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    // ListView để vẫn kéo xuống làm mới được khi trống
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 96, 32, 32),
      children: [
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primarySoft,
            child: const Icon(Icons.event_note_outlined, size: 32, color: AppColors.primaryDark),
          ),
        ),
        const SizedBox(height: 14),
        Text(past ? 'Chưa có kèo nào đã qua' : 'Chưa có kèo sắp tới',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Tìm kèo để xin vào, hoặc tự tạo kèo mời mọi người.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.muted)),
        if (!past) ...[
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            AppButton(label: 'Tìm kèo', kind: AppButtonKind.outline, height: 46, expand: false, onPressed: onFind),
            const SizedBox(width: 10),
            AppButton(label: 'Tạo kèo', kind: AppButtonKind.accent, height: 46, expand: false, onPressed: onCreate),
          ]),
        ],
      ],
    );
  }
}
