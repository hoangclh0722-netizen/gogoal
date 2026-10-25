import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonKind { primary, accent, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.height = 52,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
    const textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
    final size = Size(expand ? double.infinity : 0, height);

    if (kind == AppButtonKind.outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: shape,
          textStyle: textStyle,
        ),
        child: Text(label),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: size,
        backgroundColor: kind == AppButtonKind.accent ? AppColors.accent : AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: AppColors.muted,
        shape: shape,
        textStyle: textStyle,
      ),
      child: Text(label),
    );
  }
}
