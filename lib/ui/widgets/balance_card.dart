import 'package:flutter/material.dart';
import '../../core/formatting.dart';
import '../../models/month_summary.dart';
import '../../theme/app_colors.dart';
import 'dot_grid_background.dart';

/// Hero balance card. Per design spec, the reference's four action buttons
/// (Transfer/Withdraw/Invest/Top up) are dropped — this app has no such
/// features; the real "add transaction" action lives in the bottom-nav FAB.
class BalanceCard extends StatelessWidget {
  final int balance;
  final MonthSummary summary;
  const BalanceCard({super.key, required this.balance, required this.summary});

  @override
  Widget build(BuildContext context) {
    return DotGridBackground(
      borderRadius: 24,
      expand: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('YOUR BALANCE',
                style:
                    TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
            const SizedBox(height: 6),
            Text(
              formatRupiah(balance),
              key: const Key('balance-value'),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.textOnDark),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _mini('Masuk', summary.income, Colors.greenAccent)),
                Expanded(
                    child: _mini('Keluar', summary.expense, Colors.redAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, int value, Color valueColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textOnDarkMuted, fontSize: 12)),
          Text(formatRupiah(value),
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      );
}
