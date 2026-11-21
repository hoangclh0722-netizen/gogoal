import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../application/home_providers.dart';
import '../application/location_controller.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/home_filters.dart';
import 'widgets/home_header.dart';
import 'widgets/home_states.dart';
import 'widgets/match_card.dart';
import 'widgets/match_skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Lướt quá phần header xanh (logo, vị trí, ô tìm kiếm) thì hiện thanh thu gọn
  static const _compactAfter = 150.0;
  final _scroll = ScrollController();
  final _searchFocus = FocusNode();
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final compact = _scroll.offset > _compactAfter;
      if (compact != _compact) setState(() => _compact = compact);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _toTop() async {
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  Future<void> _search() async {
    await _toTop();
    if (mounted) _searchFocus.requestFocus();
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openLocked(BuildContext context, WidgetRef ref, String title) {
    if (title == 'Khám phá') {
      _toTop();
      return;
    }
    if (title == 'Hồ sơ') {
      requireLogin(context, ref, () => context.go(Routes.profile));
    } else if (title == 'Thông báo') {
      requireLogin(context, ref, () => context.go(Routes.notifications));
    } else if (title == 'Kèo của tôi') {
      requireLogin(context, ref, () => context.go(Routes.myMatches));
    } else if (title == 'Tạo kèo') {
      requireLogin(context, ref, () => context.push(Routes.createMatch));
    } else {
      requireLogin(context, ref, () => context.push(Routes.comingSoon, extra: title));
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(visibleMatchesProvider);
    final location = ref.watch(locationProvider);
    final filter = ref.watch(filterProvider);
    final hasPosition = location.position != null;

    return Scaffold(
      bottomNavigationBar: HomeBottomNav(
        onTap: (title) => _openLocked(context, ref, title),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
        onRefresh: () async => ref.refresh(loadedMatchesProvider.future),
        edgeOffset: 120,
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(
                onNotifications: () => _openLocked(context, ref, 'Thông báo'),
                onLogin: () => context.push(Routes.login),
                onFilter: () => _toast(context, 'Bộ lọc nâng cao sẽ có ở bước sau'),
                searchFocus: _searchFocus,
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
                        onTap: () => context.push(Routes.match(list[i].id)),
                        onJoin: () => context.push(Routes.match(list[i].id)),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_compact,
              child: AnimatedSlide(
                offset: _compact ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: HomeCompactBar(
                  onTop: _toTop,
                  onSearch: _search,
                  onNotifications: () => _openLocked(context, ref, 'Thông báo'),
                  onLogin: () => context.push(Routes.login),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
