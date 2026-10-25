import 'match.dart';

abstract interface class MatchRepository {
  Future<List<Match>> upcomingMatches({Duration within = const Duration(days: 7)});
}
