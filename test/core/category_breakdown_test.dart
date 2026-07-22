import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/category_breakdown.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/transaction.dart';

Transaction _tx(String categoryId, int amount, TxType type) => Transaction(
      id: 't-$categoryId-$amount', familyId: 'f1', categoryId: categoryId,
      createdBy: null, createdByName: null, amount: amount, type: type,
      note: null, occurredOn: '2026-07-05', source: 'manual',
    );

Category _cat(String id, String name, TxType type) =>
    Category(id: id, familyId: 'f1', name: name, type: type, isPreset: false);

void main() {
  final categories = [
    _cat('c1', 'Gaji', TxType.income),
    _cat('c2', 'Freelance', TxType.income),
    _cat('c3', 'Makan', TxType.expense),
  ];

  test('groups by category and computes percentages for the given type', () {
    final transactions = [
      _tx('c1', 8000000, TxType.income),
      _tx('c2', 2000000, TxType.income),
      _tx('c3', 500000, TxType.expense),
    ];

    final result = computeBreakdown(transactions: transactions, categories: categories, type: TxType.income);

    expect(result, hasLength(2));
    expect(result[0].categoryId, 'c1');
    expect(result[0].total, 8000000);
    expect(result[0].percent, closeTo(0.8, 0.0001));
    expect(result[1].categoryId, 'c2');
    expect(result[1].percent, closeTo(0.2, 0.0001));
  });

  test('sums multiple transactions in the same category', () {
    final transactions = [
      _tx('c1', 1000000, TxType.income),
      _tx('c1', 1000000, TxType.income),
    ];

    final result = computeBreakdown(transactions: transactions, categories: categories, type: TxType.income);

    expect(result, hasLength(1));
    expect(result[0].total, 2000000);
    expect(result[0].percent, 1.0);
  });

  test('returns an empty list when there are no transactions of that type', () {
    final result = computeBreakdown(transactions: const [], categories: categories, type: TxType.expense);
    expect(result, isEmpty);
  });

  test('falls back to "Lainnya" for a categoryId with no matching category', () {
    final transactions = [_tx('unknown-id', 100000, TxType.expense)];
    final result = computeBreakdown(transactions: transactions, categories: categories, type: TxType.expense);
    expect(result[0].categoryName, 'Lainnya');
  });

  test('sorts by total descending', () {
    final transactions = [
      _tx('c2', 1000000, TxType.income),
      _tx('c1', 5000000, TxType.income),
    ];
    final result = computeBreakdown(transactions: transactions, categories: categories, type: TxType.income);
    expect(result[0].categoryId, 'c1');
    expect(result[1].categoryId, 'c2');
  });
}
