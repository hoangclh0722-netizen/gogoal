import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../profile/application/profile_providers.dart';
import '../application/auth_providers.dart';
import '../domain/auth_repository.dart';

String authMessage(AuthError e) => switch (e) {
      AuthError.wrongCredentials => 'Email hoặc mật khẩu không đúng',
      AuthError.emailInUse => 'Email này đã được đăng ký. Nếu bạn từng dùng Google, hãy bấm "Tiếp tục với Google".',
      AuthError.invalidEmail => 'Email không hợp lệ',
      AuthError.weakPassword => 'Mật khẩu cần ít nhất 8 ký tự',
      AuthError.network => 'Không kết nối được, thử lại',
      AuthError.tooManyRequests => 'Bạn thử quá nhiều lần, vui lòng đợi một lát',
      AuthError.cancelled || AuthError.unknown => 'Có lỗi xảy ra, thử lại sau',
    };

/// Người đã đăng nhập nhưng chưa có hồ sơ thì mở màn Hoàn thành hồ sơ. Trả về true khi đã có hồ sơ.
Future<bool> ensureProfile(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authRepositoryProvider).currentUser;
  if (user == null) return false;
  final profile = await ref.read(profileRepositoryProvider).fetch(user.uid);
  if (profile != null) return true;
  if (!context.mounted) return false;
  return await context.push<bool>(Routes.profileSetup) == true;
}
