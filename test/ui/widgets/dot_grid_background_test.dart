import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/theme/app_colors.dart';
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
      'light variant uses a lighter background color than the dark variant',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DotGridBackground(light: true, child: Text('light content')),
    ));
    expect(find.text('light content'), findsOneWidget);

    final lightContainer =
        tester.widgetList<Container>(find.byType(Container)).first;
    expect(lightContainer.color, AppColors.bgLight);

    await tester.pumpWidget(const MaterialApp(
      home: DotGridBackground(child: Text('dark content')),
    ));
    expect(find.text('dark content'), findsOneWidget);

    final darkContainer =
        tester.widgetList<Container>(find.byType(Container)).first;
    expect(darkContainer.color, AppColors.bgHero);
  });
}
