import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../match/domain/entities/geo_point.dart';
import '../../../match/domain/entities/match.dart';
import '../../../sport/domain/sport.dart';
import '../../../sport/presentation/sport_style.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.origin,
    required this.onTap,
    required this.onJoin,
  });

  final Match match;
  final GeoPoint? origin;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final sport = Sport.fromId(match.sportId);
    final distance = match.distanceFrom(origin);

    return Opacity(
      opacity: match.isFull ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
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
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: sport.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(sport.icon, color: sport.color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  match.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (distance != null) ...[
                                const SizedBox(width: 8),
                                _DistanceBadge(formatDistance(distance)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${formatMatchTime(match.startAt, DateTime.now())} · ${match.venue.district}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _Pill(
                                formatLevelRange(match.levelMin, match.levelMax),
                                background: const Color(0xFFDBEAFE),
                                foreground: const Color(0xFF1D4ED8),
                              ),
                              _Pill(
                                match.isFull ? 'Đã đủ người' : 'Còn ${match.slotsLeft} chỗ',
                                background: match.isFull ? AppColors.border : AppColors.primarySoft,
                                foreground: match.isFull ? AppColors.muted : AppColors.primaryDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: sport.color.withValues(alpha: 0.2),
                                child: Text(
                                  match.host.displayName.characters.first.toUpperCase(),
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sport.color),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      match.host.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: AppColors.tennis),
                                        Text(
                                          match.host.rep.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: formatMoney(match.costPerPerson),
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                  children: const [
                                    TextSpan(
                                      text: '/người',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              AppButton(
                                label: match.isFull ? 'Đã đủ' : 'Xin vào',
                                kind: AppButtonKind.accent,
                                height: 40,
                                expand: false,
                                onPressed: match.isFull ? null : onJoin,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 13, color: AppColors.accent),
          const SizedBox(width: 2),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {required this.background, required this.foreground});

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground)),
    );
  }
}
