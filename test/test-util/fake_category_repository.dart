import 'dart:async';

import 'package:household_accounts/data/repositories/category/category_repository.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/utils/result.dart';

/// Resultを返すinterfaceはmockitoでモック生成できないため手書きFakeを共用する
class FakeCategoryRepository implements CategoryRepository {
  /// [watchIncomeCategories]が返すストリーム。テストから任意のイベント
  /// (カテゴリの一覧・エラー)を流せる。
  final StreamController<List<IncomeCategory>> incomeCategoriesController =
      StreamController<List<IncomeCategory>>.broadcast();

  /// [watchExpenseCategories]が返すストリーム。テストから任意のイベント
  /// (カテゴリの一覧・エラー)を流せる。
  final StreamController<List<ExpenseCategory>> expenseCategoriesController =
      StreamController<List<ExpenseCategory>>.broadcast();

  int watchIncomeCategoriesCallCount = 0;

  int watchExpenseCategoriesCallCount = 0;

  /// [addIncomeCategory]が返す結果。テストから差し替えて失敗を再現できる。
  Result<void> addIncomeCategoryResult = const Result.ok(null);

  /// [addExpenseCategory]が返す結果。
  Result<void> addExpenseCategoryResult = const Result.ok(null);

  /// [updateIncomeCategory]が返す結果。
  Result<void> updateIncomeCategoryResult = const Result.ok(null);

  /// [updateExpenseCategory]が返す結果。
  Result<void> updateExpenseCategoryResult = const Result.ok(null);

  /// [deleteIncomeCategory]が返す結果。
  Result<void> deleteIncomeCategoryResult = const Result.ok(null);

  /// [deleteExpenseCategory]が返す結果。
  Result<void> deleteExpenseCategoryResult = const Result.ok(null);

  /// [addIncomeCategory]の呼び出し引数の記録。
  final List<CategoryName> addIncomeCategoryCalls = [];

  /// [addExpenseCategory]の呼び出し引数の記録。
  final List<({CategoryName name, Budget budget})> addExpenseCategoryCalls = [];

  /// [updateIncomeCategory]の呼び出し引数の記録。
  final List<({CategoryId id, CategoryName name})> updateIncomeCategoryCalls =
      [];

  /// [updateExpenseCategory]の呼び出し引数の記録。
  final List<({CategoryId id, CategoryName? name, Budget? budget})>
  updateExpenseCategoryCalls = [];

  /// [deleteIncomeCategory]の呼び出し引数の記録。
  final List<CategoryId> deleteIncomeCategoryCalls = [];

  /// [deleteExpenseCategory]の呼び出し引数の記録。
  final List<CategoryId> deleteExpenseCategoryCalls = [];

  @override
  Stream<List<IncomeCategory>> watchIncomeCategories() {
    watchIncomeCategoriesCallCount++;
    return incomeCategoriesController.stream;
  }

  @override
  Stream<List<ExpenseCategory>> watchExpenseCategories() {
    watchExpenseCategoriesCallCount++;
    return expenseCategoriesController.stream;
  }

  @override
  Future<Result<void>> addIncomeCategory(CategoryName name) async {
    addIncomeCategoryCalls.add(name);
    return addIncomeCategoryResult;
  }

  @override
  Future<Result<void>> addExpenseCategory({
    required CategoryName name,
    required Budget budget,
  }) async {
    addExpenseCategoryCalls.add((name: name, budget: budget));
    return addExpenseCategoryResult;
  }

  @override
  Future<Result<void>> updateIncomeCategory(
    CategoryId id, {
    required CategoryName name,
  }) async {
    updateIncomeCategoryCalls.add((id: id, name: name));
    return updateIncomeCategoryResult;
  }

  @override
  Future<Result<void>> updateExpenseCategory(
    CategoryId id, {
    CategoryName? name,
    Budget? budget,
  }) async {
    updateExpenseCategoryCalls.add((id: id, name: name, budget: budget));
    return updateExpenseCategoryResult;
  }

  @override
  Future<Result<void>> deleteIncomeCategory(CategoryId id) async {
    deleteIncomeCategoryCalls.add(id);
    return deleteIncomeCategoryResult;
  }

  @override
  Future<Result<void>> deleteExpenseCategory(CategoryId id) async {
    deleteExpenseCategoryCalls.add(id);
    return deleteExpenseCategoryResult;
  }
}
