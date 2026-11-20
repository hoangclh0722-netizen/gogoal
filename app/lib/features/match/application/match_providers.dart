import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../../auth/application/auth_providers.dart';
import '../../notification/application/notification_providers.dart';
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
  return FirestoreMatchRepository(appFirestore, ref.watch(notificationRepositoryProvider));
});

final participantRepositoryProvider = Provider<ParticipantRepository>(
  (ref) => _fake
      ? FakeParticipantRepository()
      : FirestoreParticipantRepository(appFirestore, ref.watch(notificationRepositoryProvider)),
);

final matchProvider = StreamProvider.family<Match?, String>(
  (ref, id) => ref.watch(matchRepositoryProvider).watchMatch(id),
);

final myMatchesProvider = FutureProvider.autoDispose<List<MyMatch>>((ref) {
  final uid = ref.watch(authStateProvider.select((s) => s.value?.uid));
  if (uid == null) return const [];
  return ref.watch(matchRepositoryProvider).myMatches(uid);
});

final isWatchingProvider = StreamProvider.family<bool, String>((ref, matchId) {
  final uid = ref.watch(authStateProvider.select((s) => s.value?.uid));
  if (uid == null) return Stream.value(false);
  return ref.watch(matchRepositoryProvider).watchIsWatching(uid, matchId);
});

/// Khóa bằng record để không tải lại mỗi lần kèo gốc cập nhật.
final sameTimeProvider =
    FutureProvider.autoDispose.family<List<Match>, ({String id, String sportId, DateTime startAt})>((ref, key) {
  final probe = ref.read(matchProvider(key.id)).value;
  if (probe == null) return const [];
  return ref.watch(matchRepositoryProvider).sameTime(probe);
});

final venuesProvider = FutureProvider.family<List<VenueOption>, String>(
  (ref, sportId) => ref.watch(matchRepositoryProvider).venues(sportId),
);

final membersProvider = StreamProvider.family<List<Member>, String>(
  (ref, matchId) => ref.watch(participantRepositoryProvider).watchMembers(matchId),
);

final requestsProvider = StreamProvider.family<List<JoinRequest>, String>(
  (ref, matchId) => ref.watch(participantRepositoryProvider).watchRequests(matchId),
);

final myParticipationProvider = StreamProvider.family<ParticipantStatus?, String>((ref, matchId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(participantRepositoryProvider).watchMyStatus(matchId, user.uid);
});
