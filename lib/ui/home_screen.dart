import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category_cubit.dart';
import '../blocs/dashboard_cubit.dart';
import '../blocs/month_bloc.dart';
import '../core/formatting.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import 'transaction_form_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/dot_grid_background.dart';
import 'widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance Ivan')),
      body: DotGridBackground(
        light: true,
        child: BlocBuilder<MonthBloc, MonthState>(
          builder: (context, month) {
            final categories = context.watch<CategoryCubit>().state.categories;
            Category? categoryFor(String id) {
              final matches = categories.where((c) => c.id == id);
              return matches.isEmpty ? null : matches.first;
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MonthBloc>().add(MonthRequested(month.ym));
                await context.read<DashboardCubit>().load(month.ym);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, dash) {
                      final d = dash.data;
                      if (d == null)
                        return const SizedBox(
                            height: 160,
                            child: Center(child: CircularProgressIndicator()));
                      return BalanceCard(
                          balance: d.balance, summary: d.summary);
                    },
                  ),
                  const SizedBox(height: 8),
                  _monthPicker(context, month.ym),
                  if (month.status == MonthStatus.loading)
                    const LinearProgressIndicator(),
                  ...month.transactions.map((t) => TransactionTile(
                        tx: t,
                        category: categoryFor(t.categoryId),
                        onTap: () => _openForm(context, existing: t),
                      )),
                  if (month.status == MonthStatus.loaded &&
                      month.transactions.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child: Text('Belum ada transaksi bulan ini'))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {Transaction? existing}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TransactionFormScreen(
        txRepo: context.read<TransactionRepository>(),
        existing: existing,
      ),
    ));
  }

  Widget _monthPicker(BuildContext context, String ym) {
    void go(int delta) {
      final next = addMonths(ym, delta);
      context.read<MonthBloc>().add(MonthRequested(next));
      context.read<DashboardCubit>().load(next);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () => go(-1), icon: const Icon(Icons.chevron_left)),
        Text(ym.isEmpty ? '' : monthLabel(ym),
            style: Theme.of(context).textTheme.titleMedium),
        IconButton(
            onPressed: () => go(1), icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
