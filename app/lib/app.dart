import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/match/application/match_reminders.dart';
import 'features/settings/application/settings_controller.dart';

class GoGoalApp extends ConsumerWidget {
  const GoGoalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(matchRemindersProvider);
    return MaterialApp.router(
      title: 'GoGoal',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
