import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;
  bool _googleReady = false;

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<AppUser> signInWithEmail(String email, String password) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  @override
  Future<AppUser> register(String email, String password) => _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        await cred.user?.sendEmailVerification();
        return cred;
      });

  @override
  Future<AppUser> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize();
      _googleReady = true;
    }
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      throw AuthException(e.code == GoogleSignInExceptionCode.canceled ? AuthError.cancelled : AuthError.unknown);
    }
    final idToken = account.authentication.idToken;
    return _guard(() => _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken)));
  }

  @override
  Future<void> sendEmailVerification() async => _auth.currentUser?.sendEmailVerification();

  @override
  Future<void> signOut() async {
    if (_googleReady) await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<AppUser> _guard(Future<UserCredential> Function() action) async {
    try {
      final cred = await action();
      return _toAppUser(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_map(e.code));
    }
  }

  static AuthError _map(String code) => switch (code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-login-credentials' =>
          AuthError.wrongCredentials,
        'email-already-in-use' || 'account-exists-with-different-credential' => AuthError.emailInUse,
        'invalid-email' => AuthError.invalidEmail,
        'weak-password' => AuthError.weakPassword,
        'network-request-failed' => AuthError.network,
        'too-many-requests' => AuthError.tooManyRequests,
        _ => AuthError.unknown,
      };

  static AppUser? _toAppUser(User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          email: u.email,
          displayName: u.displayName,
          photoUrl: u.photoURL,
          emailVerified: u.emailVerified,
          usesPassword: u.providerData.any((p) => p.providerId == 'password'),
        );
}
