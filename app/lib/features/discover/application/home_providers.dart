import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/application/match_providers.dart';
import '../../match/domain/entities/match.dart';
import '../../match/domain/usecases/browse_matches.dart';
import 'location_controller.dart';

class FilterController extends Notifier<MatchFilter> {
  @override
  MatchFilter build() => const MatchFilter(time: TimeFilter.today);

  void setSport(String? id) => state = state.copyWith(sportId: () => id);

  void toggleTime(TimeFilter t) =>
      state = state.copyWith(time: () => state.time == t ? null : t);

  void setQuery(String q) => state = state.copyWith(query: q);

  void clear() => state = const MatchFilter();
}

final filterProvider = NotifierProvider<FilterController, MatchFilter>(FilterController.new);

final loadedMatchesProvider = FutureProvider<List<Match>>(
  (ref) => ref.watch(matchRepositoryProvider).upcomingMatches(),
  retry: (_, _) => null,
);

final visibleMatchesProvider = Provider<AsyncValue<List<Match>>>((ref) {
  final filter = ref.watch(filterProvider);
  final origin = ref.watch(locationProvider.select((l) => l.position));
  return ref.watch(loadedMatchesProvider).whenData(
        (all) => browseMatches(all, filter: filter, now: DateTime.now(), origin: origin),
      );
});
