import '../core/api_client.dart';
import '../models/family.dart';

class OnboardingRepository {
  final ApiClient _api;
  OnboardingRepository(this._api);

  Future<bool> needsOnboarding() async {
    final json = await _api.postJson('/auth/bootstrap', {});
    return (json['needsOnboarding'] as bool?) ?? false;
  }

  Future<Family> createFamily({String? name, required String displayName}) async {
    final json = await _api.postJson('/families', {'name': name, 'displayName': displayName});
    return Family.fromJson(json['family'] as Map<String, dynamic>);
  }

  Future<Family> joinFamily({required String code, required String displayName}) async {
    final json = await _api.postJson('/families/join', {'code': code, 'displayName': displayName});
    return Family.fromJson(json['family'] as Map<String, dynamic>);
  }
}
