import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/util/use_case.dart';

@deprecated
typedef RetrieveCategoriesUseCase = UseCase<NoParam, List<Category>>;

typedef RetrieveIncomeCategoriesUseCase
    = UseCase<NoParam, List<IncomeCategory>>;

typedef RetrieveExpenseCategoriesUseCase
    = UseCase<NoParam, List<ExpenseCategory>>;
