import 'package:flutter/material.dart';

/// Theme-aware color tokens. Read everywhere via [AppColors.bg] etc. so a
/// flip of [_isDark] (via [ThemeController]) repaints the whole UI.
///
/// Brand colors (primary, accent, amber, gradients) stay constant across
/// modes — they read well on both backgrounds.
class AppColors {
  AppColors._();

  static bool _isDark = false;
  static bool get isDark => _isDark;
  static set isDark(bool v) => _isDark = v;

  // ---------- surfaces ----------

  static Color get bg => _isDark
      ? const Color(0xFF0E1414)
      : const Color(0xFFFAFAF7);

  static Color get surface => _isDark
      ? const Color(0xFF1A1F1F)
      : Colors.white;

  /// Cards on top of [surface] (e.g. inside a tile inside a card).
  static Color get surfaceAlt => _isDark
      ? const Color(0xFF222828)
      : Colors.white;

  static Color get field => _isDark
      ? const Color(0xFF252B2B)
      : const Color(0xFFF1F3EE);

  static Color get field2 => _isDark
      ? const Color(0xFF2D3232)
      : const Color(0xFFEDEFE9);

  static Color get border => _isDark
      ? const Color(0xFF2D3232)
      : const Color(0xFFE5E8E0);

  // ---------- text ----------

  static Color get textDark => _isDark
      ? const Color(0xFFF2F2EE)
      : const Color(0xFF0E1A2E);

  static Color get textBody => _isDark
      ? const Color(0xFFD8D9D4)
      : const Color(0xFF2A3142);

  static Color get textMuted => _isDark
      ? const Color(0xFF8A9090)
      : const Color(0xFF6B7589);

  static Color get textFaint => _isDark
      ? const Color(0xFF606666)
      : const Color(0xFF98A1B3);

  // ---------- brand tints ----------

  static Color get primarySoft => _isDark
      ? const Color(0xFF1F3835)
      : const Color(0xFFE6F1EF);
}
