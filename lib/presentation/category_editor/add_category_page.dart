import 'package:flutter/material.dart';
import 'package:household_accounts/presentation/category_editor/category_editor2.dart'
    as ce2;
import 'package:household_accounts/entity/category_entity.dart';

import '../../feature/category_register/add_expense_category_use_case.dart';
import '../../feature/category_register/add_income_category_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class AddCategoryPage2 extends StatelessWidget {
  final SingleOrPair _singleOrPair;
  final UserInfo _userInfo;

  const AddCategoryPage2({
    required SingleOrPair singleOrPair,
    required UserInfo userInfo,
    Key? key,
  })  : _singleOrPair = singleOrPair,
        _userInfo = userInfo,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final onPressed = (String name, int budget, CategoryType type) {
      _submit(name, budget, type);
      Navigator.pop(context);
    };
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new category'),
      ),
      body: ce2.CategoryEditor(
        onPressed: onPressed,
        mode: ce2.CategoryEditorMode.add,
        initialCategoryType: CategoryType.income,
      ),
    );
  }

  void _submit(String name, int budget, CategoryType type) {
    switch (type) {
      case CategoryType.income:
        _submitIncomeCategory(name);
        break;

      case CategoryType.expense:
        _submitExpenseCategory(name, budget);
        break;
    }
  }

  void _submitIncomeCategory(String name) {
    final input = AddIncomeCategoryInput(
      uid: _userInfo.repoId(_singleOrPair),
      name: name,
      repository: selectIncomeCategoryRepository(_singleOrPair),
    );
    final register = sl<AddIncomeCategoryUseCase>();
    register(input);
  }

  void _submitExpenseCategory(String name, int budget) {
    final input = AddExpenseCategoryInput(
      uid: _userInfo.repoId(_singleOrPair),
      name: name,
      repository: selectExpenseCategoryRepository(_singleOrPair),
      budget: budget,
    );
    final register = sl<AddExpenseCategoryUseCase>();
    register(input);
  }
}
