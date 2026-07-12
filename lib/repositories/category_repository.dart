import '../core/api_client.dart';
import '../models/category.dart';

class CategoryRepository {
  final ApiClient _api;
  CategoryRepository(this._api);

  Future<List<Category>> list() async {
    final data = await _api.getJsonList('/categories');
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Category> create({required String name, required TxType type}) async {
    final json = await _api.postJson('/categories', {'name': name, 'type': txTypeToString(type)});
    return Category.fromJson(json);
  }
}
