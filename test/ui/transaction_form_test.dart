import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/repositories/transaction_repository.dart';
import 'package:keuangan_app/ui/transaction_form_screen.dart';

class MockCategoryCubit extends MockCubit<CategoryState> implements CategoryCubit {}
class MockTxRepo extends Mock implements TransactionRepository {}

void main() {
  testWidgets('shows validation error when amount empty', (tester) async {
    final cats = MockCategoryCubit();
    when(() => cats.state).thenReturn(const CategoryState(categories: [
      Category(id: 'c1', familyId: 'f1', name: 'Makan', type: TxType.expense, isPreset: true),
    ]));

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<CategoryCubit>.value(
        value: cats,
        child: TransactionFormScreen(txRepo: MockTxRepo(), onSaved: () {}),
      ),
    ));

    await tester.tap(find.byKey(const Key('save-tx')));
    await tester.pump();
    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });
}
