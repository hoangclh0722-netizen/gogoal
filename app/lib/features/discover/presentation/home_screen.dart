import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../match/domain/entities/match.dart';
import '../application/home_providers.dart';
import '../application/location_controller.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/home_filters.dart';
import 'widgets/home_header.dart';
import 'widgets/home_states.dart';
import 'widgets/match_card.dart';
import 'widgets/match_skeleton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openLocked(BuildContext context, WidgetRef ref, String title) {
    requireLogin(context, ref, () => context.push(Routes.comingSoon, extra: title));
  }

  void _requestJoin(BuildContext context, WidgetRef ref, Match match) {
    requireLogin(context, ref, () => _toast(context, 'Đã gửi yêu cầu vào "${match.title}"'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(visibleMatchesProvider);
    final location = ref.watch(locationProvider);
    final filter = ref.watch(filterProvider);
    final hasPosition = location.position != null;

    return Scaffold(
      bottomNavigationBar: HomeBottomNav(
        onTap: (title) => _openLocked(context, ref, title),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(loadedMatchesProvider.future),
        edgeOffset: 120,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(
                onNotifications: () => _openLocked(context, ref, 'Thông báo'),
                onLogin: () => context.push(Routes.login),
                onFilter: () => _toast(context, 'Bộ lọc nâng cao sẽ có ở bước sau'),
              ),
            ),
            const SliverToBoxAdapter(child: HomeFilters()),
            if (!location.granted)
              SliverToBoxAdapter(
                child: LocationBanner(onEnable: () => ref.read(locationProvider.notifier).enable()),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasPosition ? 'Kèo gần bạn' : 'Kèo sắp diễn ra',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      hasPosition ? 'Sắp xếp: Gần nhất' : 'Sắp xếp: Sớm nhất',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            ...matches.when(
              loading: () => [const SliverToBoxAdapter(child: MatchSkeletonList())],
              error: (_, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: OfflineView(onRetry: () => ref.invalidate(loadedMatchesProvider)),
                ),
              ],
              data: (list) {
                if (list.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        onCreate: () => _openLocked(context, ref, 'Tạo kèo'),
                        onClear: filter.isActive ? () => ref.read(filterProvider.notifier).clear() : null,
                      ),
                    ),
                  ];
                }
                return [
                  SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MatchCard(
                        match: list[i],
                        origin: location.position,
                        onTap: () => context.push(Routes.comingSoon, extra: list[i].title),
                        onJoin: () => _requestJoin(context, ref, list[i]),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Bạn đã xem hết', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                      ),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
