import 'package:flutter/material.dart';

/// Poppins for display/headings, Inter for body/data — see design spec.
TextTheme buildAppTextTheme() {
  const poppins = TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold);
  const inter = TextStyle(fontFamily: 'Inter');

  return const TextTheme(
    headlineLarge: poppins,
    headlineMedium: poppins,
    headlineSmall: poppins,
    titleLarge: poppins,
    titleMedium: inter,
    titleSmall: inter,
    bodyLarge: inter,
    bodyMedium: inter,
    bodySmall: inter,
    labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
    labelMedium: inter,
    labelSmall: inter,
  );
}
