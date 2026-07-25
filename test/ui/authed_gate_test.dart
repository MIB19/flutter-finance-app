import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/repositories/onboarding_repository.dart';
import 'package:keuangan_app/core/api_exception.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  testWidgets('shows a retry button instead of an infinite splash when bootstrap fails', (tester) async {
    final repo = MockOnboardingRepository();
    when(() => repo.needsOnboarding())
        .thenAnswer((_) async => throw ApiException(401, 'unauthorized', 'expired token'));

    await tester.pumpWidget(MaterialApp(
      home: AuthedGate(onboardingRepo: repo, displayName: 'Ivan'),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('bootstrap-retry')), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('tapping retry re-calls needsOnboarding and recovers on success', (tester) async {
    final repo = MockOnboardingRepository();
    var callCount = 0;
    when(() => repo.needsOnboarding()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) throw ApiException(401, 'unauthorized', 'expired token');
      return true; // second call succeeds -> needs onboarding
    });

    await tester.pumpWidget(MaterialApp(
      home: AuthedGate(onboardingRepo: repo, displayName: 'Ivan'),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('bootstrap-retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bootstrap-retry')));
    await tester.pump();
    await tester.pump();

    expect(callCount, 2);
    expect(find.byKey(const Key('bootstrap-retry')), findsNothing);
  });
}
