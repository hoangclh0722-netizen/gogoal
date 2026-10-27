import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/auth_flow.dart';
import '../../discover/presentation/widgets/home_bottom_nav.dart';
import '../../sport/domain/sport.dart';
import '../../sport/presentation/sport_style.dart';
import '../application/profile_providers.dart';
import '../domain/user_profile.dart';
import 'profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _toast(BuildContext context, String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFFEE2E2),
          child: Icon(Icons.logout, color: AppColors.danger),
        ),
        title: const Text('Đăng xuất khỏi GoGoal?', textAlign: TextAlign.center),
        content: const Text('Bạn sẽ cần đăng nhập lại để xin vào hoặc tạo kèo.', textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Đăng xuất'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(Routes.home);
  }

  void _onTab(BuildContext context, String title) {
    if (title == 'Hồ sơ') return;
    if (title == 'Khám phá') return context.go(Routes.home);
    context.push(Routes.comingSoon, extra: title);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(myProfileProvider);

    return Scaffold(
      bottomNavigationBar: HomeBottomNav(active: 'Hồ sơ', onTap: (t) => _onTab(context, t)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Không tải được hồ sơ', style: TextStyle(color: AppColors.muted))),
        data: (p) {
          if (user == null) return const SizedBox.shrink();
          if (p == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(label: 'Hoàn thành hồ sơ', onPressed: () => ensureProfile(context, ref)),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(profile: p),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user.needsEmailVerification) ...[
                      _VerifyBanner(onResend: () async {
                        await ref.read(authRepositoryProvider).sendEmailVerification();
                        if (context.mounted) _toast(context, 'Đã gửi lại email xác minh');
                      }),
                      const SizedBox(height: 10),
                    ],
                    _ReputationCard(profile: p),
                    const SizedBox(height: 10),
                    _SportsCard(sports: p.sports),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Sửa hồ sơ',
                      kind: AppButtonKind.outline,
                      height: 48,
                      onPressed: () => context.push(Routes.profileSetup, extra: p),
                    ),
                    TextButton(
                      onPressed: () => _signOut(context, ref),
                      child: const Text('Đăng xuất',
                          style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Hồ sơ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          ProfileAvatar(photoUrl: profile.avatarUrl, name: profile.displayName, onGreen: true),
          const SizedBox(height: 8),
          Text(profile.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text('${districtName(profile.district)} · TP.HCM',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifyBanner extends StatelessWidget {
  const _VerifyBanner({required this.onResend});

  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline, color: Color(0xFFB45309), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Chưa xác minh email', style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: onResend,
            child: const Text('Gửi lại', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _ReputationCard extends StatelessWidget {
  const _ReputationCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final rep = profile.reputation;
    return _Card(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Uy tín', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            Icon(Icons.star_rounded, size: 20, color: rep == null ? AppColors.border : AppColors.tennis),
            const SizedBox(width: 4),
            Text(rep == null ? 'Chưa có đánh giá' : rep.toStringAsFixed(1),
                style: TextStyle(
                  color: rep == null ? AppColors.muted : AppColors.ink,
                  fontWeight: rep == null ? FontWeight.w500 : FontWeight.w700,
                )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Stat(value: profile.matchesPlayed, label: 'Trận đã chơi'),
            const SizedBox(width: 8),
            _Stat(value: profile.noShows, label: 'Lần vắng'),
            const SizedBox(width: 8),
            _Stat(value: profile.ratingCount, label: 'Đánh giá'),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _SportsCard extends StatelessWidget {
  const _SportsCard({required this.sports});

  final Map<String, int> sports;

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        const Text('Môn chơi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        for (final s in Sport.all.where((s) => sports.containsKey(s.id))) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(s.icon, color: s.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(s.displayName, style: const TextStyle(fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                child: Text(skillLevels[sports[s.id]! - 1],
                    style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
