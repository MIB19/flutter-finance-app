import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/recurring_bloc.dart';
import '../core/formatting.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengeluaran Tetap')),
      body: BlocBuilder<RecurringBloc, RecurringState>(
        builder: (context, state) {
          if (state.loading && state.rules.isEmpty) return const Center(child: CircularProgressIndicator());
          if (state.rules.isEmpty) return const Center(child: Text('Belum ada aturan tetap'));
          return ListView(
            children: state.rules.map((r) => SwitchListTile(
              title: Text('${r.name} • ${formatRupiah(r.amount)}'),
              subtitle: Text('Tiap tanggal ${r.dayOfMonth}'),
              value: r.active,
              onChanged: (v) => context.read<RecurringBloc>().add(RecurringToggled(r.id, v)),
            )).toList(),
          );
        },
      ),
    );
  }
}
