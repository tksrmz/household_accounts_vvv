import '../../entity/category_entity.dart';
import '../../util/type/repository.dart';

abstract class PersonalIncomeCategoryRepository
    extends Repository<IncomeCategory> {}

abstract class SharedIncomeCategoryRepository
    extends Repository<IncomeCategory> {}

abstract class PersonalExpenseCategoryRepository
    extends Repository<ExpenseCategory> {}

abstract class SharedExpenseCategoryRepository
    extends Repository<ExpenseCategory> {}
