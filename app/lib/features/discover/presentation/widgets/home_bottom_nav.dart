import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notification/application/notification_providers.dart';

class HomeBottomNav extends ConsumerWidget {
  const HomeBottomNav({super.key, required this.onTap, this.active = 'Khám phá'});

  final void Function(String title) onTap;
  final String active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
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
                child: _Item(icon: Icons.event_note_outlined, label: 'Kèo của tôi', active: active == 'Kèo của tôi', onTap: () => onTap('Kèo của tôi')),
              ),
              Expanded(child: _CreateButton(onTap: () => onTap('Tạo kèo'))),
              Expanded(
                child: _Item(
                  icon: Icons.notifications_none,
                  label: 'Thông báo',
                  badge: unread,
                  active: active == 'Thông báo',
                  onTap: () => onTap('Thông báo'),
                ),
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
  const _Item({required this.icon, required this.label, this.active = false, this.badge = 0, this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? context.colors.primaryText : context.colors.muted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Badge(
            isLabelVisible: badge > 0,
            label: Text(badge > 9 ? '9+' : '$badge'),
            backgroundColor: context.colors.danger,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color),
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
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.colors.accentDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.accentDark.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 2),
                Text('Tạo kèo',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
