import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef RetrieveIncomeCategoriesUseCase
    = UseCase<NoParam, List<IncomeCategory>>;

typedef RetrieveExpenseCategoriesUseCase
    = UseCase<NoParam, List<ExpenseCategory>>;
