import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/presentation/category_editor/category_editor2.dart'
    as ce2;

import '../../feature/category_editing/update_expense_category_use_case.dart';
import '../../feature/category_editing/update_income_category_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class EditCategoryPage2 extends StatelessWidget {
  final Category2 _originalData;
  final SingleOrPair _singleOrPair;
  final UserInfo _userInfo;

  const EditCategoryPage2({
    required Category2 originalData,
    required SingleOrPair singleOrPair,
    required UserInfo userInfo,
    Key? key,
  })  : _originalData = originalData,
        _singleOrPair = singleOrPair,
        _userInfo = userInfo,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final int? initialBudget;
    switch (_originalData.type) {
      case CategoryType.income:
        initialBudget = null;
        break;
      case CategoryType.expense:
        initialBudget = (_originalData as ExpenseCategory).totalBudget;
        break;
    }

    final onPressed = (String name, int budget, CategoryType type) {
      _update(name, budget, type);
      Navigator.pop(context);
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: ce2.CategoryEditor(
        onPressed: onPressed,
        mode: ce2.CategoryEditorMode.edit,
        initialCategoryType: _originalData.type,
        initialCategoryName: _originalData.name,
        initialBudget: initialBudget,
      ),
    );
  }

  void _update(String name, int budget, CategoryType type) {
    switch (type) {
      case CategoryType.income:
        _updateIncomeCategory(name);
        break;
      case CategoryType.expense:
        _updateExpenseCategory(name, budget);
        break;
    }
  }

  void _updateIncomeCategory(String name) {
    final input = UpdateIncomeCategoryInput(
      uid: _userInfo.repoId(_singleOrPair),
      categoryId: _originalData.id,
      repository: selectIncomeCategoryRepository(_singleOrPair),
      name: name,
    );
    final update = sl<UpdateIncomeCategoryUseCase>();
    update(input);
  }

  void _updateExpenseCategory(String name, int budget) {
    final input = UpdateExpenseCategoryInput(
      uid: _userInfo.repoId(_singleOrPair),
      categoryId: _originalData.id,
      repository: selectExpenseCategoryRepository(_singleOrPair),
      name: name,
      budget: budget,
    );
    final update = sl<UpdateExpenseCategoryUseCase>();
    update(input);
  }
}
