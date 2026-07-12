import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/recurring_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/recurring_rule.dart';
import 'package:keuangan_app/repositories/recurring_repository.dart';

class MockRecurringRepo extends Mock implements RecurringRepository {}

RecurringRule _rule(String id, {bool active = true}) => RecurringRule(
  id: id, familyId: 'f1', categoryId: 'c1', name: 'Sewa', amount: 3000000, type: TxType.expense,
  dayOfMonth: 1, active: active, startMonth: '2026-01-01', endMonth: null);

void main() {
  late MockRecurringRepo repo;
  setUp(() => repo = MockRecurringRepo());

  blocTest<RecurringBloc, RecurringState>(
    'load -> loaded rules',
    build: () {
      when(() => repo.list()).thenAnswer((_) async => [_rule('r1')]);
      return RecurringBloc(repo);
    },
    act: (b) => b.add(RecurringRequested()),
    expect: () => [
      isA<RecurringState>().having((s) => s.loading, 'loading', true),
      isA<RecurringState>().having((s) => s.rules.length, 'count', 1),
    ],
  );

  blocTest<RecurringBloc, RecurringState>(
    'toggle active -> updates then reloads',
    build: () {
      when(() => repo.update('r1', any())).thenAnswer((_) async => _rule('r1', active: false));
      when(() => repo.list()).thenAnswer((_) async => [_rule('r1', active: false)]);
      return RecurringBloc(repo);
    },
    act: (b) => b.add(RecurringToggled('r1', false)),
    expect: () => [
      isA<RecurringState>().having((s) => s.loading, 'loading', true),
      isA<RecurringState>().having((s) => s.rules.single.active, 'active', false),
    ],
    verify: (_) => verify(() => repo.update('r1', {'active': false})).called(1),
  );

  blocTest<RecurringBloc, RecurringState>(
    'update -> patches then reloads',
    build: () {
      when(() => repo.update('r1', any())).thenAnswer((_) async => _rule('r1'));
      when(() => repo.list()).thenAnswer((_) async => [_rule('r1')]);
      return RecurringBloc(repo);
    },
    act: (b) => b.add(RecurringUpdated('r1', const {'amount': 4000000})),
    expect: () => [
      isA<RecurringState>().having((s) => s.loading, 'loading', true),
      isA<RecurringState>().having((s) => s.rules.length, 'count', 1),
    ],
    verify: (_) => verify(() => repo.update('r1', {'amount': 4000000})).called(1),
  );
}
