import 'dart:async';

import 'package:household_accounts/data/repositories/category/category_repository.dart';
import 'package:household_accounts/domain/models/category.dart';

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
}
