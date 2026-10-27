import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../data/fake_match_repository.dart';
import '../data/firestore_match_repository.dart';
import '../domain/entities/match_repository.dart';

const _fake = bool.fromEnvironment('FAKE');
const _scenario = String.fromEnvironment('FAKE_SCENARIO');

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  if (_fake) {
    return FakeMatchRepository(
      scenario: _scenario == 'offline' ? FakeScenario.offline : FakeScenario.normal,
    );
  }
  return FirestoreMatchRepository(appFirestore);
});
