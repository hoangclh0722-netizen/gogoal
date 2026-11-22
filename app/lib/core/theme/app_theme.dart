import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primaryDark,
    secondary: AppColors.accentDark,
    surface: AppColors.surface,
    error: AppColors.danger,
  );
  final text = GoogleFonts.beVietnamProTextTheme().apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
  const buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: const BorderSide(color: AppColors.outline),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: buttonShape, textStyle: buttonText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: buttonShape, textStyle: buttonText),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: buttonText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 15),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.danger)),
      focusedErrorBorder:
          inputBorder.copyWith(borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );
}
