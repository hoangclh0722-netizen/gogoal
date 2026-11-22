import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/onboarding_store.dart';

const _remindersKey = 'reminders_on';

class RemindersController extends Notifier<bool> {
  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_remindersKey) ?? true;

  Future<void> set(bool on) async {
    state = on;
    await ref.read(sharedPreferencesProvider).setBool(_remindersKey, on);
  }
}

final remindersOnProvider = NotifierProvider<RemindersController, bool>(RemindersController.new);
