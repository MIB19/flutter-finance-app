import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/models/family.dart';
import 'package:keuangan_app/repositories/onboarding_repository.dart';
import 'package:keuangan_app/ui/onboarding_screen.dart';

class MockOnboardingRepo extends Mock implements OnboardingRepository {}

void main() {
  testWidgets('join mode calls joinFamily with the entered code', (tester) async {
    final repo = MockOnboardingRepo();
    when(() => repo.joinFamily(code: any(named: 'code'), displayName: any(named: 'displayName')))
        .thenAnswer((_) async => const Family(id: 'f1', name: 'Rumah', inviteCode: 'ABC234'));

    await tester.pumpWidget(MaterialApp(
      home: OnboardingScreen(repo: repo, displayName: 'Ivan', onDone: () {}),
    ));

    await tester.tap(find.byKey(const Key('mode-join')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('code-field')), 'ABC234');
    await tester.tap(find.byKey(const Key('onboarding-submit')));
    await tester.pump();

    verify(() => repo.joinFamily(code: 'ABC234', displayName: 'Ivan')).called(1);
  });
}
