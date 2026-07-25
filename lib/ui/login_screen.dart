import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';
import '../theme/app_colors.dart';
import 'widgets/dot_grid_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DotGridBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: AppColors.accentPrimary, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.textOnDark, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Finance Ivan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textOnDark),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final busy = state.status == AuthStatus.authenticating;
                    return FilledButton.icon(
                      key: const Key('google-signin'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.accentPrimary, foregroundColor: Colors.white),
                      onPressed: busy ? null : () => context.read<AuthBloc>().add(AuthSignInRequested()),
                      icon: const Icon(Icons.login),
                      label: Text(busy ? 'Masuk...' : 'Masuk dengan Google'),
                    );
                  },
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => state.error == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
