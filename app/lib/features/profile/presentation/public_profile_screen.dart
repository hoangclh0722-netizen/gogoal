import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/widgets/app_card.dart';
import '../../match/application/match_providers.dart';
import '../../rating/application/rating_providers.dart';
import '../application/profile_providers.dart';
import 'profile_avatar.dart';
import 'profile_screen.dart';

/// Hồ sơ người khác (UC16), mở khi bấm vào chủ kèo hoặc thành viên.
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(uid));
    final tags = ref.watch(tagCountsProvider(uid)).value;
    final hosted = ref.watch(hostedStatsProvider(uid)).value;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.primaryDark,
        foregroundColor: Colors.white,
        surfaceTintColor: context.colors.primaryDark,
        shape: const Border(),
        title: const Text('Hồ sơ người chơi', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text('Không tải được hồ sơ', style: TextStyle(color: context.colors.muted))),
        data: (p) {
          if (p == null) {
            return Center(child: Text('Người chơi này không còn trên GoGoal', style: TextStyle(color: context.colors.muted)));
          }
          final top = [...?tags?.entries.where((e) => e.value > 0)]..sort((a, b) => b.value.compareTo(a.value));
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Column(children: [
                ProfileAvatar(photoUrl: p.avatarUrl, name: p.displayName),
                const SizedBox(height: 8),
                Text(p.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${districtName(p.district)} · TP.HCM', style: TextStyle(color: context.colors.muted)),
                if (hosted != null && hosted.hosted > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    hosted.cancelled == 0
                        ? 'Đã tổ chức ${hosted.hosted} kèo'
                        : 'Đã tổ chức ${hosted.hosted} kèo · hủy ${hosted.cancelled}',
                    style: TextStyle(fontSize: 13, color: context.colors.muted),
                  ),
                ],
              ]),
              const SizedBox(height: 16),
              ReputationCard(profile: p),
              if (top.isNotEmpty) ...[
                const SizedBox(height: 10),
                AppCard(spacing: 0, children: [
                  const Text('Được khen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final e in top.take(3))
                      Chip(
                        label: Text('${e.key.label} · ${e.value}'),
                        backgroundColor: context.colors.primarySoft,
                        labelStyle: TextStyle(color: context.colors.primaryText, fontWeight: FontWeight.w600),
                        side: BorderSide.none,
                      ),
                  ]),
                ]),
              ],
              if (p.sports.isNotEmpty) ...[
                const SizedBox(height: 10),
                SportsCard(sports: p.sports),
              ],
            ],
          );
        },
      ),
    );
  }
}
