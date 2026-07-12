import 'package:equatable/equatable.dart';
import 'category.dart';

class RecurringRule extends Equatable {
  final String id;
  final String familyId;
  final String categoryId;
  final String name;
  final int amount;
  final TxType type;
  final int dayOfMonth;
  final bool active;
  final String startMonth;
  final String? endMonth;

  const RecurringRule({
    required this.id, required this.familyId, required this.categoryId, required this.name,
    required this.amount, required this.type, required this.dayOfMonth, required this.active,
    required this.startMonth, required this.endMonth,
  });

  factory RecurringRule.fromJson(Map<String, dynamic> j) => RecurringRule(
        id: j['id'] as String,
        familyId: j['family_id'] as String,
        categoryId: j['category_id'] as String,
        name: j['name'] as String,
        amount: (j['amount'] as num).toInt(),
        type: txTypeFromString(j['type'] as String),
        dayOfMonth: (j['day_of_month'] as num).toInt(),
        active: (j['active'] as bool?) ?? true,
        startMonth: (j['start_month'] as String).substring(0, 10),
        endMonth: j['end_month'] == null ? null : (j['end_month'] as String).substring(0, 10),
      );

  @override
  List<Object?> get props => [id, familyId, categoryId, name, amount, type, dayOfMonth, active, startMonth, endMonth];
}
