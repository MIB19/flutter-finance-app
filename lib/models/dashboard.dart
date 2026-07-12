import 'package:equatable/equatable.dart';
import 'month_summary.dart';

class Dashboard extends Equatable {
  final int balance;
  final MonthSummary summary;
  const Dashboard({required this.balance, required this.summary});

  factory Dashboard.fromJson(Map<String, dynamic> j) => Dashboard(
        balance: (j['balance'] as num).toInt(),
        summary: MonthSummary.fromJson(j['currentMonthSummary'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [balance, summary];
}
