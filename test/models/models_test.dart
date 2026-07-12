import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/transaction.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/models/dashboard.dart';
import 'package:keuangan_app/models/recurring_rule.dart';
import 'package:keuangan_app/models/family.dart';

void main() {
  test('Category.fromJson', () {
    final c = Category.fromJson({'id': 'c1', 'family_id': 'f1', 'name': 'Makan', 'type': 'expense', 'is_preset': true, 'created_at': 'x'});
    expect(c.name, 'Makan');
    expect(c.type, TxType.expense);
    expect(c.isPreset, true);
  });

  test('Transaction.fromJson parses amount as int and author name', () {
    final t = Transaction.fromJson({
      'id': 't1', 'family_id': 'f1', 'category_id': 'c1', 'created_by': 'u1', 'created_by_name': 'Ivan',
      'amount': 50000, 'type': 'expense', 'note': 'nasi', 'occurred_on': '2026-07-05',
      'month_key': '2026-07-01', 'source': 'manual', 'recurring_rule_id': null, 'created_at': 'x',
    });
    expect(t.amount, 50000);
    expect(t.createdByName, 'Ivan');
    expect(t.type, TxType.expense);
  });

  test('MonthSummary.net', () {
    const s = MonthSummary(income: 1000000, expense: 300000);
    expect(s.net, 700000);
  });

  test('Dashboard.fromJson', () {
    final d = Dashboard.fromJson({'balance': -3000000, 'currentMonthSummary': {'income': 0, 'expense': 3000000}});
    expect(d.balance, -3000000);
    expect(d.summary.expense, 3000000);
  });

  test('RecurringRule.fromJson', () {
    final r = RecurringRule.fromJson({
      'id': 'r1', 'family_id': 'f1', 'category_id': 'c1', 'name': 'Sewa', 'amount': 3000000, 'type': 'expense',
      'day_of_month': 1, 'active': true, 'start_month': '2026-01-01', 'end_month': null, 'created_at': 'x',
    });
    expect(r.name, 'Sewa');
    expect(r.dayOfMonth, 1);
    expect(r.active, true);
  });

  test('Family + Member fromJson', () {
    final f = Family.fromJson({'id': 'f1', 'name': 'Rumah', 'invite_code': 'ABC234'});
    expect(f.inviteCode, 'ABC234');
    final m = Member.fromJson({'id': 'u1', 'display_name': 'Ivan', 'email': 'a@b.com'});
    expect(m.displayName, 'Ivan');
  });
}
