import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/family_repository.dart';

class FamilyState extends Equatable {
  final bool loading;
  final FamilyInfo? info;
  final String? error;
  const FamilyState({this.loading = false, this.info, this.error});

  @override
  List<Object?> get props => [loading, info?.family.id, info?.inviteCode, info?.members.length, error];
}

class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepository _repo;
  FamilyCubit(this._repo) : super(const FamilyState());

  Future<void> load() async {
    emit(const FamilyState(loading: true));
    try {
      emit(FamilyState(info: await _repo.me()));
    } catch (e) {
      emit(FamilyState(error: e.toString()));
    }
  }
}
