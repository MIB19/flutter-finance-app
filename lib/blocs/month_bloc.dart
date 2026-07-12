import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/month_summary.dart';
import '../models/transaction.dart';
import '../repositories/finance_repository.dart';
import '../repositories/transaction_repository.dart';

enum MonthStatus { initial, loading, loaded, failure }

class MonthState extends Equatable {
  final MonthStatus status;
  final String ym;
  final List<Transaction> transactions;
  final MonthSummary summary;
  final String? error;

  const MonthState({
    required this.status,
    required this.ym,
    this.transactions = const [],
    this.summary = const MonthSummary(income: 0, expense: 0),
    this.error,
  });

  const MonthState.initial() : this(status: MonthStatus.initial, ym: '');

  MonthState copyWith({MonthStatus? status, String? ym, List<Transaction>? transactions, MonthSummary? summary, String? error}) =>
      MonthState(
        status: status ?? this.status,
        ym: ym ?? this.ym,
        transactions: transactions ?? this.transactions,
        summary: summary ?? this.summary,
        error: error,
      );

  @override
  List<Object?> get props => [status, ym, transactions, summary, error];
}

abstract class MonthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MonthRequested extends MonthEvent {
  final String ym;
  MonthRequested(this.ym);
  @override
  List<Object?> get props => [ym];
}

class TransactionDeleted extends MonthEvent {
  final String id;
  TransactionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class MonthBloc extends Bloc<MonthEvent, MonthState> {
  final FinanceRepository _finance;
  final TransactionRepository _txRepo;

  MonthBloc({required FinanceRepository finance, required TransactionRepository txRepo})
      : _finance = finance,
        _txRepo = txRepo,
        super(const MonthState.initial()) {
    on<MonthRequested>(_onRequested);
    on<TransactionDeleted>(_onDeleted);
  }

  Future<void> _load(String ym, Emitter<MonthState> emit) async {
    emit(state.copyWith(status: MonthStatus.loading, ym: ym));
    try {
      final data = await _finance.month(ym);
      emit(state.copyWith(status: MonthStatus.loaded, ym: ym, transactions: data.transactions, summary: data.summary));
    } catch (e) {
      emit(state.copyWith(status: MonthStatus.failure, ym: ym, error: e.toString()));
    }
  }

  Future<void> _onRequested(MonthRequested e, Emitter<MonthState> emit) => _load(e.ym, emit);

  Future<void> _onDeleted(TransactionDeleted e, Emitter<MonthState> emit) async {
    await _txRepo.remove(e.id);
    await _load(state.ym, emit);
  }
}
