import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../auth/application/auth_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/presentation/profile_avatar.dart';
import '../application/match_providers.dart';
import '../domain/entities/match.dart';
import '../domain/entities/participant.dart';

class ManageMatchScreen extends ConsumerStatefulWidget {
  const ManageMatchScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<ManageMatchScreen> createState() => _ManageMatchScreenState();
}

class _ManageMatchScreenState extends ConsumerState<ManageMatchScreen> {
  int _tab = 0;

  Future<void> _edit(Match match) async {
    final saved = await context.push<bool>(Routes.edit(match.id), extra: match);
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
    }
  }

  Future<void> _cancel(Match match) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => _CancelSheet(match: match),
    );
    if (done == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy kèo')));
      context.pop();
    }
  }

  Future<void> _remove(Match match, Member member) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFFEE2E2),
          child: Icon(Icons.person_remove_outlined, color: AppColors.danger),
        ),
        title: Text('Mời ${member.displayName} ra khỏi kèo?', textAlign: TextAlign.center),
        content: Text(
          '${member.displayName} sẽ không còn trong danh sách thành viên, kèo mở lại 1 chỗ.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
              ),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Mời ra'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(participantRepositoryProvider).remove(match: match, uid: member.uid);
    } on JoinException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(e.error == JoinError.network ? 'Không kết nối được, thử lại' : 'Không thực hiện được, thử lại'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchProvider(widget.matchId)).value;
    final uid = ref.watch(authStateProvider).value?.uid;
    if (match == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (uid != match.hostId) {
      return const Scaffold(body: Center(child: Text('Chỉ chủ kèo mới quản lý được kèo này')));
    }

    final requests = ref.watch(requestsProvider(match.id));
    final members = ref.watch(membersProvider(match.id)).value ?? const [];
    // Kèo đã bắt đầu hoặc đã hủy thì chỉ xem
    final editable = match.status == MatchStatus.active && match.startAt.isAfter(DateTime.now());

    return Scaffold(
      body: Column(
        children: [
          _Header(
            match: match,
            onEdit: editable ? () => _edit(match) : null,
            onCancel: editable ? () => _cancel(match) : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: _Tabs(
              index: _tab,
              counts: [requests.value?.length ?? 0, members.length + 1],
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: _tab == 0
                ? requests.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Center(child: Text('Không kết nối được, thử lại')),
                    data: (list) => list.isEmpty
                        ? const Center(
                            child: Text('Chưa có ai xin vào', style: TextStyle(color: AppColors.muted)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => _RequestCard(match: match, request: list[i], editable: editable),
                          ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _Card(
                        children: [
                          _MemberTile(name: '${match.host.displayName} (bạn)', avatarUrl: match.host.avatarUrl, tag: 'Chủ kèo', isHost: true),
                          for (final m in members)
                            _MemberTile(
                              name: m.displayName,
                              avatarUrl: m.avatarUrl,
                              tag: skillLevels[m.level - 1],
                              onRemove: editable ? () => _remove(match, m) : null,
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.match, this.onEdit, this.onCancel});

  final Match match;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.2),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Quản lý kèo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (onEdit != null) ...[
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Sửa', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
              ],
              if (onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Hủy kèo', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(match.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '${formatTimeRange(match.startAt, match.endAt)} · Đã nhận ${match.slotsFilled}/${match.slotsNeeded}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.counts, required this.onChanged});

  final int index;
  final List<int> counts;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Chờ duyệt', 'Thành viên'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (var i = 0; i < 2; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: i == index ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(labels[i],
                          style: TextStyle(
                            fontWeight: i == index ? FontWeight.w700 : FontWeight.w500,
                            color: i == index ? AppColors.ink : AppColors.muted,
                          )),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: i == index ? AppColors.accent : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${counts[i]}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: children),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.match, required this.request, required this.editable});

  final Match match;
  final JoinRequest request;
  final bool editable;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _busy = false;

  Future<void> _act(bool approve) async {
    setState(() => _busy = true);
    final repo = ref.read(participantRepositoryProvider);
    try {
      approve
          ? await repo.approve(match: widget.match, uid: widget.request.uid)
          : await repo.reject(match: widget.match, uid: widget.request.uid);
    } on JoinException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(switch (e.error) {
            JoinError.full => 'Kèo đã đủ người',
            JoinError.network => 'Không kết nối được, thử lại',
            JoinError.denied => 'Yêu cầu này vừa thay đổi',
          }),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final rep = ref.watch(profileProvider(r.uid)).value?.reputation;
    final full = widget.match.isFull;

    return _Card(children: [
      Row(
        children: [
          ProfileAvatar(photoUrl: r.avatarUrl, name: r.displayName, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(r.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    if (r.requestedAt != null)
                      Text(formatTimeAgo(r.requestedAt!, DateTime.now()),
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ),
                Row(
                  children: [
                    _Tag(skillLevels[r.level - 1]),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.tennis),
                    const SizedBox(width: 2),
                    Text(
                      rep == null ? 'Chưa có đánh giá' : rep.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: rep == null ? AppColors.muted : AppColors.ink,
                        fontWeight: rep == null ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      if (r.message != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Text('“${r.message}”', style: const TextStyle(fontSize: 13)),
        ),
      if (widget.editable)
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _act(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                child: const Text('Từ chối'),
              ),
            ),
            Expanded(
              child: FilledButton(
                onPressed: _busy || full ? null : () => _act(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.muted,
                ),
                child: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(full ? 'Đã đủ người' : 'Nhận'),
              ),
            ),
          ],
        ),
    ]);
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.name, required this.avatarUrl, required this.tag, this.isHost = false, this.onRemove});

  final String name;
  final String? avatarUrl;
  final String tag;
  final bool isHost;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(photoUrl: avatarUrl, name: name, radius: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(name,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        _Tag(tag, host: isHost),
        if (onRemove != null)
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger, visualDensity: VisualDensity.compact),
            child: const Text('Mời ra', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.host = false});

  final String text;
  final bool host;

  @override
  Widget build(BuildContext context) {
    final fg = host ? const Color(0xFFB45309) : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: host ? const Color(0xFFFEF3C7) : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (host) ...[Icon(Icons.workspace_premium_outlined, size: 13, color: fg), const SizedBox(width: 3)],
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _CancelSheet extends ConsumerStatefulWidget {
  const _CancelSheet({required this.match});

  final Match match;

  @override
  ConsumerState<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<_CancelSheet> {
  static const _reasons = ['Trời mưa', 'Không đủ người', 'Bận đột xuất', 'Sân có vấn đề', 'Khác'];

  final _other = TextEditingController();
  String? _picked;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  String get _reason => _picked == 'Khác' ? _other.text.trim() : _picked ?? '';

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(matchRepositoryProvider).cancel(widget.match.id, _reason);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = 'Không hủy được, thử lại';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              const Text('Hủy kèo này?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Text('Mọi người trong kèo sẽ thấy kèo đã bị hủy. Chọn lý do:',
                  style: TextStyle(color: AppColors.muted)),
              for (final r in _reasons)
                InkWell(
                  onTap: () => setState(() => _picked = r),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: r == _picked ? AppColors.primarySoft : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: r == _picked ? AppColors.primaryDark : AppColors.border,
                        width: r == _picked ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          r == _picked ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: r == _picked ? AppColors.primaryDark : AppColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Text(r, style: TextStyle(fontWeight: r == _picked ? FontWeight.w600 : FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              if (_picked == 'Khác')
                TextField(
                  controller: _other,
                  maxLength: 100,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Nhập lý do'),
                ),
              if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.danger)),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                      child: const Text('Giữ kèo'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _reason.isEmpty || _sending ? null : _send,
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 48), backgroundColor: AppColors.danger),
                      child: Text(_sending ? 'Đang hủy…' : 'Hủy kèo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
