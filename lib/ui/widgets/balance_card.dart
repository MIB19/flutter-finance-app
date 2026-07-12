import 'package:flutter/material.dart';
import '../../core/formatting.dart';
import '../../models/month_summary.dart';

class BalanceCard extends StatelessWidget {
  final int balance;
  final MonthSummary summary;
  const BalanceCard({super.key, required this.balance, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo aktual'),
            const SizedBox(height: 4),
            Text(formatRupiah(balance),
                key: const Key('balance-value'),
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _mini('Masuk', summary.income, Colors.green)),
                Expanded(child: _mini('Keluar', summary.expense, Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, int value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(label), Text(formatRupiah(value), style: TextStyle(color: color))],
      );
}
