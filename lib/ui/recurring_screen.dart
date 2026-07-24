import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/recurring_bloc.dart';
import '../core/formatting.dart';
import 'recurring_form_screen.dart';
import 'widgets/dot_grid_background.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Tetap'),
        actions: [
          IconButton(
            key: const Key('add-rule'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecurringFormScreen()),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: DotGridBackground(
        light: true,
        child: BlocBuilder<RecurringBloc, RecurringState>(
          builder: (context, state) {
            if (state.loading && state.rules.isEmpty)
              return const Center(child: CircularProgressIndicator());
            if (state.rules.isEmpty)
              return const Center(child: Text('Belum ada aturan tetap'));
            return ListView(
              children: state.rules
                  .map((r) => ListTile(
                        title: Text('${r.name} • ${formatRupiah(r.amount)}'),
                        subtitle: Text('Tiap tanggal ${r.dayOfMonth}'),
                        trailing: Switch(
                          value: r.active,
                          onChanged: (v) => context
                              .read<RecurringBloc>()
                              .add(RecurringToggled(r.id, v)),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => RecurringFormScreen(existing: r)),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
