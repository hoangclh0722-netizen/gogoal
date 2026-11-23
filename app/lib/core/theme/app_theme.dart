import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
    primary: c.primaryDark,
    onPrimary: Colors.white,
    secondary: c.accentDark,
    onSecondary: Colors.white,
    surface: c.surface,
    error: c.danger,
  );
  final text = GoogleFonts.beVietnamProTextTheme(ThemeData(brightness: brightness).textTheme).apply(
    bodyColor: c.ink,
    displayColor: c.ink,
  );
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
  const buttonText = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: c.outline),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    extensions: [c],
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: c.surface,
      surfaceTintColor: c.surface,
      foregroundColor: c.ink,
      shape: Border(bottom: BorderSide(color: c.border)),
    ),
    dialogTheme: DialogThemeData(backgroundColor: c.surface),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.surface),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: buttonShape, textStyle: buttonText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: buttonShape, textStyle: buttonText, foregroundColor: c.primaryText),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: buttonText, foregroundColor: c.primaryText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: c.muted, fontSize: 15),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: c.primaryText, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.dangerText)),
      focusedErrorBorder:
          inputBorder.copyWith(borderSide: BorderSide(color: c.dangerText, width: 1.5)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: TextStyle(color: c.background),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );
}
