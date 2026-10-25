import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../match/domain/usecases/browse_matches.dart';
import '../../../sport/domain/sport.dart';
import '../../../sport/presentation/sport_style.dart';
import '../../application/home_providers.dart';

class HomeFilters extends ConsumerWidget {
  const HomeFilters({super.key});

  static const _timeLabels = {
    TimeFilter.today: 'Hôm nay',
    TimeFilter.tomorrow: 'Ngày mai',
    TimeFilter.weekend: 'Cuối tuần',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final controller = ref.read(filterProvider.notifier);

    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _SportChip(
                label: 'Tất cả',
                icon: Icons.apps,
                color: AppColors.primary,
                selected: filter.sportId == null,
                onTap: () => controller.setSport(null),
              ),
              for (final sport in Sport.all)
                _SportChip(
                  label: sport.displayName,
                  icon: sport.icon,
                  color: sport.color,
                  selected: filter.sportId == sport.id,
                  onTap: () => controller.setSport(sport.id),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final entry in _timeLabels.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TimeChip(
                    label: entry.value,
                    selected: filter.time == entry.key,
                    onTap: () => controller.toggleTime(entry.key),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 4),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : color.withValues(alpha: 0.14),
                border: selected ? Border.all(color: color.withValues(alpha: 0.35), width: 3) : null,
              ),
              child: Icon(icon, color: selected ? Colors.white : color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.ink : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primaryDark : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
