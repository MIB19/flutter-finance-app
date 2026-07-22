import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/category_breakdown.dart';
import '../../theme/app_colors.dart';

class DonutChart extends StatelessWidget {
  final List<CategoryBreakdown> data;
  final double size;
  const DonutChart({super.key, required this.data, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DonutPainter(data, AppColors.categoryPalette)),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<CategoryBreakdown> data;
  final List<Color> palette;
  _DonutPainter(this.data, this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(8);
    final strokeWidth = size.width * 0.16;

    if (data.isEmpty) {
      final paint = Paint()
        ..color = AppColors.textOnDarkMuted.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    var start = -math.pi / 2;
    for (var i = 0; i < data.length; i++) {
      final sweep = data[i].percent * 2 * math.pi;
      final paint = Paint()
        ..color = palette[i % palette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.data != data;
}
