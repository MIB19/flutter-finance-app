import 'package:equatable/equatable.dart';

class Family extends Equatable {
  final String id;
  final String name;
  final String? inviteCode;
  const Family({required this.id, required this.name, required this.inviteCode});

  factory Family.fromJson(Map<String, dynamic> j) =>
      Family(id: j['id'] as String, name: j['name'] as String, inviteCode: j['invite_code'] as String?);

  @override
  List<Object?> get props => [id, name, inviteCode];
}

class Member extends Equatable {
  final String id;
  final String? displayName;
  final String? email;
  const Member({required this.id, required this.displayName, required this.email});

  factory Member.fromJson(Map<String, dynamic> j) =>
      Member(id: j['id'] as String, displayName: j['display_name'] as String?, email: j['email'] as String?);

  @override
  List<Object?> get props => [id, displayName, email];
}
