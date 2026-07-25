import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/category_breakdown.dart';
import 'package:keuangan_app/ui/widgets/donut_chart.dart';

void main() {
  testWidgets('renders without error for non-empty data', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DonutChart(data: [
        CategoryBreakdown(categoryId: 'c1', categoryName: 'Gaji', total: 8000000, percent: 0.8),
        CategoryBreakdown(categoryId: 'c2', categoryName: 'Freelance', total: 2000000, percent: 0.2),
      ]),
    ));

    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders an empty-state ring without error for empty data', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DonutChart(data: [])));

    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
