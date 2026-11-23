import 'package:flutter/material.dart';

/// Màu thương hiệu, giữ nguyên ở cả chế độ sáng và tối.
abstract final class AppColors {
  static const primary = Color(0xFF22C55E);
  static const accent = Color(0xFFF97316);
  static const warning = Color(0xFFF59E0B);
  static const facebook = Color(0xFF1877F2);

  static const football = Color(0xFF22C55E);
  static const badminton = Color(0xFF3B82F6);
  static const basketball = Color(0xFFF97316);
  static const pickleball = Color(0xFFA855F7);
  static const tennis = Color(0xFFEAB308);
}

/// Màu đổi theo chế độ sáng/tối, lấy qua `context.colors`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primaryDark,
    required this.primaryText,
    required this.accentText,
    required this.dangerText,
    required this.primarySoft,
    required this.accentDark,
    required this.accentSoft,
    required this.ink,
    required this.background,
    required this.surface,
    required this.border,
    required this.outline,
    required this.muted,
    required this.neutralSoft,
    required this.warningSoft,
    required this.warningBorder,
    required this.warningInk,
    required this.warningText,
    required this.danger,
    required this.dangerSoft,
    required this.dangerInk,
    required this.info,
    required this.infoSoft,
  });

  // primaryDark/accentDark/danger dùng làm nền có chữ trắng; *Text dùng cho chữ, icon, viền nhấn.
  // Tách ra vì ở chế độ tối một màu không thể vừa làm nền chữ trắng vừa làm chữ trên nền tối (cả hai cần 4.5:1)
  final Color primaryDark;
  final Color primaryText;
  final Color accentText;
  final Color dangerText;
  final Color primarySoft;
  final Color accentDark;
  final Color accentSoft;
  final Color ink;
  final Color background;
  final Color surface;
  final Color border;
  // Viền ô nhập phải nhìn thấy được (tương phản >= 3:1 với nền)
  final Color outline;
  final Color muted;
  final Color neutralSoft;
  // Nền vàng nhạt cho thông báo, kèm màu icon và chữ đậm dần
  final Color warningSoft;
  final Color warningBorder;
  final Color warningInk;
  final Color warningText;
  final Color danger;
  final Color dangerSoft;
  final Color dangerInk;
  final Color info;
  final Color infoSoft;

  static const light = AppPalette(
    primaryDark: Color(0xFF15803D),
    primaryText: Color(0xFF15803D),
    accentText: Color(0xFFC2410C),
    dangerText: Color(0xFFDC2626),
    primarySoft: Color(0xFFDCFCE7),
    accentDark: Color(0xFFC2410C),
    accentSoft: Color(0xFFFFEDD5),
    ink: Color(0xFF0F172A),
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    border: Color(0xFFE2E8F0),
    outline: Color(0xFF7E8DA2),
    muted: Color(0xFF64748B),
    neutralSoft: Color(0xFFF1F5F9),
    warningSoft: Color(0xFFFEF3C7),
    warningBorder: Color(0xFFFDE68A),
    warningInk: Color(0xFFB45309),
    warningText: Color(0xFF92400E),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFFFEE2E2),
    dangerInk: Color(0xFFB91C1C),
    info: Color(0xFF1D4ED8),
    infoSoft: Color(0xFFDBEAFE),
  );

  static const dark = AppPalette(
    primaryDark: Color(0xFF15803D),
    primaryText: Color(0xFF4ADE80),
    accentText: Color(0xFFFB923C),
    dangerText: Color(0xFFF87171),
    primarySoft: Color(0xFF052E16),
    accentDark: Color(0xFFC2410C),
    accentSoft: Color(0xFF431407),
    ink: Color(0xFFF1F5F9),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    border: Color(0xFF334155),
    outline: Color(0xFF64748B),
    muted: Color(0xFF94A3B8),
    neutralSoft: Color(0xFF273449),
    warningSoft: Color(0xFF422006),
    warningBorder: Color(0xFF713F12),
    warningInk: Color(0xFFFBBF24),
    warningText: Color(0xFFFDE68A),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFF450A0A),
    dangerInk: Color(0xFFFCA5A5),
    info: Color(0xFF60A5FA),
    infoSoft: Color(0xFF172554),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppPaletteX on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
}
