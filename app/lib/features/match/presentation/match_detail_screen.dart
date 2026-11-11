import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/auth_flow.dart';
import '../../discover/application/location_controller.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/presentation/profile_avatar.dart';
import '../../sport/domain/sport.dart';
import '../../sport/presentation/sport_style.dart';
import '../application/match_providers.dart';
import '../domain/entities/join_eligibility.dart';
import '../domain/entities/match.dart';
import '../domain/entities/participant.dart';
import 'join_sheet.dart';

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchProvider(matchId));
    return Scaffold(
      body: match.when(
        loading: () => const _Skeleton(),
        error: (_, _) => _Message(
          icon: Icons.wifi_off_rounded,
          text: 'Không kết nối được',
          action: 'Thử lại',
          onTap: () => ref.invalidate(matchProvider(matchId)),
        ),
        data: (m) => m == null
            ? _Message(
                icon: Icons.event_busy_rounded,
                text: 'Kèo này không còn',
                action: 'Về trang chủ',
                onTap: () => context.go(Routes.home),
              )
            : _Detail(match: m),
      ),
    );
  }
}

void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(Routes.home);

class _Detail extends ConsumerWidget {
  const _Detail({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sport = Sport.fromId(match.sportId);
    final distance = match.distanceFrom(ref.watch(locationProvider).position);
    final place = [
      if (match.venue.address.isNotEmpty) match.venue.address,
      districtName(match.district),
    ].join(', ');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(match: match, sport: sport),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (match.status == MatchStatus.cancelled) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Text('Kèo đã bị hủy',
                            style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _Card(children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Thời gian',
                        value: formatTimeRange(match.startAt, match.endAt),
                      ),
                      _InfoRow(
                        icon: Icons.place_outlined,
                        label: 'Địa điểm',
                        value: match.venue.name,
                        sub: distance == null ? place : '$place · ${formatDistance(distance)}',
                        below: OutlinedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse('https://www.google.com/maps/dir/?api=1'
                                '&destination=${match.geo.lat},${match.geo.lng}'),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.near_me_outlined, size: 18),
                          label: const Text('Chỉ đường'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          ),
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.bar_chart_rounded,
                        label: 'Trình độ',
                        value: formatLevelRange(match.levelMin, match.levelMax),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _SlotsCard(match: match),
                    const SizedBox(height: 12),
                    _Card(children: [
                      Row(
                        children: [
                          ProfileAvatar(photoUrl: match.host.avatarUrl, name: match.host.displayName, radius: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(match.host.displayName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                const Text('Chủ kèo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.tennis),
                          const SizedBox(width: 4),
                          Text(match.host.rep.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ]),
                    if (match.note != null) ...[
                      const SizedBox(height: 12),
                      _Card(children: [
                        const Text('Ghi chú của chủ kèo', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(match.note!, style: const TextStyle(color: AppColors.muted, height: 1.4)),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _ActionBar(match: match),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.match, required this.sport});

  final Match match;
  final Sport sport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => _back(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(sport.icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(sport.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(match.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '${formatLabel(match.format)} · ${match.playersTotal} người · '
            '${match.autoApprove ? 'Vào ngay' : 'Chủ kèo duyệt'}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.sub, this.below});

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primaryDark, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (sub != null) Text(sub!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              if (below != null) ...[const SizedBox(height: 4), below!],
            ],
          ),
        ),
      ],
    );
  }
}

class _SlotsCard extends StatelessWidget {
  const _SlotsCard({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return _Card(children: [
      Row(
        children: [
          Expanded(
            child: Text(
              match.isFull ? 'Đã đủ người' : 'Còn ${match.slotsLeft} chỗ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: match.isFull ? AppColors.muted : AppColors.ink,
              ),
            ),
          ),
          Text('Đã nhận ${match.slotsFilled}/${match.slotsNeeded}',
              style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: match.slotsFilled / match.slotsNeeded,
          minHeight: 8,
          color: AppColors.primary,
          backgroundColor: AppColors.border,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${match.slotsFilled + 1} người trong kèo',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Text('Chỉ thành viên trong kèo xem được danh sách',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.match});

  final Match match;

  void _toast(BuildContext context, String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(myProfileProvider);
    final status = ref.watch(myParticipationProvider(match.id));
    if (user != null && (!profile.hasValue || !status.hasValue)) return const SizedBox(height: 96);

    Widget? note;
    Widget? main;
    var showPrice = true;
    void soon() => _toast(context, 'Sắp có');

    final eligibility = match.checkEligibility(
      uid: user?.uid ?? '',
      sports: profile.value?.sports ?? const {},
      myStatus: status.value,
      now: DateTime.now(),
    );
    switch (eligibility) {
      case MatchCancelled():
        return const SizedBox.shrink();
      case MatchStarted():
        main = const AppButton(label: 'Kèo đã bắt đầu', onPressed: null);
      case _ when user == null:
        main = AppButton(label: 'Đăng nhập để tham gia', onPressed: () => requireLogin(context, ref, () {}));
      case _ when profile.value == null:
        main = AppButton(label: 'Hoàn thành hồ sơ', onPressed: () => ensureProfile(context, ref));
      case IsHost():
        showPrice = false;
        note = const _Status(Icons.workspace_premium_outlined, AppColors.warning, 'Kèo của bạn');
        main = AppButton(
          label: 'Quản lý kèo',
          onPressed: () => context.push(Routes.comingSoon, extra: 'Quản lý kèo'),
        );
      case AlreadyRequested(status: ParticipantStatus.pending):
        showPrice = false;
        note = const _Status(Icons.schedule, AppColors.warning, 'Đang chờ chủ kèo duyệt');
        main = AppButton(label: 'Hủy yêu cầu', kind: AppButtonKind.outline, onPressed: soon);
      case AlreadyRequested(status: ParticipantStatus.approved):
        showPrice = false;
        note = const _Status(Icons.check_circle_outline, AppColors.primaryDark, 'Bạn đã ở trong kèo');
        main = Column(
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(child: AppButton(label: 'Thanh toán', kind: AppButtonKind.outline, height: 48, onPressed: soon)),
                Expanded(child: AppButton(label: 'Chat', kind: AppButtonKind.outline, height: 48, onPressed: soon)),
              ],
            ),
            TextButton(
              onPressed: soon,
              child: const Text('Rời kèo',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ],
        );
      case AlreadyRequested(:final status):
        showPrice = false;
        note = _Status(Icons.info_outline, AppColors.muted, switch (status) {
          ParticipantStatus.rejected => 'Chủ kèo đã từ chối yêu cầu',
          ParticipantStatus.removed => 'Bạn đã bị mời ra khỏi kèo',
          _ => 'Bạn đã rời kèo',
        });
      case MatchFull():
        main = const AppButton(label: 'Đã đủ người', onPressed: null);
      case SportNotInProfile():
        note = _Status(Icons.info_outline, AppColors.muted,
            'Bạn chưa chọn môn ${Sport.fromId(match.sportId).displayName.toLowerCase()} trong hồ sơ');
        main = const AppButton(label: 'Xin vào', onPressed: null);
      case LevelMismatch(:final myLevel):
        note = _Status(Icons.info_outline, AppColors.muted,
            'Kèo dành cho ${formatLevelRange(match.levelMin, match.levelMax)}, bạn đang là ${skillLevels[myLevel - 1]}');
        main = const AppButton(label: 'Xin vào', onPressed: null);
      case Eligible():
        main = AppButton(
          label: 'Xin vào',
          kind: AppButtonKind.accent,
          onPressed: () async {
            final ok = await showJoinSheet(context, match, profile.value!);
            if (ok == true && context.mounted) {
              _toast(context, match.autoApprove ? 'Bạn đã vào kèo' : 'Đã gửi yêu cầu, chờ chủ kèo duyệt');
            }
          },
        );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          ?note,
          if (main != null)
            showPrice
                ? Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatMoney(match.costPerPerson),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const Text('mỗi người', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: main),
                    ],
                  )
                : main,
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.icon, this.color, this.text);

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, required this.action, required this.onTap});

  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(onPressed: () => _back(context), icon: const Icon(Icons.arrow_back)),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 56, color: AppColors.muted),
                    const SizedBox(height: 12),
                    Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    AppButton(label: action, expand: false, onPressed: onTap),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget box(double h) => Container(
          height: h,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(16)),
        );
    return Column(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        box(170),
        box(110),
        box(72),
      ],
    );
  }
}
