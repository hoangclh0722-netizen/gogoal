import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../../auth/application/auth_providers.dart';
import '../data/firestore_profile_repository.dart';
import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => FirestoreProfileRepository(appFirestore));

final myProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(authStateProvider.select((s) => s.value?.uid));
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watch(uid);
});
