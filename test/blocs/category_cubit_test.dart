import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/blocs/category_cubit.dart';
import 'package:keuangan_app/models/category.dart';
import 'package:keuangan_app/repositories/category_repository.dart';

class MockCategoryRepo extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepo repo;
  setUpAll(() {
    registerFallbackValue(TxType.expense);
  });
  setUp(() => repo = MockCategoryRepo());

  blocTest<CategoryCubit, CategoryState>(
    'load -> loaded list',
    build: () {
      when(() => repo.list()).thenAnswer((_) async => const [
        Category(id: 'c1', familyId: 'f1', name: 'Makan', type: TxType.expense, isPreset: true),
      ]);
      return CategoryCubit(repo);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<CategoryState>().having((s) => s.loading, 'loading', true),
      isA<CategoryState>().having((s) => s.categories.length, 'count', 1),
    ],
  );

  blocTest<CategoryCubit, CategoryState>(
    'add -> appends and reloads',
    build: () {
      when(() => repo.create(name: any(named: 'name'), type: any(named: 'type')))
          .thenAnswer((_) async => const Category(id: 'c2', familyId: 'f1', name: 'Kopi', type: TxType.expense, isPreset: false));
      when(() => repo.list()).thenAnswer((_) async => const [
        Category(id: 'c2', familyId: 'f1', name: 'Kopi', type: TxType.expense, isPreset: false),
      ]);
      return CategoryCubit(repo);
    },
    act: (c) => c.add('Kopi', TxType.expense),
    expect: () => [
      isA<CategoryState>().having((s) => s.loading, 'loading', true),
      isA<CategoryState>().having((s) => s.categories.single.name, 'name', 'Kopi'),
    ],
  );
}
