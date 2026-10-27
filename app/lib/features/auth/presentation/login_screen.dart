import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../application/auth_providers.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_flow.dart';
import 'auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<AppUser> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      final ok = await ensureProfile(context, ref);
      if (!mounted) return;
      context.canPop() ? context.pop(ok) : context.go(Routes.home);
    } on AuthException catch (e) {
      if (mounted && e.error != AuthError.cancelled) setState(() => _error = authMessage(e.error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _google() => _run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  void _facebook() => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('Đăng nhập Facebook sắp có')));

  Future<void> _openRegister() async {
    final ok = await context.push<bool>(Routes.register);
    if (ok == true && mounted) context.pop(true);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _run(() => ref.read(authRepositoryProvider).signInWithEmail(_email.text, _password.text));
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Chào mừng đến GoGoal',
      subtitle: 'Đăng nhập để lên kèo',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SocialButtons(onGoogle: _google, onFacebook: _facebook),
            const SizedBox(height: 20),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
              validator: validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                hintText: 'Mật khẩu',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.muted,
                  ),
                ),
              ),
              validator: validateRequired,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(Routes.comingSoon, extra: 'Quên mật khẩu'),
                child: const Text('Quên mật khẩu?',
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 4),
            if (_error != null) AuthErrorText(_error!),
            AppButton(label: _busy ? 'Đang đăng nhập…' : 'Đăng nhập', onPressed: _busy ? null : _submit),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản?', style: TextStyle(color: AppColors.muted)),
                GestureDetector(
                  onTap: _openRegister,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text('Đăng ký',
                        style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
