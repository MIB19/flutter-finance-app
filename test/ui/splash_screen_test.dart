import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/ui/splash_screen.dart';

void main() {
  testWidgets('shows app name, tagline, and a loading indicator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Keuangan Keluarga'), findsOneWidget);
    expect(find.text('Kelola keuangan keluarga, bareng-bareng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
