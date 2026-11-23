import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../application/auth_providers.dart';
import '../domain/auth_repository.dart';
import 'auth_flow.dart';
import 'auth_shell.dart';

/// Gửi link đặt lại mật khẩu qua email. Không báo email có tồn tại hay không để tránh dò tài khoản.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  bool _busy = false;
  bool _sent = false;
  String? _error;
  int _wait = 0;
  Timer? _timer;

  @override
  void dispose() {
    _email.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy || _wait > 0 || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(_email.text);
      if (!mounted) return;
      setState(() {
        _sent = true;
        _wait = 60;
      });
      // Chặn bấm gửi lại liên tục
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || _wait <= 1) t.cancel();
        if (mounted) setState(() => _wait--);
      });
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = authMessage(e.error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AuthShell(
        title: 'Đã gửi email',
        subtitle: 'Kiểm tra hộp thư của bạn',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: context.colors.primarySoft,
                child: Icon(Icons.mark_email_read_outlined, size: 36, color: context.colors.primaryText),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nếu ${_email.text.trim()} đã đăng ký GoGoal, bạn sẽ nhận được link đặt lại mật khẩu trong vài phút. '
              'Nhớ kiểm tra cả thư mục Spam.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.muted, height: 1.45),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Về đăng nhập', onPressed: () => context.pop()),
            TextButton(
              onPressed: _wait > 0 || _busy ? null : _send,
              child: Text(_wait > 0 ? 'Gửi lại sau ${_wait}s' : 'Gửi lại email'),
            ),
          ],
        ),
      );
    }
    return AuthShell(
      title: 'Quên mật khẩu',
      subtitle: 'Nhập email đã đăng ký, GoGoal sẽ gửi link đặt lại mật khẩu',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofocus: widget.email == null || widget.email!.isEmpty,
              decoration: const InputDecoration(hintText: 'Email'),
              validator: validateEmail,
              onFieldSubmitted: (_) => _send(),
            ),
            const SizedBox(height: 16),
            if (_error != null) AuthErrorText(_error!),
            AppButton(label: _busy ? 'Đang gửi…' : 'Gửi link đặt lại', onPressed: _busy ? null : _send),
          ],
        ),
      ),
    );
  }
}
