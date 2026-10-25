import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../application/auth_controller.dart';
import 'auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _busy = false;

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(signedInProvider.notifier).signIn();
    if (!mounted) return;
    context.canPop() ? context.pop(true) : context.go(Routes.home);
  }

  Future<void> _openRegister() async {
    final ok = await context.push<bool>(Routes.register);
    if (ok == true && mounted) context.pop(true);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) _signIn();
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
            SocialButtons(onGoogle: _signIn, onFacebook: _signIn),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
              validator: validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(Routes.comingSoon, extra: 'Quên mật khẩu'),
                child: const Text('Quên mật khẩu?',
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 4),
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
