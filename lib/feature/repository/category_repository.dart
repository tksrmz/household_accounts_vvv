import '../../entity/category_entity.dart';
import '../../util/type/repository.dart';

abstract class PersonalIncomeCategoryRepository
    extends Repository2<IncomeCategory> {}

abstract class SharedIncomeCategoryRepository
    extends Repository2<IncomeCategory> {}

abstract class PersonalExpenseCategoryRepository
    extends Repository2<ExpenseCategory> {}

abstract class SharedExpenseCategoryRepository
    extends Repository2<ExpenseCategory> {}
