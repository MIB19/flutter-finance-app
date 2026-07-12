import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/blocs/recurring_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/recurring_rule.dart';
import 'package:keuangan_app/ui/recurring_form_screen.dart';

class MockRecurringBloc extends MockBloc<RecurringEvent, RecurringState> implements RecurringBloc {}
class MockCategoryCubit extends MockCubit<CategoryState> implements CategoryCubit {}

const _cat = Category(id: 'c1', familyId: 'f1', name: 'Sewa', type: TxType.expense, isPreset: true);

RecurringRule _rule() => const RecurringRule(
    id: 'r1', familyId: 'f1', categoryId: 'c1', name: 'Sewa', amount: 3000000, type: TxType.expense,
    dayOfMonth: 1, active: true, startMonth: '2026-01-01', endMonth: null);

void main() {
  setUpAll(() async {
    registerFallbackValue(RecurringRequested());
    await initializeDateFormatting('id_ID', null);
  });

  Widget wrap(Widget child, RecurringBloc bloc, CategoryCubit cats) => MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<RecurringBloc>.value(value: bloc),
            BlocProvider<CategoryCubit>.value(value: cats),
          ],
          child: child,
        ),
      );

  testWidgets('shows validation error when amount empty', (tester) async {
    final bloc = MockRecurringBloc();
    final cats = MockCategoryCubit();
    when(() => bloc.state).thenReturn(const RecurringState());
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));

    await tester.pumpWidget(wrap(const RecurringFormScreen(), bloc, cats));

    await tester.tap(find.byKey(const Key('save-rule')));
    await tester.pump();
    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });

  testWidgets('edit mode prefills name/amount and shows delete button', (tester) async {
    final bloc = MockRecurringBloc();
    final cats = MockCategoryCubit();
    when(() => bloc.state).thenReturn(const RecurringState());
    when(() => cats.state).thenReturn(const CategoryState(categories: [_cat]));

    await tester.pumpWidget(wrap(RecurringFormScreen(existing: _rule()), bloc, cats));

    final nameField = tester.widget<TextFormField>(find.byKey(const Key('rule-name')));
    expect(nameField.controller!.text, 'Sewa');
    final amountField = tester.widget<TextFormField>(find.byKey(const Key('rule-amount')));
    expect(amountField.controller!.text, '3000000');
    expect(find.byKey(const Key('delete-rule')), findsOneWidget);
  });
}
