import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/domain/repositories/repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

abstract class IncomeCategoryRepository extends Repository<IncomeCategory> {
  /// Retrieves all income categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<Either<Failure, List<IncomeCategory>>> retrieveIncomeCategories();
}

abstract class ExpenseCategoryRepository extends Repository<ExpenseCategory> {
  /// Retrieves all expense categories.
  ///
  /// The list order has no meanings.
  /// Fails if something goes wrong with the repository.
  Future<Either<Failure, List<ExpenseCategory>>> retrieveExpenseCategories();
}
