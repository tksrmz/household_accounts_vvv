import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/expense_category_repository.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_category_service.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart'
    as data;
import 'package:household_accounts/v2/domain/models/expense_category.dart';
import 'package:household_accounts/v2/domain/models/vo/budget_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/category_id.dart';
import 'package:household_accounts/v2/domain/models/vo/category_name.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<PersonalExpenseCategoryService>(),
])
import 'expense_category_repository_test.mocks.dart';

void main() {
  group('fetchAll', () {
    final MockPersonalExpenseCategoryService mockService =
        MockPersonalExpenseCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('支出カテゴリ一覧を取得できる', () async {
      final mockModel = data.ExpenseCategoryModel(
        id: 'test-category-id',
        name: 'テストカテゴリ',
        type: 'expense',
        totalBudget: 50000,
      );

      when(mockService.fetchAll(
        userId,
      )).thenAnswer((_) async => Right([mockModel]));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.fetchAll();
      final categoryList = result.getOrElse(() => []);

      verify(mockService.fetchAll(
        userId,
      )).called(1);

      expect(result.isRight(), isTrue);
      expect(categoryList, hasLength(1));
      expect(categoryList[0].id.value, equals('test-category-id'));
      expect(categoryList[0].name.value, equals('テストカテゴリ'));
      expect(categoryList[0].totalBudget.value, equals(50000));
    });

    test('カテゴリが存在しない場合、空のリストを返す', () async {
      when(mockService.fetchAll(
        userId,
      )).thenAnswer((_) async => Right([]));

      final target = FirestoreExpenseCategoryRepository(
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
      when(mockService.fetchAll(
        userId,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.fetchAll();

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('add', () {
    final MockPersonalExpenseCategoryService mockService =
        MockPersonalExpenseCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('支出カテゴリを追加できる', () async {
      final category = ExpenseCategoryModel(
        id: CategoryIdVo('test-category-id'),
        name: CategoryNameVo('テストカテゴリ'),
        totalBudget: BudgetAmountVo(50000),
      );

      when(mockService.add(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.add(category);

      verify(mockService.add(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final category = ExpenseCategoryModel(
        id: CategoryIdVo('test-category-id'),
        name: CategoryNameVo('テストカテゴリ'),
        totalBudget: BudgetAmountVo(50000),
      );

      final exception = Exception('test error');
      when(mockService.add(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.add(category);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('update', () {
    final MockPersonalExpenseCategoryService mockService =
        MockPersonalExpenseCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('支出カテゴリを更新できる', () async {
      const categoryId = CategoryIdVo('test-category-id');
      final category = ExpenseCategoryModel(
        id: categoryId,
        name: CategoryNameVo('更新されたカテゴリ'),
        totalBudget: BudgetAmountVo(75000),
      );

      when(mockService.update(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.update(categoryId, category);

      verify(mockService.update(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const categoryId = CategoryIdVo('test-category-id');
      final category = ExpenseCategoryModel(
        id: categoryId,
        name: CategoryNameVo('更新されたカテゴリ'),
        totalBudget: BudgetAmountVo(75000),
      );

      final exception = Exception('test error');
      when(mockService.update(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.update(categoryId, category);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('delete', () {
    final MockPersonalExpenseCategoryService mockService =
        MockPersonalExpenseCategoryService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('支出カテゴリを削除できる', () async {
      const categoryId = CategoryIdVo('test-category-id');

      when(mockService.delete(
        userId,
        categoryId.value,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.delete(categoryId);

      verify(mockService.delete(
        userId,
        categoryId.value,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const categoryId = CategoryIdVo('test-category-id');
      final exception = Exception('test error');

      when(mockService.delete(
        userId,
        categoryId.value,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreExpenseCategoryRepository(
        mockService,
        userId,
      );
      final result = await target.delete(categoryId);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });
}
