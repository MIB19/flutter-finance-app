import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryState extends Equatable {
  final bool loading;
  final List<Category> categories;
  final String? error;
  const CategoryState({this.loading = false, this.categories = const [], this.error});

  @override
  List<Object?> get props => [loading, categories, error];
}

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo;
  CategoryCubit(this._repo) : super(const CategoryState());

  Future<void> load() async {
    emit(const CategoryState(loading: true));
    try {
      emit(CategoryState(categories: await _repo.list()));
    } catch (e) {
      emit(CategoryState(error: e.toString()));
    }
  }

  Future<void> add(String name, TxType type) async {
    emit(const CategoryState(loading: true));
    try {
      await _repo.create(name: name, type: type);
      emit(CategoryState(categories: await _repo.list()));
    } catch (e) {
      emit(CategoryState(error: e.toString()));
    }
  }
}
