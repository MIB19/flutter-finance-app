import 'package:equatable/equatable.dart';
import 'category.dart';

class Transaction extends Equatable {
  final String id;
  final String familyId;
  final String categoryId;
  final String? createdBy;
  final String? createdByName;
  final int amount;
  final TxType type;
  final String? note;
  final String occurredOn;
  final String source;

  const Transaction({
    required this.id, required this.familyId, required this.categoryId,
    required this.createdBy, required this.createdByName, required this.amount,
    required this.type, required this.note, required this.occurredOn, required this.source,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as String,
        familyId: j['family_id'] as String,
        categoryId: j['category_id'] as String,
        createdBy: j['created_by'] as String?,
        createdByName: j['created_by_name'] as String?,
        amount: (j['amount'] as num).toInt(),
        type: txTypeFromString(j['type'] as String),
        note: j['note'] as String?,
        occurredOn: (j['occurred_on'] as String).substring(0, 10),
        source: j['source'] as String,
      );

  @override
  List<Object?> get props => [id, familyId, categoryId, createdBy, createdByName, amount, type, note, occurredOn, source];
}
