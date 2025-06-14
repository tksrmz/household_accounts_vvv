import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_category_service.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart' as data;

import '../../../domain/models/expense_category.dart';
import '../../../domain/models/vo/budget_amount.dart';
import '../../../domain/models/vo/category_id.dart';
import '../../../domain/models/vo/category_name.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_category_repository.dart';

class FirestoreExpenseCategoryRepository implements ExpenseCategoryRepository {
  const FirestoreExpenseCategoryRepository(
    this._personalExpenseCategoryService,
    this._uid,
  );

  final PersonalExpenseCategoryService _personalExpenseCategoryService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<ExpenseCategoryModel>>> fetchAll() async {
    final result = await _personalExpenseCategoryService.fetchPersonalExpenseCategories(_uid);
    return result.map((categoryModels) => 
      categoryModels.map((model) => ExpenseCategoryModel(
        id: CategoryIdVo(model.id),
        name: CategoryNameVo(model.name),
        totalBudget: BudgetAmountVo(model.totalBudget),
      )).toList(growable: false)
    );
  }

  @override
  Future<Either<Exception, Unit>> add(ExpenseCategoryModel category) async {
    final model = data.ExpenseCategoryModel(
      id: category.id.value,
      name: category.name.value,
      totalBudget: category.totalBudget.value,
    );
    return _personalExpenseCategoryService.addPersonalExpenseCategory(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> update(CategoryIdVo id, ExpenseCategoryModel category) async {
    final model = data.ExpenseCategoryModel(
      id: category.id.value,
      name: category.name.value,
      totalBudget: category.totalBudget.value,
    );
    return _personalExpenseCategoryService.updatePersonalExpenseCategory(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(CategoryIdVo id) async {
    return _personalExpenseCategoryService.deletePersonalExpenseCategory(_uid, id.value);
  }
}