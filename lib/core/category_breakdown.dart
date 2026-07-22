import 'package:equatable/equatable.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class CategoryBreakdown extends Equatable {
  final String categoryId;
  final String categoryName;
  final int total;
  final double percent;
  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.total,
    required this.percent,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, total, percent];
}

/// Groups [transactions] of the given [type] by category and computes each
/// category's share of the total — pure, no I/O. Backs the Stats screen
/// (see design spec: no new API/cubit, computed client-side from data
/// already loaded by MonthBloc + CategoryCubit).
List<CategoryBreakdown> computeBreakdown({
  required List<Transaction> transactions,
  required List<Category> categories,
  required TxType type,
}) {
  final filtered = transactions.where((t) => t.type == type);
  final totals = <String, int>{};
  for (final t in filtered) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }
  final grandTotal = totals.values.fold<int>(0, (a, b) => a + b);

  final result = totals.entries.map((e) {
    final matches = categories.where((c) => c.id == e.key);
    final name = matches.isNotEmpty ? matches.first.name : 'Lainnya';
    final percent = grandTotal == 0 ? 0.0 : e.value / grandTotal;
    return CategoryBreakdown(categoryId: e.key, categoryName: name, total: e.value, percent: percent);
  }).toList();

  result.sort((a, b) => b.total.compareTo(a.total));
  return result;
}
