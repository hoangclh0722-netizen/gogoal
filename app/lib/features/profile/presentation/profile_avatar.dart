import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/user_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, required this.name, this.radius = 36, this.onGreen = false});

  final String? photoUrl;
  final String name;
  final double radius;
  final bool onGreen;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: onGreen ? Colors.white : AppColors.primary,
      foregroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
          color: onGreen ? AppColors.primaryDark : Colors.white,
        ),
      ),
    );
  }
}
