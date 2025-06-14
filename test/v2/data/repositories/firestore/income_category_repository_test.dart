import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/income_category_repository.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_category_service.dart';
import 'package:household_accounts/v2/data/models/income_category_model.dart' as data;
import 'package:household_accounts/v2/domain/models/income_category.dart';
import 'package:household_accounts/v2/domain/models/vo/category_id.dart';
import 'package:household_accounts/v2/domain/models/vo/category_name.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<PersonalIncomeCategoryService>(),
])
import 'income_category_repository_test.mocks.dart';

void main() {
  group('fetchAll', () {
    final MockPersonalIncomeCategoryService mockService = MockPersonalIncomeCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('収入カテゴリ一覧を取得できる', () async {
      final mockModel = data.IncomeCategoryModel(
        id: 'test-category-id',
        name: 'テストカテゴリ',
        type: 'income',
      );

      when(mockService.fetchPersonalIncomeCategories(
        userId,
      )).thenAnswer((_) async => Right([mockModel]));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.fetchAll();
      final categoryList = result.getOrElse(() => []);

      verify(mockService.fetchPersonalIncomeCategories(
        userId,
      )).called(1);

      expect(result.isRight(), isTrue);
      expect(categoryList, hasLength(1));
      expect(categoryList[0].id.value, equals('test-category-id'));
      expect(categoryList[0].name.value, equals('テストカテゴリ'));
    });

    test('カテゴリが存在しない場合、空のリストを返す', () async {
      when(mockService.fetchPersonalIncomeCategories(
        userId,
      )).thenAnswer((_) async => Right([]));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.fetchAll();
      final categoryList = result.getOrElse(() => []);

      expect(result.isRight(), isTrue);
      expect(categoryList, hasLength(0));
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final exception = Exception('test error');
      when(mockService.fetchPersonalIncomeCategories(
        userId,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.fetchAll();

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('add', () {
    final MockPersonalIncomeCategoryService mockService = MockPersonalIncomeCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('収入カテゴリを追加できる', () async {
      final category = IncomeCategoryModel(
        id: CategoryIdVo('test-category-id'),
        name: CategoryNameVo('テストカテゴリ'),
      );

      when(mockService.addPersonalIncomeCategory(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.add(category);

      verify(mockService.addPersonalIncomeCategory(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final category = IncomeCategoryModel(
        id: CategoryIdVo('test-category-id'),
        name: CategoryNameVo('テストカテゴリ'),
      );

      final exception = Exception('test error');
      when(mockService.addPersonalIncomeCategory(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.add(category);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('update', () {
    final MockPersonalIncomeCategoryService mockService = MockPersonalIncomeCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('収入カテゴリを更新できる', () async {
      const categoryId = CategoryIdVo('test-category-id');
      final category = IncomeCategoryModel(
        id: categoryId,
        name: CategoryNameVo('更新されたカテゴリ'),
      );

      when(mockService.updatePersonalIncomeCategory(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.update(categoryId, category);

      verify(mockService.updatePersonalIncomeCategory(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const categoryId = CategoryIdVo('test-category-id');
      final category = IncomeCategoryModel(
        id: categoryId,
        name: CategoryNameVo('更新されたカテゴリ'),
      );

      final exception = Exception('test error');
      when(mockService.updatePersonalIncomeCategory(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.update(categoryId, category);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('delete', () {
    final MockPersonalIncomeCategoryService mockService = MockPersonalIncomeCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('収入カテゴリを削除できる', () async {
      const categoryId = CategoryIdVo('test-category-id');

      when(mockService.deletePersonalIncomeCategory(
        userId,
        categoryId.value,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.delete(categoryId);

      verify(mockService.deletePersonalIncomeCategory(
        userId,
        categoryId.value,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const categoryId = CategoryIdVo('test-category-id');
      final exception = Exception('test error');

      when(mockService.deletePersonalIncomeCategory(
        userId,
        categoryId.value,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreIncomeCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.delete(categoryId);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });
}