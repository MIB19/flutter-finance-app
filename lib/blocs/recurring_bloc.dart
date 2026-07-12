import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/category.dart';
import '../models/recurring_rule.dart';
import '../repositories/recurring_repository.dart';

class RecurringState extends Equatable {
  final bool loading;
  final List<RecurringRule> rules;
  final String? error;
  const RecurringState({this.loading = false, this.rules = const [], this.error});

  @override
  List<Object?> get props => [loading, rules, error];
}

abstract class RecurringEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecurringRequested extends RecurringEvent {}

class RecurringToggled extends RecurringEvent {
  final String id;
  final bool active;
  RecurringToggled(this.id, this.active);
  @override
  List<Object?> get props => [id, active];
}

class RecurringCreated extends RecurringEvent {
  final String categoryId;
  final String name;
  final int amount;
  final TxType type;
  final int dayOfMonth;
  final String startMonth;
  RecurringCreated({required this.categoryId, required this.name, required this.amount, required this.type, required this.dayOfMonth, required this.startMonth});
  @override
  List<Object?> get props => [categoryId, name, amount, type, dayOfMonth, startMonth];
}

class RecurringDeleted extends RecurringEvent {
  final String id;
  RecurringDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringRepository _repo;

  RecurringBloc(this._repo) : super(const RecurringState()) {
    on<RecurringRequested>((_, emit) async {
      emit(const RecurringState(loading: true));
      await _reload(emit);
    });
    on<RecurringToggled>((e, emit) async {
      emit(const RecurringState(loading: true));
      await _repo.update(e.id, {'active': e.active});
      await _reload(emit);
    });
    on<RecurringCreated>((e, emit) async {
      emit(const RecurringState(loading: true));
      await _repo.create(categoryId: e.categoryId, name: e.name, amount: e.amount, type: e.type, dayOfMonth: e.dayOfMonth, startMonth: e.startMonth);
      await _reload(emit);
    });
    on<RecurringDeleted>((e, emit) async {
      emit(const RecurringState(loading: true));
      await _repo.remove(e.id);
      await _reload(emit);
    });
  }

  Future<void> _reload(Emitter<RecurringState> emit) async {
    try {
      emit(RecurringState(rules: await _repo.list()));
    } catch (e) {
      emit(RecurringState(error: e.toString()));
    }
  }
}
