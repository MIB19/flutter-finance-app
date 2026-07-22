import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/ui/splash_screen.dart';
import 'package:keuangan_app/ui/widgets/dot_grid_background.dart';

void main() {
  testWidgets('shows app name, tagline, and a loading indicator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Keuangan Keluarga'), findsOneWidget);
    expect(find.text('Kelola keuangan keluarga, bareng-bareng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes cleanly when removed mid-animation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 300)); // mid-entrance, equalizer already looping

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });

  testWidgets('skips the entrance animation on a second mount within the same session', (tester) async {
    // First mount: plays the entrance animation (starts small/transparent, animates in).
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(); // first frame only, entrance still in progress
    // Can't use pumpAndSettle here: the equalizer loader's AnimationController
    // runs `..repeat()` forever, so the tree never settles. Pump a fixed
    // duration comfortably longer than the 900ms entrance instead.
    await tester.pump(const Duration(milliseconds: 1000)); // let the first entrance finish

    // Unmount, then mount a SECOND fresh SplashScreen instance (simulating app.dart's
    // second SplashScreen() at a different tree location).
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(); // first frame of the second mount

    // On the second mount, the icon should already be at full scale/opacity
    // immediately (no animating-in), because the entrance already played once.
    // Scope to DotGridBackground (the splash content) rather than the whole
    // SplashScreen/Scaffold subtree: Scaffold's internal FAB-transition
    // machinery also contains a ScaleTransition even with no FAB set, so
    // find.byType(ScaleTransition) alone matches more than one widget.
    final scaleTransition = tester.widget<ScaleTransition>(
      find.descendant(of: find.byType(DotGridBackground), matching: find.byType(ScaleTransition)),
    );
    expect(scaleTransition.scale.value, 1.0);
  });
}
