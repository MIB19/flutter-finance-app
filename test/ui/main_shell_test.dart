import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/blocs/dashboard_cubit.dart';
import 'package:keuangan_app/blocs/family_cubit.dart';
import 'package:keuangan_app/blocs/month_bloc.dart';
import 'package:keuangan_app/blocs/recurring_bloc.dart';
import 'package:keuangan_app/core/api_client.dart';
import 'package:keuangan_app/models/dashboard.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/repositories/transaction_repository.dart';
import 'package:keuangan_app/ui/transaction_form_screen.dart';

class MockDashboardCubit extends MockCubit<DashboardState> implements DashboardCubit {}
class MockMonthBloc extends MockBloc<MonthEvent, MonthState> implements MonthBloc {}
class MockCategoryCubit extends MockCubit<CategoryState> implements CategoryCubit {}
class MockRecurringBloc extends MockBloc<RecurringEvent, RecurringState> implements RecurringBloc {}
class MockFamilyCubit extends MockCubit<FamilyState> implements FamilyCubit {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    registerFallbackValue(RecurringRequested());
  });

  Widget wrap({TransactionRepository? txRepo}) {
    final dash = MockDashboardCubit();
    final month = MockMonthBloc();
    final cats = MockCategoryCubit();
    final recurring = MockRecurringBloc();
    final family = MockFamilyCubit();
    when(() => dash.state).thenReturn(const DashboardState.loaded(Dashboard(balance: 0, summary: MonthSummary(income: 0, expense: 0))));
    when(() => month.state).thenReturn(const MonthState(status: MonthStatus.loaded, ym: '2026-07'));
    when(() => cats.state).thenReturn(const CategoryState());
    when(() => recurring.state).thenReturn(const RecurringState());
    when(() => family.state).thenReturn(const FamilyState());

    // Providers must wrap MaterialApp (not sit inside `home:`), matching the
    // real KeuanganApp.build() structure — MaterialApp owns the Navigator,
    // and routes pushed onto it (e.g. the FAB's TransactionFormScreen push)
    // are siblings in the Overlay, not descendants of `home`'s subtree, so
    // they can only see providers placed above the Navigator.
    Widget app = MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>.value(value: dash),
        BlocProvider<MonthBloc>.value(value: month),
        BlocProvider<CategoryCubit>.value(value: cats),
        BlocProvider<RecurringBloc>.value(value: recurring),
        BlocProvider<FamilyCubit>.value(value: family),
      ],
      child: const MaterialApp(home: MainShell()),
    );
    if (txRepo != null) {
      app = RepositoryProvider<TransactionRepository>.value(value: txRepo, child: app);
    }
    return app;
  }

  testWidgets('shows Home tab by default with exactly one FAB', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.byKey(const Key('balance-value')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('switching to Tetap tab still shows exactly one FAB (not two)', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byKey(const Key('nav-Tetap')));
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('switching to Stats tab shows exactly one FAB', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.byKey(const Key('nav-Stats')));
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('tapping the FAB opens TransactionFormScreen', (tester) async {
    // TransactionRepository only needs a constructible ApiClient here — its
    // methods are never invoked by TransactionFormScreen.build(), only inside
    // save/delete callbacks this test never triggers, so a real Dio instance
    // that never fires a request is safe.
    final txRepo = TransactionRepository(ApiClient(dio: Dio(), getToken: () async => null));

    await tester.pumpWidget(wrap(txRepo: txRepo));

    await tester.tap(find.byKey(const Key('main-fab-add-transaction')));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionFormScreen), findsOneWidget);
  });
}
