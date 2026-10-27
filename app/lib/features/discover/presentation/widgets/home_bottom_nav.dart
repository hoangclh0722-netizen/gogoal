import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key, required this.onTap, this.active = 'Khám phá'});

  final void Function(String title) onTap;
  final String active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _Item(icon: Icons.explore, label: 'Khám phá', active: active == 'Khám phá', onTap: () => onTap('Khám phá')),
              ),
              Expanded(
                child: _Item(icon: Icons.event_note_outlined, label: 'Kèo của tôi', onTap: () => onTap('Kèo của tôi')),
              ),
              Expanded(child: _CreateButton(onTap: () => onTap('Tạo kèo'))),
              Expanded(
                child: _Item(icon: Icons.notifications_none, label: 'Thông báo', onTap: () => onTap('Thông báo')),
              ),
              Expanded(
                child: _Item(icon: Icons.person_outline, label: 'Hồ sơ', active: active == 'Hồ sơ', onTap: () => onTap('Hồ sơ')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, this.active = false, this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryDark : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -18,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 2),
                const Text('Tạo kèo',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
