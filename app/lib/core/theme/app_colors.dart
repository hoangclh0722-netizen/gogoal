import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF22C55E);
  // Nút và chữ xanh cần đậm hơn để chữ trắng / chữ xanh đạt tương phản 4.5:1
  static const primaryDark = Color(0xFF15803D);
  static const primarySoft = Color(0xFFDCFCE7);
  static const accent = Color(0xFFF97316);
  static const accentDark = Color(0xFFC2410C);
  static const ink = Color(0xFF0F172A);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  // Viền ô nhập phải nhìn thấy được (tương phản >= 3:1 với nền)
  static const outline = Color(0xFF7E8DA2);
  static const muted = Color(0xFF64748B);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const facebook = Color(0xFF1877F2);

  static const football = Color(0xFF22C55E);
  static const badminton = Color(0xFF3B82F6);
  static const basketball = Color(0xFFF97316);
  static const pickleball = Color(0xFFA855F7);
  static const tennis = Color(0xFFEAB308);
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
}
