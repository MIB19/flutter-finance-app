import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_cubit.dart';
import '../blocs/month_bloc.dart';
import '../core/category_breakdown.dart';
import '../core/formatting.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';
import 'widgets/dot_grid_background.dart';
import 'widgets/donut_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  TxType _type = TxType.expense;

  @override
  Widget build(BuildContext context) {
    final month = context.watch<MonthBloc>().state;
    final categories = context.watch<CategoryCubit>().state.categories;
    final breakdown = computeBreakdown(
        transactions: month.transactions, categories: categories, type: _type);
    final total = breakdown.fold<int>(0, (a, b) => a + b.total);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DotGridBackground(
              borderRadius: 24,
              expand: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                child: Column(
                  children: [
                    SegmentedButton<TxType>(
                      key: const Key('stats-type-toggle'),
                      segments: const [
                        ButtonSegment(
                            value: TxType.income, label: Text('Income')),
                        ButtonSegment(
                            value: TxType.expense, label: Text('Expense')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) =>
                          setState(() => _type = s.first),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        DonutChart(data: breakdown),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _type == TxType.income
                                  ? 'TOTAL INCOME'
                                  : 'TOTAL EXPENSE',
                              style: const TextStyle(
                                  color: AppColors.textOnDarkMuted,
                                  fontSize: 11),
                            ),
                            Text(
                              formatRupiah(total),
                              key: const Key('stats-total'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (month.status == MonthStatus.loading)
              const LinearProgressIndicator(),
            Text(
              _type == TxType.income ? 'Income Breakdown' : 'Expense Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (breakdown.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Belum ada data bulan ini')),
              ),
            ...breakdown.map((b) => ListTile(
                  title: Text(b.categoryName),
                  subtitle: Text(formatRupiah(b.total)),
                  trailing: Text('${(b.percent * 100).round()}%'),
                )),
          ],
        ),
      ),
    );
  }
}
