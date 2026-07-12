import '../core/api_client.dart';
import '../models/category.dart';
import '../models/recurring_rule.dart';

class RecurringRepository {
  final ApiClient _api;
  RecurringRepository(this._api);

  Future<List<RecurringRule>> list() async {
    final data = await _api.getJsonList('/recurring');
    return data.map((e) => RecurringRule.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RecurringRule> create({
    required String categoryId, required String name, required int amount,
    required TxType type, required int dayOfMonth, required String startMonth, String? endMonth,
  }) async {
    final json = await _api.postJson('/recurring', {
      'categoryId': categoryId, 'name': name, 'amount': amount, 'type': txTypeToString(type),
      'dayOfMonth': dayOfMonth, 'startMonth': startMonth, 'endMonth': endMonth,
    });
    return RecurringRule.fromJson(json);
  }

  Future<RecurringRule> update(String id, Map<String, dynamic> patch) async =>
      RecurringRule.fromJson(await _api.patchJson('/recurring/$id', patch));

  Future<void> remove(String id) => _api.delete('/recurring/$id');
}
