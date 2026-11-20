import 'app_user.dart';

enum AuthError { wrongCredentials, emailInUse, invalidEmail, weakPassword, network, tooManyRequests, cancelled, unknown }

class AuthException implements Exception {
  const AuthException(this.error);

  final AuthError error;
}

abstract interface class AuthRepository {
  Stream<AppUser?> userChanges();
  AppUser? get currentUser;
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> register(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<void> sendEmailVerification();

  /// Gửi link đặt lại mật khẩu. Email chưa đăng ký cũng coi như gửi xong để không lộ tài khoản.
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
