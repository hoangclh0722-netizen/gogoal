import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  /// Icon màu bộ Noto Emoji (Google, Apache 2.0). Pickleball chưa có emoji riêng nên dùng vợt bóng bàn.
  String get asset => 'assets/sports/$id.svg';
}

class SportIcon extends StatelessWidget {
  const SportIcon(this.sport, {super.key, this.size = 24});

  final Sport sport;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(sport.asset, width: size, height: size);
}
