import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/blocs/recurring_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/recurring_rule.dart';
import 'package:keuangan_app/ui/recurring_screen.dart';

class MockRecurringBloc extends MockBloc<RecurringEvent, RecurringState> implements RecurringBloc {}
class MockCategoryCubit extends MockCubit<CategoryState> implements CategoryCubit {}

RecurringRule _rule(String id, {bool active = true}) => RecurringRule(
    id: id, familyId: 'f1', categoryId: 'c1', name: 'Sewa', amount: 3000000, type: TxType.expense,
    dayOfMonth: 1, active: active, startMonth: '2026-01-01', endMonth: null);

void main() {
  setUpAll(() {
    registerFallbackValue(RecurringRequested());
  });

  Widget wrap(RecurringBloc bloc, CategoryCubit cats) => MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<RecurringBloc>.value(value: bloc),
            BlocProvider<CategoryCubit>.value(value: cats),
          ],
          child: const RecurringScreen(),
        ),
      );

  testWidgets('shows add-rule FAB and renders rule row', (tester) async {
    final bloc = MockRecurringBloc();
    final cats = MockCategoryCubit();
    when(() => bloc.state).thenReturn(RecurringState(rules: [_rule('r1')]));
    when(() => cats.state).thenReturn(const CategoryState());

    await tester.pumpWidget(wrap(bloc, cats));

    expect(find.byKey(const Key('add-rule')), findsOneWidget);
    expect(find.textContaining('Sewa'), findsOneWidget);
  });
}
