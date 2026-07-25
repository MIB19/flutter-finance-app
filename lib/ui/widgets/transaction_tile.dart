import 'package:flutter/material.dart';
import '../../core/formatting.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import 'category_avatar.dart';

class TransactionTile extends StatelessWidget {
  final Transaction tx;
  final Category? category;
  final VoidCallback? onTap;
  const TransactionTile({super.key, required this.tx, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TxType.expense;
    final sign = isExpense ? -tx.amount : tx.amount;
    return ListTile(
      onTap: onTap,
      leading: CategoryAvatar(categoryId: tx.categoryId, categoryName: category?.name ?? ''),
      title: Text(tx.note?.isNotEmpty == true ? tx.note! : (isExpense ? 'Pengeluaran' : 'Pemasukan')),
      subtitle: Text([
        tx.occurredOn,
        if (tx.createdByName != null) '• ${tx.createdByName}',
        if (tx.source == 'recurring') '• tetap',
      ].join(' ')),
      trailing: Text(formatRupiah(sign), style: TextStyle(color: isExpense ? AppColors.expenseOnLight : AppColors.incomeOnLight)),
    );
  }
}
