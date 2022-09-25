import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/util/type/repository.dart';

import '../../util/type/exception_or.dart';

abstract class IncomeCategoryRepository extends Repository2<IncomeCategory> {
  /// Retrieves all income categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<ExceptionOr<List<IncomeCategory>>> retrieveIncomeCategories();
}

abstract class ExpenseCategoryRepository extends Repository2<ExpenseCategory> {
  /// Retrieves all expense categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<ExceptionOr<List<ExpenseCategory>>> retrieveExpenseCategories();
}
