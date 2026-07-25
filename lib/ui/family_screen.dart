import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../blocs/family_cubit.dart';
import 'widgets/dot_grid_background.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keluarga')),
      body: DotGridBackground(
        light: true,
        child: BlocBuilder<FamilyCubit, FamilyState>(
          builder: (context, state) {
            if (state.loading || state.info == null)
              return const Center(child: CircularProgressIndicator());
            final info = state.info!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                    title: const Text('Nama keluarga'),
                    subtitle: Text(info.family.name)),
                ListTile(
                  title: const Text('Kode undangan'),
                  subtitle: Text(info.inviteCode ?? '-'),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: info.inviteCode == null
                        ? null
                        : () => Clipboard.setData(
                            ClipboardData(text: info.inviteCode!)),
                  ),
                ),
                const Divider(),
                const Padding(
                    padding: EdgeInsets.all(8), child: Text('Anggota')),
                ...info.members.map((m) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(m.displayName ?? m.email ?? m.id))),
                const Divider(),
                TextButton.icon(
                  onPressed: () =>
                      context.read<AuthBloc>().add(AuthSignOutRequested()),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
