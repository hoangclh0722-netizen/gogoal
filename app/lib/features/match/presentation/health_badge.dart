import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../domain/entities/match.dart';

class HealthBadge extends StatelessWidget {
  const HealthBadge(this.health, {super.key});

  final MatchHealth health;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (health) {
      MatchHealth.confirmed => ('Đã chốt', AppColors.primarySoft, AppColors.primaryDark),
      MatchHealth.recruiting => ('Đang tìm người', const Color(0xFFFEF9C3), const Color(0xFFA16207)),
      MatchHealth.atRisk => ('Có nguy cơ bể', AppColors.accentSoft, AppColors.accentDark),
      MatchHealth.cancelled => ('Bể', AppColors.dangerSoft, AppColors.dangerInk),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

/// "Còn thiếu 2 người · hạn chốt 20:00 hôm nay"
String? healthDetail(Match m, DateTime now) {
  final h = m.health(now);
  if (h != MatchHealth.recruiting && h != MatchHealth.atRisk) return null;
  final need = m.missing > 0 ? 'Còn thiếu ${m.missing} người' : 'Đủ tối thiểu, còn ${m.slotsLeft} chỗ';
  final d = m.joinDeadline;
  if (d == null) return need;
  return d.isAfter(now) ? '$need · chốt ${formatMatchTime(d, now)}' : '$need · đã qua hạn chốt';
}
