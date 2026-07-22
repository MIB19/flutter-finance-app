import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/ui/widgets/category_avatar.dart';

void main() {
  group('categoryAvatarColor', () {
    test('is deterministic for the same category id', () {
      expect(categoryAvatarColor('cat-1'), categoryAvatarColor('cat-1'));
    });

    test('differs for different ids (not guaranteed, but true for these two)', () {
      expect(categoryAvatarColor('cat-1'), isNot(categoryAvatarColor('cat-2')));
    });
  });

  testWidgets('CategoryAvatar shows the uppercased first letter', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CategoryAvatar(categoryId: 'c1', categoryName: 'gaji'),
    ));

    expect(find.text('G'), findsOneWidget);
  });

  testWidgets('CategoryAvatar falls back to ? for an empty name', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CategoryAvatar(categoryId: 'c1', categoryName: ''),
    ));

    expect(find.text('?'), findsOneWidget);
  });
}
