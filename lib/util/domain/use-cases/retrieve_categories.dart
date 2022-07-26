import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/use_case.dart';

typedef RetrieveIncomeCategoriesUseCase
    = UseCase<NoParam, List<IncomeCategory>>;

typedef RetrieveExpenseCategoriesUseCase
    = UseCase<NoParam, List<ExpenseCategory>>;
