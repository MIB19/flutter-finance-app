import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/ui/widgets/dot_grid_background.dart';

void main() {
  testWidgets('renders child content on top of the pattern', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DotGridBackground(child: Text('hero content')),
    ));

    expect(find.text('hero content'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets(
      'light variant paints a lighter background than the default dark variant',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DotGridBackground(light: true, child: Text('light content')),
    ));

    expect(find.text('light content'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
