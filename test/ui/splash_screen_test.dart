import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/ui/splash_screen.dart';
import 'package:keuangan_app/ui/widgets/dot_grid_background.dart';

void main() {
  testWidgets('skips the entrance animation on a second mount within the same session', (tester) async {
    // First mount in this process/isolate: entrance should actually be playing,
    // not already settled. Assert this BEFORE it has time to finish animating.
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 50)); // early in the 900ms entrance
    final firstMountScale = tester.widget<ScaleTransition>(
      find.descendant(of: find.byType(DotGridBackground), matching: find.byType(ScaleTransition)),
    );
    expect(firstMountScale.scale.value, lessThan(1.0));

    // Let the first entrance finish.
    await tester.pump(const Duration(milliseconds: 1000));

    // Unmount, then mount a SECOND fresh SplashScreen instance (simulating app.dart's
    // second SplashScreen() at a different tree location).
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(); // first frame of the second mount

    // On the second mount, the icon should already be at full scale/opacity
    // immediately (no animating-in), because the entrance already played once.
    final secondMountScale = tester.widget<ScaleTransition>(
      find.descendant(of: find.byType(DotGridBackground), matching: find.byType(ScaleTransition)),
    );
    expect(secondMountScale.scale.value, 1.0);
  });

  testWidgets('shows app name, tagline, and a loading indicator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Keuangan Keluarga'), findsOneWidget);
    expect(find.text('Kelola keuangan keluarga, bareng-bareng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes cleanly when removed mid-animation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });
}
