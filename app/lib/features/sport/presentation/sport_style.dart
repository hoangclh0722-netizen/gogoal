import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/sport.dart';

extension SportStyle on Sport {
  Color get color => switch (id) {
        'football' => AppColors.football,
        'badminton' => AppColors.badminton,
        'basketball' => AppColors.basketball,
        'pickleball' => AppColors.pickleball,
        _ => AppColors.tennis,
      };

  IconData get icon => switch (id) {
        'football' => Icons.sports_soccer,
        'badminton' => Icons.sports_tennis,
        'basketball' => Icons.sports_basketball,
        'pickleball' => Icons.sports_cricket,
        _ => Icons.sports_baseball,
      };
}
