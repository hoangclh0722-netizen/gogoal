import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_providers.dart';
import '../../match/application/match_providers.dart';
import '../../profile/presentation/profile_avatar.dart';
import '../application/rating_providers.dart';
import '../domain/rating.dart';

typedef _Target = ({String uid, String name, String? avatarUrl, bool isHost});

/// "GG! Đánh giá đồng đội" (UC15): chấm sao và thẻ cho những người có mặt khác.
class RateScreen extends ConsumerStatefulWidget {
  const RateScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends ConsumerState<RateScreen> {
  final _stars = <String, int>{};
  final _tags = <String, Set<RatingTag>>{};
  Set<String>? _rated;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid != null) {
      ref.read(ratingRepositoryProvider).ratedBy(widget.matchId, uid).then((s) {
        if (mounted) setState(() => _rated = s);
      }, onError: (_) {
        if (mounted) setState(() => _rated = const {});
      });
    }
  }

  Future<void> _submit(String uid) async {
    final drafts = [
      for (final MapEntry(key: to, value: stars) in _stars.entries)
        if (stars > 0) RatingDraft(toUid: to, stars: stars, tags: _tags[to] ?? const {}),
    ];
    if (drafts.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(ratingRepositoryProvider).submit(matchId: widget.matchId, fromUid: uid, ratings: drafts);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đã gửi ${drafts.length} đánh giá, cảm ơn bạn!')));
      context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không gửi được, thử lại')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final match = ref.watch(matchProvider(widget.matchId)).value;
    final members = ref.watch(membersProvider(widget.matchId)).value;
    final rated = _rated;

    Widget body;
    if (uid == null || match == null || members == null || rated == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final iAmPresent = uid == match.hostId || members.any((m) => m.uid == uid && m.attended == true);
      final targets = <_Target>[
        if (match.hostId != uid)
          (uid: match.hostId, name: match.host.displayName, avatarUrl: match.host.avatarUrl, isHost: true),
        for (final m in members)
          if (m.uid != uid && m.attended == true) (uid: m.uid, name: m.displayName, avatarUrl: m.avatarUrl, isHost: false),
      ].where((t) => !rated.contains(t.uid)).toList();

      if (!match.canRate(DateTime.now())) {
        body = const _Info('Đánh giá chỉ mở trong 48 giờ sau trận, sau khi chủ kèo điểm danh.');
      } else if (!iAmPresent) {
        body = const _Info('Bạn được tính vắng trong trận này nên không đánh giá được.');
      } else if (targets.isEmpty) {
        body = const _Info('Bạn đã đánh giá hết mọi người trong trận này rồi.');
      } else {
        final ready = _stars.values.any((s) => s > 0);
        body = Column(children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: targets.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return const Text('Chấm sao cho đồng đội đã đá cùng bạn. Người nào không muốn chấm thì bỏ qua.',
                      style: TextStyle(color: AppColors.muted));
                }
                final t = targets[i - 1];
                return _TargetCard(
                  target: t,
                  stars: _stars[t.uid] ?? 0,
                  tags: _tags[t.uid] ?? const {},
                  onStars: (s) => setState(() => _stars[t.uid] = s),
                  onTag: (tag) => setState(() {
                    final set = {...?_tags[t.uid]};
                    set.contains(tag) ? set.remove(tag) : set.add(tag);
                    _tags[t.uid] = set;
                  }),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: ready && !_sending ? () => _submit(uid) : null,
              child: Text(_sending ? 'Đang gửi…' : 'Gửi đánh giá'),
            ),
          ),
        ]);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GG! Đánh giá đồng đội', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: body,
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.target,
    required this.stars,
    required this.tags,
    required this.onStars,
    required this.onTag,
  });

  final _Target target;
  final int stars;
  final Set<RatingTag> tags;
  final ValueChanged<int> onStars;
  final ValueChanged<RatingTag> onTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ProfileAvatar(photoUrl: target.avatarUrl, name: target.name, radius: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(target.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            if (target.isHost) const Text('Chủ kèo', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            for (var s = 1; s <= 5; s++)
              IconButton(
                tooltip: '$s sao',
                onPressed: () => onStars(s == stars ? 0 : s),
                icon: Icon(s <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 32, color: s <= stars ? const Color(0xFFD97706) : AppColors.outline),
              ),
          ]),
          Wrap(spacing: 8, children: [
            for (final tag in RatingTag.values)
              FilterChip(
                label: Text(tag.label),
                selected: tags.contains(tag),
                onSelected: stars == 0 ? null : (_) => onTag(tag),
              ),
          ]),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.4)),
        ),
      );
}
