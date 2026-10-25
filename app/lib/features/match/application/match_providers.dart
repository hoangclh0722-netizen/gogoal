import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_match_repository.dart';
import '../domain/entities/match_repository.dart';

const _scenario = String.fromEnvironment('FAKE_SCENARIO');

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return FakeMatchRepository(
    scenario: _scenario == 'offline' ? FakeScenario.offline : FakeScenario.normal,
  );
});
