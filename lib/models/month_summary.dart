import 'package:equatable/equatable.dart';

class MonthSummary extends Equatable {
  final int income;
  final int expense;
  const MonthSummary({required this.income, required this.expense});

  int get net => income - expense;

  factory MonthSummary.fromJson(Map<String, dynamic> j) =>
      MonthSummary(income: (j['income'] as num).toInt(), expense: (j['expense'] as num).toInt());

  @override
  List<Object?> get props => [income, expense];
}
