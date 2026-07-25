import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/blocs/month_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/models/transaction.dart';
import 'package:keuangan_app/ui/stats_screen.dart';

class MockMonthBloc extends MockBloc<MonthEvent, MonthState> implements MonthBloc {}
class MockCategoryCubit extends MockCubit<CategoryState> implements CategoryCubit {}

Transaction _tx(String categoryId, int amount, TxType type) => Transaction(
      id: 't-$categoryId', familyId: 'f1', categoryId: categoryId,
      createdBy: null, createdByName: null, amount: amount, type: type,
      note: null, occurredOn: '2026-07-05', source: 'manual',
    );

void main() {
  Widget wrap(MonthBloc month, CategoryCubit cats) => MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MonthBloc>.value(value: month),
            BlocProvider<CategoryCubit>.value(value: cats),
          ],
          child: const StatsScreen(),
        ),
      );

  testWidgets('shows expense breakdown by default', (tester) async {
    final month = MockMonthBloc();
    final cats = MockCategoryCubit();
    when(() => month.state).thenReturn(MonthState(
      status: MonthStatus.loaded,
      ym: '2026-07',
      transactions: [_tx('c1', 8000000, TxType.income), _tx('c2', 500000, TxType.expense)],
      summary: const MonthSummary(income: 8000000, expense: 500000),
    ));
    when(() => cats.state).thenReturn(CategoryState(categories: [
      Category(id: 'c1', familyId: 'f1', name: 'Gaji', type: TxType.income, isPreset: false),
      Category(id: 'c2', familyId: 'f1', name: 'Makan', type: TxType.expense, isPreset: false),
    ]));

    await tester.pumpWidget(wrap(month, cats));

    expect(find.text('Makan'), findsOneWidget);
    expect(find.text('Gaji'), findsNothing);
  });

  testWidgets('toggling to Income swaps the breakdown shown', (tester) async {
    final month = MockMonthBloc();
    final cats = MockCategoryCubit();
    when(() => month.state).thenReturn(MonthState(
      status: MonthStatus.loaded,
      ym: '2026-07',
      transactions: [_tx('c1', 8000000, TxType.income), _tx('c2', 500000, TxType.expense)],
      summary: const MonthSummary(income: 8000000, expense: 500000),
    ));
    when(() => cats.state).thenReturn(CategoryState(categories: [
      Category(id: 'c1', familyId: 'f1', name: 'Gaji', type: TxType.income, isPreset: false),
      Category(id: 'c2', familyId: 'f1', name: 'Makan', type: TxType.expense, isPreset: false),
    ]));

    await tester.pumpWidget(wrap(month, cats));
    await tester.tap(find.text('Income'));
    await tester.pump();

    expect(find.text('Gaji'), findsOneWidget);
    expect(find.text('Makan'), findsNothing);
  });
}
