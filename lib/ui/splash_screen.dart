import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'widgets/dot_grid_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DotGridBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.textOnDark, size: 30),
                ),
              ),
              const SizedBox(height: 14),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                ),
                child: Text(
                  'Keuangan Keluarga',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textOnDark),
                ),
              ),
              const SizedBox(height: 4),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                ),
                child: const Text(
                  'Kelola keuangan keluarga, bareng-bareng',
                  style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              const _EqualizerLoader(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EqualizerLoader extends StatefulWidget {
  const _EqualizerLoader();

  @override
  State<_EqualizerLoader> createState() => _EqualizerLoaderState();
}

class _EqualizerLoaderState extends State<_EqualizerLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final t = (_controller.value + i * 0.15) % 1.0;
              final height = 8 + 22 * (0.5 - (t - 0.5).abs()) * 2;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 5,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimaryLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
