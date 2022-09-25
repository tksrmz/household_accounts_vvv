import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef RetrieveIncomeCategoriesUseCase = UseCase2<Unit, List<IncomeCategory>>;

typedef RetrieveExpenseCategoriesUseCase
    = UseCase2<Unit, List<ExpenseCategory>>;
