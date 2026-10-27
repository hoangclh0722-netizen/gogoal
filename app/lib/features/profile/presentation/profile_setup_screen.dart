import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/district.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_providers.dart';
import '../../sport/domain/sport.dart';
import '../../sport/presentation/sport_style.dart';
import '../application/profile_providers.dart';
import '../domain/user_profile.dart';
import 'profile_avatar.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key, this.initial});

  final UserProfile? initial;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _name;
  late final String? _photoUrl;
  String? _district;
  late Map<String, int> _sports;
  int _step = 0;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    _name = TextEditingController(text: widget.initial?.displayName ?? user?.displayName ?? '')
      ..addListener(() => setState(() {}));
    _photoUrl = widget.initial?.avatarUrl ?? user?.photoUrl;
    _district = widget.initial?.district;
    _sports = {...?widget.initial?.sports};
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _stepOneDone {
    final n = _name.text.trim().length;
    return n >= 2 && n <= 40 && _district != null;
  }

  bool get _stepTwoDone => _sports.isNotEmpty && _sports.values.every((l) => l > 0);

  void _back() => _step == 1 ? setState(() => _step = 0) : context.pop(false);

  Future<void> _save() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(profileRepositoryProvider);
    try {
      final initial = widget.initial;
      if (initial == null) {
        await repo.create(UserProfile(
          uid: user.uid,
          displayName: _name.text.trim(),
          district: _district!,
          sports: _sports,
          avatarUrl: _photoUrl,
        ));
      } else {
        await repo.update(initial.copyWith(displayName: _name.text.trim(), district: _district, sports: _sports));
      }
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không lưu được hồ sơ, thử lại');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDistrict() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in districtCodes)
              ListTile(
                title: Text(districtName(c)),
                trailing: c == _district ? const Icon(Icons.check, color: AppColors.primaryDark) : null,
                onTap: () => Navigator.of(context).pop(c),
              ),
          ],
        ),
      ),
    );
    if (code != null) setState(() => _district = code);
  }

  void _toggleSport(String id) => setState(() {
        _sports.containsKey(id) ? _sports.remove(id) : _sports[id] = 0;
      });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step = 0);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
                    Text('Bước ${_step + 1}/2',
                        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: i <= _step ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                  child: _step == 0 ? _stepOne() : _stepTwo(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                child: Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    _step == 0
                        ? AppButton(
                            label: 'Tiếp tục',
                            onPressed: _stepOneDone ? () => setState(() => _step = 1) : null,
                          )
                        : AppButton(
                            label: _saving ? 'Đang lưu…' : 'Hoàn tất',
                            onPressed: _stepTwoDone && !_saving ? _save : null,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 15, color: AppColors.muted)),
        ],
      );

  Widget _stepOne() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Bạn là ai?', 'Tên và khu vực giúp người chơi khác nhận ra bạn.'),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                ProfileAvatar(photoUrl: _photoUrl, name: _name.text, radius: 48),
                if (_photoUrl != null) ...[
                  const SizedBox(height: 8),
                  const Text('Ảnh lấy từ tài khoản Google', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tên hiển thị', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _name, maxLength: 40, decoration: const InputDecoration(hintText: 'Ví dụ: Minh Nguyễn')),
          const SizedBox(height: 8),
          const Text('Quận/Huyện', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDistrict,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: const InputDecoration(suffixIcon: Icon(Icons.expand_more)),
              child: Text(
                _district == null ? 'Chọn quận/huyện' : districtName(_district!),
                style: TextStyle(color: _district == null ? AppColors.muted : AppColors.ink, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Dùng để gợi ý kèo gần bạn', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      );

  Widget _stepTwo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('Bạn chơi môn gì?', 'Chọn ít nhất 1 môn và trình độ của bạn ở môn đó.'),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 20) / 3;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in Sport.all) _SportTile(sport: s, width: w, selected: _sports.containsKey(s.id), onTap: () => _toggleSport(s.id)),
              ],
            );
          }),
          for (final s in Sport.all.where((s) => _sports.containsKey(s.id))) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(radius: 5, backgroundColor: s.color),
                const SizedBox(width: 8),
                Text('Trình độ ${s.displayName.toLowerCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            _LevelPicker(
              value: _sports[s.id]!,
              onChanged: (l) => setState(() => _sports[s.id] = l),
            ),
          ],
        ],
      );
}

class _SportTile extends StatelessWidget {
  const _SportTile({required this.sport, required this.width, required this.selected, required this.onTap});

  final Sport sport;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? sport.color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? sport.color : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: sport.color.withValues(alpha: selected ? 0.25 : 0.12),
              child: Icon(sport.icon, color: sport.color),
            ),
            const SizedBox(height: 6),
            Text(sport.displayName, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          for (var i = 0; i < skillLevels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i + 1),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == i + 1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: value == i + 1 ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))] : null,
                  ),
                  child: Text(
                    skillLevels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: value == i + 1 ? FontWeight.w700 : FontWeight.w500,
                      color: value == i + 1 ? AppColors.primaryDark : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
