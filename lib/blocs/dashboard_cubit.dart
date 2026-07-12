import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dashboard.dart';
import '../repositories/finance_repository.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final Dashboard? data;
  final String? error;
  const DashboardState._(this.status, this.data, this.error);

  const DashboardState.initial() : this._(DashboardStatus.initial, null, null);
  const DashboardState.loading() : this._(DashboardStatus.loading, null, null);
  const DashboardState.loaded(Dashboard d) : this._(DashboardStatus.loaded, d, null);
  const DashboardState.failure(String e) : this._(DashboardStatus.failure, null, e);

  @override
  List<Object?> get props => [status, data, error];
}

class DashboardCubit extends Cubit<DashboardState> {
  final FinanceRepository _repo;
  DashboardCubit(this._repo) : super(const DashboardState.initial());

  Future<void> load(String ym) async {
    emit(const DashboardState.loading());
    try {
      emit(DashboardState.loaded(await _repo.dashboard(ym)));
    } catch (e) {
      emit(DashboardState.failure(e.toString()));
    }
  }
}
