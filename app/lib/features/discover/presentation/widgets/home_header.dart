import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/logo_wordmark.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/home_providers.dart';
import '../../application/location_controller.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.onSettings,
    required this.onLogin,
    required this.onFilter,
    this.searchFocus,
  });

  final VoidCallback onSettings;
  final VoidCallback onLogin;
  final VoidCallback onFilter;
  final FocusNode? searchFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(signedInProvider);
    final located = ref.watch(locationProvider).granted;

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 24),
      decoration: BoxDecoration(
        color: context.colors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LogoWordmark(size: 24),
                if (signedIn)
                  Tooltip(
                    message: 'Cài đặt',
                    child: InkWell(
                      onTap: onSettings,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: onLogin,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.colors.primaryDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Đăng nhập'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  located ? 'Gần tôi · Quận 1' : 'TP. Hồ Chí Minh',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    focusNode: searchFocus,
                    onChanged: ref.read(filterProvider.notifier).setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo sân, quận…',
                      prefixIcon: Icon(Icons.search, color: context.colors.muted),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  onTap: onFilter,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Thanh mảnh dính trên cùng khi đã lướt qua header: logo (về đầu trang), ô tìm kiếm, chuông.
class HomeCompactBar extends ConsumerWidget {
  const HomeCompactBar({super.key, required this.onTop, required this.onSearch, required this.onSettings, required this.onLogin});

  final VoidCallback onTop;
  final VoidCallback onSearch;
  final VoidCallback onSettings;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(signedInProvider);
    final query = ref.watch(filterProvider.select((f) => f.query));

    return Material(
      color: context.colors.primaryDark,
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 4, 8, 8),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Về đầu trang',
              excludeSemantics: true,
              child: InkWell(
                onTap: onTop,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: const SizedBox(
                  height: 48,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Center(child: LogoWordmark(size: 18)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Tìm kèo',
                excludeSemantics: true,
                child: InkWell(
                  onTap: onSearch,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(24)),
                    child: Row(children: [
                      Icon(Icons.search, color: context.colors.muted, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          query.isEmpty ? 'Tìm theo sân, quận…' : query,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: query.isEmpty ? context.colors.muted : context.colors.ink),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (signedIn)
              IconButton(
                tooltip: 'Cài đặt',
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              )
            else
              TextButton(
                onPressed: onLogin,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}
