import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/month_bloc.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/models/month_summary.dart';
import 'package:keuangan_app/models/transaction.dart';
import 'package:keuangan_app/repositories/finance_repository.dart';
import 'package:keuangan_app/repositories/transaction_repository.dart';

class MockFinanceRepo extends Mock implements FinanceRepository {}
class MockTxRepo extends Mock implements TransactionRepository {}

Transaction _tx(String id, int amount) => Transaction(
  id: id, familyId: 'f1', categoryId: 'c1', createdBy: 'u1', createdByName: 'Ivan',
  amount: amount, type: TxType.expense, note: null, occurredOn: '2026-07-05', source: 'manual');

void main() {
  late MockFinanceRepo finance;
  late MockTxRepo txRepo;
  setUp(() {
    finance = MockFinanceRepo();
    txRepo = MockTxRepo();
  });

  blocTest<MonthBloc, MonthState>(
    'MonthRequested loads month',
    build: () {
      when(() => finance.month('2026-07')).thenAnswer(
        (_) async => MonthData(const MonthSummary(income: 0, expense: 50000), [_tx('t1', 50000)]),
      );
      return MonthBloc(finance: finance, txRepo: txRepo);
    },
    act: (b) => b.add(MonthRequested('2026-07')),
    expect: () => [
      isA<MonthState>().having((s) => s.status, 'status', MonthStatus.loading),
      isA<MonthState>().having((s) => s.transactions.length, 'count', 1).having((s) => s.ym, 'ym', '2026-07'),
    ],
  );

  blocTest<MonthBloc, MonthState>(
    'TransactionDeleted removes then reloads',
    build: () {
      when(() => txRepo.remove('t1')).thenAnswer((_) async {});
      when(() => finance.month('2026-07')).thenAnswer(
        (_) async => MonthData(const MonthSummary(income: 0, expense: 0), const []),
      );
      return MonthBloc(finance: finance, txRepo: txRepo);
    },
    seed: () => MonthState(status: MonthStatus.loaded, ym: '2026-07', transactions: [_tx('t1', 50000), _tx('t2', 20000)], summary: const MonthSummary(income: 0, expense: 70000)),
    act: (b) => b.add(TransactionDeleted('t1')),
    expect: () => [
      isA<MonthState>().having((s) => s.status, 'status', MonthStatus.loading),
      isA<MonthState>().having((s) => s.transactions.length, 'count', 0),
    ],
    verify: (_) => verify(() => txRepo.remove('t1')).called(1),
  );
}
