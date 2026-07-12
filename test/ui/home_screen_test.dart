import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/dashboard_cubit.dart';
import 'package:keuangan_app/blocs/month_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/dashboard.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/models/transaction.dart';
import 'package:keuangan_app/ui/home_screen.dart';

class MockDashboardCubit extends MockCubit<DashboardState> implements DashboardCubit {}
class MockMonthBloc extends MockBloc<MonthEvent, MonthState> implements MonthBloc {}

Transaction _tx() => const Transaction(
  id: 't1', familyId: 'f1', categoryId: 'c1', createdBy: 'u1', createdByName: 'Ivan',
  amount: 50000, type: TxType.expense, note: 'nasi', occurredOn: '2026-07-05', source: 'manual');

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('renders balance and a transaction', (tester) async {
    final dash = MockDashboardCubit();
    final month = MockMonthBloc();
    when(() => dash.state).thenReturn(const DashboardState.loaded(Dashboard(balance: -50000, summary: MonthSummary(income: 0, expense: 50000))));
    when(() => month.state).thenReturn(MonthState(status: MonthStatus.loaded, ym: '2026-07', transactions: [_tx()], summary: const MonthSummary(income: 0, expense: 50000)));

    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>.value(value: dash),
          BlocProvider<MonthBloc>.value(value: month),
        ],
        child: const HomeScreen(),
      ),
    ));

    expect(find.byKey(const Key('balance-value')), findsOneWidget);
    expect(find.text('nasi'), findsOneWidget);
  });
}
