import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/feature/category_register/category_register_use_case.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';
import 'package:household_accounts/util/uuid/uuid.dart';

import '../../util/type/exception_or.dart';

class AddCategoryInteractor2 extends AddCategoryUseCase2 {
  final IncomeCategoryRepository _incomeCategoryRepository;
  final ExpenseCategoryRepository _expenseCategoryRepository;

  AddCategoryInteractor2(
    this._incomeCategoryRepository,
    this._expenseCategoryRepository,
  );

  @override
  Future<ExceptionOr<Unit>> call(AddCategoryInput2 input) {
    switch (input.type) {
      case CategoryType.income:
        return _incomeCategoryRepository.register(
          IncomeCategory(
            id: UUID.generate(),
            name: input.name,
          ),
        );

      case CategoryType.expense:
        return _expenseCategoryRepository.register(
          ExpenseCategory(
            id: UUID.generate(),
            name: input.name,
            totalBudget: input.budgetAmount,
          ),
        );
    }
  }
}
