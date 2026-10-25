import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _seenKey = 'onboarding_seen';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override trong main()'),
);

class OnboardingStore {
  const OnboardingStore(this._prefs);

  final SharedPreferences _prefs;

  bool get seen => _prefs.getBool(_seenKey) ?? false;

  Future<void> markSeen() => _prefs.setBool(_seenKey, true);
}

final onboardingStoreProvider =
    Provider((ref) => OnboardingStore(ref.watch(sharedPreferencesProvider)));
