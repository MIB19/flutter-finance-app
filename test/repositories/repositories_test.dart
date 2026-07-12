import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:keuangan_app/core/api_client.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/repositories/category_repository.dart';
import 'package:keuangan_app/repositories/transaction_repository.dart';
import 'package:keuangan_app/repositories/finance_repository.dart';
import 'package:keuangan_app/repositories/onboarding_repository.dart';

ApiClient makeClient(DioAdapter Function(Dio) attach) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
  attach(dio);
  return ApiClient(dio: dio, getToken: () async => 'tok');
}

void main() {
  test('CategoryRepository.list parses categories', () async {
    late DioAdapter a;
    final client = makeClient((d) {
      a = DioAdapter(dio: d);
      return a;
    });
    a.onGet('/categories', (s) => s.reply(200, [
          {'id': 'c1', 'family_id': 'f1', 'name': 'Makan', 'type': 'expense', 'is_preset': true, 'created_at': 'x'},
        ]));
    final cats = await CategoryRepository(client).list();
    expect(cats.single.name, 'Makan');
  });

  test('TransactionRepository.create posts and parses', () async {
    late DioAdapter a;
    final client = makeClient((d) {
      a = DioAdapter(dio: d);
      return a;
    });
    a.onPost(
        '/transactions',
        (s) => s.reply(201, {
              'id': 't1',
              'family_id': 'f1',
              'category_id': 'c1',
              'created_by': 'u1',
              'created_by_name': 'Ivan',
              'amount': 50000,
              'type': 'expense',
              'note': null,
              'occurred_on': '2026-07-05',
              'month_key': '2026-07-01',
              'source': 'manual',
              'recurring_rule_id': null,
              'created_at': 'x',
            }),
        data: {'categoryId': 'c1', 'amount': 50000, 'type': 'expense', 'occurredOn': '2026-07-05', 'note': null});
    final tx = await TransactionRepository(client)
        .create(categoryId: 'c1', amount: 50000, type: TxType.expense, occurredOn: '2026-07-05', note: null);
    expect(tx.amount, 50000);
  });

  test('FinanceRepository.month parses summary + transactions', () async {
    late DioAdapter a;
    final client = makeClient((d) {
      a = DioAdapter(dio: d);
      return a;
    });
    a.onGet('/months/2026-07', (s) => s.reply(200, {
          'summary': {'income': 0, 'expense': 3000000},
          'transactions': [
            {
              'id': 't1',
              'family_id': 'f1',
              'category_id': 'c1',
              'created_by': null,
              'created_by_name': null,
              'amount': 3000000,
              'type': 'expense',
              'note': 'Sewa',
              'occurred_on': '2026-07-01',
              'month_key': '2026-07-01',
              'source': 'recurring',
              'recurring_rule_id': 'r1',
              'created_at': 'x',
            },
          ],
        }));
    final res = await FinanceRepository(client).month('2026-07');
    expect(res.summary.expense, 3000000);
    expect(res.transactions.single.source, 'recurring');
  });

  test('OnboardingRepository.bootstrap detects needsOnboarding', () async {
    late DioAdapter a;
    final client = makeClient((d) {
      a = DioAdapter(dio: d);
      return a;
    });
    a.onPost('/auth/bootstrap', (s) => s.reply(200, {'needsOnboarding': true}), data: {});
    expect(await OnboardingRepository(client).needsOnboarding(), true);
  });
}
