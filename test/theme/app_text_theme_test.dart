import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/theme/app_text_theme.dart';

void main() {
  test('headline styles use Poppins bold', () {
    final theme = buildAppTextTheme();
    expect(theme.headlineMedium?.fontFamily, 'Poppins');
    expect(theme.headlineMedium?.fontWeight, FontWeight.bold);
    expect(theme.headlineSmall?.fontFamily, 'Poppins');
  });

  test('body/title styles use Inter', () {
    final theme = buildAppTextTheme();
    expect(theme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.titleMedium?.fontFamily, 'Inter');
    expect(theme.labelLarge?.fontFamily, 'Inter');
  });
}
