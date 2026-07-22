import 'package:flutter/material.dart';

/// Design tokens for the fintech-dashboard revamp (see
/// docs/superpowers/specs/2026-07-21-ui-revamp-fintech-design.md).
/// These are for bespoke-painted components; stock Material widgets get
/// their color from ThemeData's colorSchemeSeed instead.
class AppColors {
  AppColors._();

  static const bgHero = Color(0xFF150F2E);
  static const accentPrimary = Color(0xFF7C4DFF);
  static const accentPrimaryLight = Color(0xFFB39CFF);
  static const accentPink = Color(0xFFF48FB1);
  static const accentTeal = Color(0xFF4DB6AC);
  static const accentAmber = Color(0xFFFFB74D);
  static const surfaceSoft = Color(0xFFEDE7F6);
  static const textOnDark = Color(0xFFEDE7FF);
  static const textOnDarkMuted = Color(0xFF9C94C9);

  /// Palette for category avatars. Deterministically selects one color per
  /// category id (via hash modulo), ensuring consistent visual identity.
  static const categoryPalette = [
    accentPrimary,
    accentPink,
    accentPrimaryLight,
    accentTeal,
    accentAmber,
  ];
}
