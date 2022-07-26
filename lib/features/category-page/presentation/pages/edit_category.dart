import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/presentation/widgets/category_editor2.dart'
    as ce2;
import 'package:household_accounts/util/domain/entities/category.dart';

class EditCategoryPage2 extends StatelessWidget {
  const EditCategoryPage2({
    Key? key,
    required ce2.CategoryPropertiesHandler onSubmit,
    required Category2 originalData,
  })  : _onSubmit = onSubmit,
        _originalData = originalData,
        super(key: key);

  final ce2.CategoryPropertiesHandler _onSubmit;
  final Category2 _originalData;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: ce2.CategoryEditor(
        onPressed: _onSubmit,
        mode: ce2.CategoryEditorMode.edit,
        initialCategoryType: _originalData.type,
        initialCategoryName: _originalData.name,
        initialBudget: initialBudget,
      ),
    );
  }
}
