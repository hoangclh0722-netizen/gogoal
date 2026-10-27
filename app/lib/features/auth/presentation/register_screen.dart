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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _agreed = false;
  bool _showAgreeError = false;
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

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() => _showAgreeError = !_agreed);
    if (valid && _agreed) _run(() => ref.read(authRepositoryProvider).register(_email.text, _password.text));
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Tạo tài khoản',
      subtitle: 'Vào kèo cùng cộng đồng thể thao TP.HCM',
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
              validator: validatePassword,
            ),
            const SizedBox(height: 12),
            TextFormField(
              obscureText: _hidePassword,
              decoration: const InputDecoration(hintText: 'Nhập lại mật khẩu'),
              validator: (v) => v != _password.text ? 'Mật khẩu nhập lại không khớp' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() {
                _agreed = !_agreed;
                _showAgreeError = false;
              }),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() {
                      _agreed = v ?? false;
                      _showAgreeError = false;
                    }),
                  ),
                  const Expanded(
                    child: Text('Tôi đồng ý với Điều khoản sử dụng', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            if (_showAgreeError)
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 4),
                child: Text('Bạn cần đồng ý điều khoản để tiếp tục',
                    style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            if (_error != null) AuthErrorText(_error!),
            AppButton(label: _busy ? 'Đang tạo…' : 'Tạo tài khoản', onPressed: _busy ? null : _submit),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đã có tài khoản?', style: TextStyle(color: AppColors.muted)),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text('Đăng nhập',
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
