import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_flow.dart';
import '../application/settings_controller.dart';

const _version = '1.0.0';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersOn = ref.watch(remindersOnProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _Section('Giao diện'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Sáng')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Tối')),
                ButtonSegment(value: ThemeMode.system, label: Text('Theo máy')),
              ],
              selected: {ref.watch(themeModeProvider)},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
          const _Section('Thông báo'),
          SwitchListTile(
            secondary: const Icon(Icons.alarm_outlined),
            title: const Text('Nhắc giờ kèo'),
            subtitle: const Text('Trước giờ đá 2 tiếng, trước hạn chốt 1 tiếng'),
            value: remindersOn,
            onChanged: (on) => ref.read(remindersOnProvider.notifier).set(on),
          ),
          const _Section('Khác'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Về GoGoal'),
            subtitle: const Text('Phiên bản $_version'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'GoGoal',
              applicationVersion: _version,
              applicationLegalese: 'Mã nguồn MIT · Biểu tượng Noto Emoji (Apache 2.0)',
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: context.colors.dangerText),
            title: Text('Đăng xuất', style: TextStyle(color: context.colors.dangerText)),
            onTap: () => confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: TextStyle(color: context.colors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
