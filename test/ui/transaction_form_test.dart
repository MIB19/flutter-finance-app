import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/blocs/dashboard_cubit.dart';
import 'package:keuangan_app/blocs/month_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/transaction.dart';
import 'package:keuangan_app/repositories/transaction_repository.dart';
import 'package:keuangan_app/ui/transaction_form_screen.dart';

class MockCategoryCubit extends MockCubit<CategoryState> implements CategoryCubit {}
class MockTxRepo extends Mock implements TransactionRepository {}
class MockMonthBloc extends MockBloc<MonthEvent, MonthState> implements MonthBloc {}
class MockDashboardCubit extends MockCubit<DashboardState> implements DashboardCubit {}

const _cat = Category(id: 'c1', familyId: 'f1', name: 'Makan', type: TxType.expense, isPreset: true);

Transaction _tx() => const Transaction(
    id: 't1', familyId: 'f1', categoryId: 'c1', createdBy: 'u1', createdByName: 'Ivan',
    amount: 75000, type: TxType.expense, note: 'nasi padang', occurredOn: '2026-07-05', source: 'manual');

Widget _wrap(Widget child, {required CategoryCubit cats, MonthBloc? month, DashboardCubit? dashboard}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<CategoryCubit>.value(value: cats),
        if (month != null) BlocProvider<MonthBloc>.value(value: month),
        if (dashboard != null) BlocProvider<DashboardCubit>.value(value: dashboard),
      ],
      child: child,
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(MonthRequested(''));
    registerFallbackValue(TxType.expense);
  });

  testWidgets('shows validation error when amount empty', (tester) async {
    final cats = MockCategoryCubit();
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));

    await tester.pumpWidget(_wrap(
      TransactionFormScreen(txRepo: MockTxRepo()),
      cats: cats,
    ));

    await tester.tap(find.byKey(const Key('save-tx')));
    await tester.pump();
    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });

  testWidgets('create mode: no delete button, empty amount field', (tester) async {
    final cats = MockCategoryCubit();
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));

    await tester.pumpWidget(_wrap(
      TransactionFormScreen(txRepo: MockTxRepo()),
      cats: cats,
    ));

    expect(find.byKey(const Key('delete-tx')), findsNothing);
    expect(find.byKey(const Key('amount-field')), findsOneWidget);
    final field = tester.widget<TextFormField>(find.byKey(const Key('amount-field')));
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('edit mode: prefills amount and shows delete button', (tester) async {
    final cats = MockCategoryCubit();
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));

    await tester.pumpWidget(_wrap(
      TransactionFormScreen(txRepo: MockTxRepo(), existing: _tx()),
      cats: cats,
    ));

    final field = tester.widget<TextFormField>(find.byKey(const Key('amount-field')));
    expect(field.controller!.text, '75000');
    expect(find.byKey(const Key('delete-tx')), findsOneWidget);
  });

  testWidgets('edit mode: save calls txRepo.update and reloads month + dashboard', (tester) async {
    final cats = MockCategoryCubit();
    final month = MockMonthBloc();
    final dashboard = MockDashboardCubit();
    final repo = MockTxRepo();
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));
    when(() => month.state).thenReturn(const MonthState(status: MonthStatus.loaded, ym: '2026-07'));
    when(() => repo.update(any(), any())).thenAnswer((_) async => _tx());
    when(() => dashboard.load(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(
      TransactionFormScreen(txRepo: repo, existing: _tx()),
      cats: cats,
      month: month,
      dashboard: dashboard,
    ));

    await tester.tap(find.byKey(const Key('save-tx')));
    await tester.pumpAndSettle();

    verify(() => repo.update('t1', any())).called(1);
    verify(() => month.add(any(that: isA<MonthRequested>()))).called(1);
    verify(() => dashboard.load('2026-07')).called(1);
  });

  testWidgets('edit mode: delete calls txRepo.remove and reloads', (tester) async {
    final cats = MockCategoryCubit();
    final month = MockMonthBloc();
    final dashboard = MockDashboardCubit();
    final repo = MockTxRepo();
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));
    when(() => month.state).thenReturn(const MonthState(status: MonthStatus.loaded, ym: '2026-07'));
    when(() => repo.remove(any())).thenAnswer((_) async {});
    when(() => dashboard.load(any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(
      TransactionFormScreen(txRepo: repo, existing: _tx()),
      cats: cats,
      month: month,
      dashboard: dashboard,
    ));

    await tester.tap(find.byKey(const Key('delete-tx')));
    await tester.pumpAndSettle();

    verify(() => repo.remove('t1')).called(1);
    verify(() => dashboard.load('2026-07')).called(1);
  });

  testWidgets('add-category dialog calls CategoryCubit.add', (tester) async {
    final cats = MockCategoryCubit();
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));
    when(() => cats.add(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(_wrap(
      TransactionFormScreen(txRepo: MockTxRepo()),
      cats: cats,
    ));

    await tester.tap(find.byKey(const Key('add-category')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('new-category-name')), 'Kopi');
    await tester.tap(find.byKey(const Key('confirm-add-category')));
    await tester.pumpAndSettle();

    verify(() => cats.add('Kopi', TxType.expense)).called(1);
  });
}
