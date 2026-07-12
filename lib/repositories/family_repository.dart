import '../core/api_client.dart';
import '../models/family.dart';

class FamilyInfo {
  final Family family;
  final String? inviteCode;
  final List<Member> members;
  FamilyInfo(this.family, this.inviteCode, this.members);
}

class FamilyRepository {
  final ApiClient _api;
  FamilyRepository(this._api);

  Future<FamilyInfo> me() async {
    final json = await _api.getJson('/families/me');
    final members = (json['members'] as List? ?? [])
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
    return FamilyInfo(Family.fromJson(json['family'] as Map<String, dynamic>), json['invite_code'] as String?, members);
  }
}
