import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/ui/widgets/balance_card.dart';

void main() {
  testWidgets('shows the formatted balance and income/expense summary', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BalanceCard(balance: 1500000, summary: MonthSummary(income: 8000000, expense: 6500000)),
    ));

    expect(find.byKey(const Key('balance-value')), findsOneWidget);
    expect(find.textContaining('8.000.000'), findsOneWidget);
    expect(find.textContaining('6.500.000'), findsOneWidget);
  });
}
