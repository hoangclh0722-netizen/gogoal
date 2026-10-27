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
  Future<void> signOut();
}
