import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/application/auth_providers.dart';
import '../../profile/domain/user_profile.dart';
import '../application/match_providers.dart';
import '../domain/entities/match.dart';
import '../domain/entities/participant.dart';

/// Trả về true khi đã gửi yêu cầu (hoặc đã vào kèo) thành công.
Future<bool?> showJoinSheet(BuildContext context, Match match, UserProfile profile) => showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => JoinSheet(match: match, profile: profile),
    );

class JoinSheet extends ConsumerStatefulWidget {
  const JoinSheet({super.key, required this.match, required this.profile});

  final Match match;
  final UserProfile profile;

  @override
  ConsumerState<JoinSheet> createState() => _JoinSheetState();
}

class _JoinSheetState extends ConsumerState<JoinSheet> {
  final _message = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final text = _message.text.trim();
    try {
      await ref.read(participantRepositoryProvider).requestJoin(
            match: widget.match,
            uid: user.uid,
            displayName: widget.profile.displayName,
            avatarUrl: widget.profile.avatarUrl,
            level: widget.profile.sports[widget.match.sportId]!,
            message: text.isEmpty ? null : text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on JoinException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = switch (e.error) {
          JoinError.full => 'Kèo vừa đủ người',
          JoinError.network => 'Không kết nối được, thử lại',
          JoinError.denied => 'Không gửi được, kèo vừa thay đổi. Hãy xem lại thông tin kèo',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    Widget line(IconData icon, String text) => Row(
          children: [
            Icon(icon, size: 16, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.muted))),
          ],
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Xin vào kèo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(m.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    line(Icons.calendar_today_outlined, formatTimeRange(m.startAt, m.endAt)),
                    line(Icons.place_outlined, m.venue.name),
                    line(Icons.payments_outlined, '${formatMoney(m.costPerPerson)} mỗi người'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Lời nhắn cho chủ kèo (không bắt buộc)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _message,
                maxLength: 200,
                maxLines: 3,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Ví dụ: Mình đi 2 người'),
              ),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Text(
                    m.autoApprove ? 'Kèo vào ngay, bạn có chỗ luôn' : 'Chủ kèo sẽ duyệt yêu cầu của bạn',
                    style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
              ],
              const SizedBox(height: 14),
              AppButton(
                label: _sending ? 'Đang gửi…' : (m.autoApprove ? 'Vào kèo' : 'Gửi yêu cầu'),
                kind: AppButtonKind.accent,
                onPressed: _sending ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
