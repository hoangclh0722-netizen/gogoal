import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../auth/application/auth_providers.dart';
import '../../match/application/match_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../application/chat_providers.dart';
import '../domain/chat_message.dart';

/// Chat chung của một kèo: chủ kèo và thành viên đã được nhận (UC13).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.matchId});

  final String matchId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send(String uid) async {
    final text = _text.text.trim();
    if (text.isEmpty || _sending) return;
    final profile = await ref.read(myProfileProvider.future);
    if (profile == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatRepositoryProvider).send(matchId: widget.matchId, uid: uid, name: profile.displayName, text: text);
      _text.clear();
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
    final messages = ref.watch(messagesProvider(widget.matchId));
    // Mở tới 24 giờ sau giờ kết thúc, sau đó chỉ đọc (rules cũng chặn)
    final open = match != null && DateTime.now().isBefore(match.endAt.add(const Duration(hours: 24)));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match?.title ?? 'Chat kèo', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (match != null)
              Text(formatTimeRange(match.startAt, match.endAt),
                  style: TextStyle(fontSize: 12, color: context.colors.muted)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Chỉ chủ kèo và thành viên đã được nhận mới xem được chat',
                      textAlign: TextAlign.center, style: TextStyle(color: context.colors.muted)),
                ),
              ),
              data: (list) => list.isEmpty
                  ? Center(
                      child: Text('Chưa có tin nhắn. Chào mọi người đi!', style: TextStyle(color: context.colors.muted)),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final m = list[i];
                        // Danh sách đảo ngược: tin phía trên là i + 1
                        final above = i + 1 < list.length ? list[i + 1] : null;
                        return _Bubble(
                          message: m,
                          mine: m.senderId == uid,
                          showName: above?.senderId != m.senderId,
                        );
                      },
                    ),
            ),
          ),
          if (!open)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
              color: context.colors.surface,
              child: Text('Chat đã đóng sau 24 giờ kể từ khi kèo kết thúc',
                  textAlign: TextAlign.center, style: TextStyle(color: context.colors.muted)),
            )
          else
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 4, 8 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Nhắn cho cả kèo…', counterText: ''),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Gửi',
                    onPressed: uid == null || _sending || _text.text.trim().isEmpty ? null : () => _send(uid),
                    icon: const Icon(Icons.send_rounded),
                    color: context.colors.primaryText,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine, required this.showName});

  final ChatMessage message;
  final bool mine;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt;
    return Padding(
      padding: EdgeInsets.only(top: showName ? 10 : 3),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName && !mine)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 3),
              child: Text(message.senderName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.muted)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: mine ? context.colors.primaryDark : context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: mine ? null : Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(message.text,
                      style: TextStyle(fontSize: 15, height: 1.35, color: mine ? Colors.white : context.colors.ink)),
                  const SizedBox(height: 2),
                  Text(time == null ? 'Đang gửi…' : formatHm(time),
                      style: TextStyle(fontSize: 12, color: mine ? Colors.white : context.colors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
