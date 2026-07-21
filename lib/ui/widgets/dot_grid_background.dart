import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Wraps [child] in the dark hero surface with a faded dot-grid mesh pattern
/// (see design spec). Used by the splash screen, balance card, and Stats header.
class DotGridBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  const DotGridBackground({super.key, required this.child, this.borderRadius = 0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.bgHero)),
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
          child,
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = AppColors.accentPrimaryLight.withValues(alpha: 0.35);
    const spacing = 16.0;
    for (double y = -4; y < size.height; y += spacing) {
      for (double x = -4; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
    final fadePaint = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.bgHero.withValues(alpha: 0), AppColors.bgHero],
        stops: const [0.0, 0.85],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fadePaint);
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}
