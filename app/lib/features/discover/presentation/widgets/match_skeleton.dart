import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MatchSkeletonList extends StatefulWidget {
  const MatchSkeletonList({super.key});

  @override
  State<MatchSkeletonList> createState() => _MatchSkeletonListState();
}

class _MatchSkeletonListState extends State<MatchSkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) {
        final tone = Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _pulse.value)!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                _SkeletonCard(tone),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard(this.tone);

  final Color tone;

  Widget _bar(double? width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(6)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              const SizedBox(width: 12),
              Expanded(child: _bar(null, 16)),
              const SizedBox(width: 24),
              _bar(48, 20),
            ],
          ),
          const SizedBox(height: 14),
          _bar(180, 14),
          const SizedBox(height: 12),
          Row(children: [_bar(80, 22), const SizedBox(width: 8), _bar(70, 22)]),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(color: tone, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              _bar(70, 12),
              const Spacer(),
              _bar(88, 40),
            ],
          ),
        ],
      ),
    );
  }
}
