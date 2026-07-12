import '../core/api_client.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final ApiClient _api;
  TransactionRepository(this._api);

  Future<Transaction> create({
    required String categoryId,
    required int amount,
    required TxType type,
    required String occurredOn,
    String? note,
  }) async {
    final json = await _api.postJson('/transactions', {
      'categoryId': categoryId, 'amount': amount, 'type': txTypeToString(type),
      'occurredOn': occurredOn, 'note': note,
    });
    return Transaction.fromJson(json);
  }

  Future<Transaction> update(String id, Map<String, dynamic> patch) async {
    final json = await _api.patchJson('/transactions/$id', patch);
    return Transaction.fromJson(json);
  }

  Future<void> remove(String id) => _api.delete('/transactions/$id');
}
