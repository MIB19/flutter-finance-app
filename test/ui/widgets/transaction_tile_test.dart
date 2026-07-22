import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/transaction.dart';
import 'package:keuangan_app/ui/widgets/transaction_tile.dart';

Transaction _tx() => const Transaction(
      id: 't1', familyId: 'f1', categoryId: 'c1', createdBy: 'u1', createdByName: 'Ivan',
      amount: 50000, type: TxType.expense, note: 'nasi', occurredOn: '2026-07-05', source: 'manual',
    );

void main() {
  testWidgets('shows the category avatar when category is known', (tester) async {
    final category = Category(id: 'c1', familyId: 'f1', name: 'Makan', type: TxType.expense, isPreset: false);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TransactionTile(tx: _tx(), category: category)),
    ));

    expect(find.text('M'), findsOneWidget);
    expect(find.text('nasi'), findsOneWidget);
  });

  testWidgets('falls back to a ? avatar when category is null', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: TransactionTile(tx: _tx(), category: null)),
    ));

    expect(find.text('?'), findsOneWidget);
  });
}
