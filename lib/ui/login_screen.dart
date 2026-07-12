import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 72),
              const SizedBox(height: 16),
              Text('Keuangan Keluarga', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final busy = state.status == AuthStatus.authenticating;
                  return FilledButton.icon(
                    key: const Key('google-signin'),
                    onPressed: busy ? null : () => context.read<AuthBloc>().add(AuthSignInRequested()),
                    icon: const Icon(Icons.login),
                    label: Text(busy ? 'Masuk...' : 'Masuk dengan Google'),
                  );
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => state.error == null
                    ? const SizedBox.shrink()
                    : Padding(padding: const EdgeInsets.only(top: 12), child: Text(state.error!, style: const TextStyle(color: Colors.red))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
