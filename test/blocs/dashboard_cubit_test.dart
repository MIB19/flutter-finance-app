import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/dashboard_cubit.dart';
import 'package:keuangan_app/models/dashboard.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/repositories/finance_repository.dart';

class MockFinanceRepo extends Mock implements FinanceRepository {}

void main() {
  late MockFinanceRepo repo;
  setUp(() => repo = MockFinanceRepo());

  blocTest<DashboardCubit, DashboardState>(
    'loads dashboard -> loaded',
    build: () {
      when(() => repo.dashboard(any())).thenAnswer(
        (_) async => const Dashboard(balance: -3000000, summary: MonthSummary(income: 0, expense: 3000000)),
      );
      return DashboardCubit(repo);
    },
    act: (c) => c.load('2026-07'),
    expect: () => [
      const DashboardState.loading(),
      isA<DashboardState>().having((s) => s.data?.balance, 'balance', -3000000),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'error -> failure',
    build: () {
      when(() => repo.dashboard(any())).thenThrow(Exception('boom'));
      return DashboardCubit(repo);
    },
    act: (c) => c.load('2026-07'),
    expect: () => [
      const DashboardState.loading(),
      isA<DashboardState>().having((s) => s.error, 'error', isNotNull),
    ],
  );
}
