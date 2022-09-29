import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/util/type/repository.dart';

import '../../util/type/exception_or.dart';

@deprecated
abstract class IncomeCategoryRepository extends Repository<IncomeCategory> {
  /// Retrieves all income categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<ExceptionOr<List<IncomeCategory>>> retrieveAll();
}

@deprecated
abstract class ExpenseCategoryRepository extends Repository<ExpenseCategory> {
  /// Retrieves all expense categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<ExceptionOr<List<ExpenseCategory>>> retrieveAll();
}

typedef IncomeCategoryRepository2 = Repository2<IncomeCategory>;
typedef ExpenseCategoryRepository2 = Repository2<ExpenseCategory>;
