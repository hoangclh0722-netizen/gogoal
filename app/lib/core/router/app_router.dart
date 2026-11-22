import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/auth_flow.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/discover/presentation/home_screen.dart';
import '../../features/match/domain/entities/match.dart';
import '../../features/match/presentation/create_match_screen.dart';
import '../../features/match/presentation/manage_match_screen.dart';
import '../../features/match/presentation/match_detail_screen.dart';
import '../../features/match/presentation/my_matches_screen.dart';
import '../../features/notification/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/rating/presentation/rate_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../widgets/coming_soon_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const profile = '/profile';
  static const profileSetup = '/profile/setup';
  static const comingSoon = '/soon';
  static const createMatch = '/match/new';
  static const myMatches = '/my-matches';
  static const notifications = '/notifications';
  static String match(String id) => '/match/$id';
  static String manage(String id) => '/match/$id/manage';
  static String chat(String id) => '/match/$id/chat';
  static String rate(String id) => '/match/$id/rate';
  static String edit(String id) => '/match/$id/edit';
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
        path: Routes.forgotPassword,
        builder: (_, state) => ForgotPasswordScreen(email: state.extra as String?),
      ),
      GoRoute(path: Routes.myMatches, builder: (_, _) => const MyMatchesScreen()),
      GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: Routes.createMatch, builder: (_, _) => const CreateMatchScreen()),
      GoRoute(
        path: '/match/:id',
        builder: (_, state) => MatchDetailScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/match/:id/rate',
        builder: (_, state) => RateScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/match/:id/chat',
        builder: (_, state) => ChatScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/match/:id/manage',
        builder: (_, state) => ManageMatchScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/match/:id/edit',
        builder: (_, state) => CreateMatchScreen(initial: state.extra as Match),
      ),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: Routes.profileSetup,
        builder: (_, state) => ProfileSetupScreen(initial: state.extra as UserProfile?),
      ),
      GoRoute(
        path: Routes.comingSoon,
        builder: (_, state) => ComingSoonScreen(title: state.extra as String? ?? ''),
      ),
    ],
  );
});

/// Khách bấm hành động cần tài khoản thì sang Đăng nhập (và Hoàn thành hồ sơ nếu cần), xong mới chạy tiếp [action].
Future<void> requireLogin(BuildContext context, WidgetRef ref, VoidCallback action) async {
  if (ref.read(signedInProvider)) {
    if (await ensureProfile(context, ref) && context.mounted) action();
    return;
  }
  final ok = await context.push<bool>(Routes.login);
  if (ok == true && context.mounted) action();
}
