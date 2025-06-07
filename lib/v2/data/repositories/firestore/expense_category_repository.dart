import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart';

import '../../../domain/models/expense_category.dart';
import '../../../domain/models/vo/budget_amount.dart';
import '../../../domain/models/vo/category_id.dart';
import '../../../domain/models/vo/category_name.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/repositories/expense_category_repository.dart';

class FirestoreExpenseCategoryRepository implements ExpenseCategoryRepository {
  const FirestoreExpenseCategoryRepository(
    this._firestoreService,
    this._uid,
  );

  final FirestoreService _firestoreService;
  final UserIdVo _uid;

  @override
  Future<Either<Exception, List<ExpenseCategoryVo>>> fetchAll() async {
    final result = await _firestoreService.fetchPersonalExpenseCategories(_uid);
    return result.map((categoryModels) => 
      categoryModels.map((model) => ExpenseCategoryVo(
        id: CategoryIdVo(model.id),
        name: CategoryNameVo(model.name),
        totalBudget: BudgetAmountVo(model.totalBudget),
      )).toList(growable: false)
    );
  }

  @override
  Future<Either<Exception, Unit>> add(ExpenseCategoryVo category) async {
    final model = ExpenseCategoryModel(
      id: category.id.value,
      name: category.name.value,
      totalBudget: category.totalBudget.value,
    );
    return _firestoreService.addPersonalExpenseCategory(_uid, model);
  }

  @override
  Future<Either<Exception, Unit>> update(CategoryIdVo id, ExpenseCategoryVo category) async {
    final model = ExpenseCategoryModel(
      id: category.id.value,
      name: category.name.value,
      totalBudget: category.totalBudget.value,
    );
    return _firestoreService.updatePersonalExpenseCategory(_uid, id.value, model);
  }

  @override
  Future<Either<Exception, Unit>> delete(CategoryIdVo id) async {
    return _firestoreService.deletePersonalExpenseCategory(_uid, id.value);
  }
}