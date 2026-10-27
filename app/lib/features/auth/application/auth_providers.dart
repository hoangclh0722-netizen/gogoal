import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../data/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => FirebaseAuthRepository(appAuth));

final authStateProvider = StreamProvider<AppUser?>((ref) => ref.watch(authRepositoryProvider).userChanges());

final signedInProvider = Provider<bool>((ref) => ref.watch(authStateProvider).value != null);
