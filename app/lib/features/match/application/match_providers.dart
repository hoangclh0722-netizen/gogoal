import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../../auth/application/auth_providers.dart';
import '../data/fake_match_repository.dart';
import '../data/firestore_match_repository.dart';
import '../data/firestore_participant_repository.dart';
import '../domain/entities/match.dart';
import '../domain/entities/match_repository.dart';
import '../domain/entities/participant.dart';

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

final participantRepositoryProvider = Provider<ParticipantRepository>(
  (ref) => _fake ? FakeParticipantRepository() : FirestoreParticipantRepository(appFirestore),
);

final matchProvider = StreamProvider.family<Match?, String>(
  (ref, id) => ref.watch(matchRepositoryProvider).watchMatch(id),
);

final myParticipationProvider = StreamProvider.family<ParticipantStatus?, String>((ref, matchId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(participantRepositoryProvider).watchMyStatus(matchId, user.uid);
});
