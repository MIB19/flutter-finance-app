import 'package:equatable/equatable.dart';

enum TxType { income, expense }

TxType txTypeFromString(String s) => s == 'income' ? TxType.income : TxType.expense;
String txTypeToString(TxType t) => t == TxType.income ? 'income' : 'expense';

class Category extends Equatable {
  final String id;
  final String familyId;
  final String name;
  final TxType type;
  final bool isPreset;

  const Category({required this.id, required this.familyId, required this.name, required this.type, required this.isPreset});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'] as String,
        familyId: j['family_id'] as String,
        name: j['name'] as String,
        type: txTypeFromString(j['type'] as String),
        isPreset: (j['is_preset'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [id, familyId, name, type, isPreset];
}
