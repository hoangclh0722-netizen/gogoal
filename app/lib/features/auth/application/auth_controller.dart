import 'package:flutter_riverpod/flutter_riverpod.dart';

// Chưa nối Firebase: đăng nhập chỉ đổi cờ trong bộ nhớ.
class AuthController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> signIn() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = true;
  }
}

final signedInProvider = NotifierProvider<AuthController, bool>(AuthController.new);
