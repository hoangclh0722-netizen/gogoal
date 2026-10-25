import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/discover/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../widgets/coming_soon_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const comingSoon = '/soon';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: Routes.comingSoon,
        builder: (_, state) => ComingSoonScreen(title: state.extra as String? ?? ''),
      ),
    ],
  );
});

/// Khách bấm hành động cần tài khoản thì sang Đăng nhập, đăng nhập xong mới chạy tiếp [action].
Future<void> requireLogin(BuildContext context, WidgetRef ref, VoidCallback action) async {
  if (ref.read(signedInProvider)) return action();
  final ok = await context.push<bool>(Routes.login);
  if (ok == true && context.mounted) action();
}
