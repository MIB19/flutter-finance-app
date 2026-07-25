import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Wraps [child] in a dot-grid mesh pattern background. Defaults to the dark
/// hero variant (used by the splash screen, balance card, and Stats header).
/// Pass [light]: true for the lighter, subtler variant used as the general
/// screen background on every other screen (Home, Recurring, Family, forms,
/// onboarding) — same pattern language, different palette, so the whole app
/// reads as one cohesive design rather than "dark cards on a plain white app."
class DotGridBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool light;
  final bool expand;
  const DotGridBackground(
      {super.key,
      required this.child,
      this.borderRadius = 0,
      this.light = false,
      this.expand = true});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(
              child: Container(
                  color: light ? AppColors.bgLight : AppColors.bgHero)),
          Positioned.fill(
              child: CustomPaint(painter: _DotGridPainter(light: light))),
          expand ? Positioned.fill(child: child) : child,
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final bool light;
  const _DotGridPainter({required this.light});

  @override
  void paint(Canvas canvas, Size size) {
    final dotColor = light
        ? AppColors.accentPrimary.withValues(alpha: 0.18)
        : AppColors.accentPrimaryLight.withValues(alpha: 0.35);
    final dotPaint = Paint()..color = dotColor;
    const spacing = 16.0;
    for (double y = -4; y < size.height; y += spacing) {
      for (double x = -4; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
    if (!light) {
      final fadePaint = Paint()
        ..shader = RadialGradient(
          colors: [AppColors.bgHero.withValues(alpha: 0), AppColors.bgHero],
          stops: const [0.0, 0.85],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fadePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.light != light;
}
