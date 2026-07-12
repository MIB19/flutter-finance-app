import '../core/api_client.dart';
import '../models/dashboard.dart';
import '../models/month_summary.dart';
import '../models/transaction.dart';

class MonthData {
  final MonthSummary summary;
  final List<Transaction> transactions;
  MonthData(this.summary, this.transactions);
}

class FinanceRepository {
  final ApiClient _api;
  FinanceRepository(this._api);

  Future<Dashboard> dashboard(String ym) async =>
      Dashboard.fromJson(await _api.getJson('/dashboard?month=$ym'));

  Future<MonthData> month(String ym) async {
    final json = await _api.getJson('/months/$ym');
    final txs = (json['transactions'] as List)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    return MonthData(MonthSummary.fromJson(json['summary'] as Map<String, dynamic>), txs);
  }
}
