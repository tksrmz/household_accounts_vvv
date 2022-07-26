import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_page.dart';
import 'package:household_accounts/features/category-page/presentation/widgets/category_editor.dart';
import 'package:household_accounts/features/category-page/presentation/widgets/category_editor2.dart'
    as ce2;
import 'package:household_accounts/util/domain/entities/category.dart';

class AddCategoryPage extends StatelessWidget {
  const AddCategoryPage({
    Key? key,
    required IncomeCategoryListState incomeCategoryListState,
  })  : _incomeCategoryListState = incomeCategoryListState,
        super(key: key);

  final IncomeCategoryListState _incomeCategoryListState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new category'),
      ),
      body: CategoryEditor(
        onPressed: (nameController, budgetController, type) {
          switch (type) {
            case CategoryType.income:
              _incomeCategoryListState.addCategory(
                nameController.text,
              );
              break;
            case CategoryType.expense:
              // TODO: Handle this case.
              break;
          }
        },
        buttonChild: const Text('Add'),
        mode: CategoryEditorMode.add,
      ),
    );
  }
}

class AddCategoryPage2 extends StatelessWidget {
  const AddCategoryPage2({
    Key? key,
    required ce2.CategoryPropertiesHandler onSubmit,
  })  : _onSubmit = onSubmit,
        super(key: key);

  final ce2.CategoryPropertiesHandler _onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new category'),
      ),
      body: ce2.CategoryEditor(
        onPressed: _onSubmit,
        mode: ce2.CategoryEditorMode.add,
        initialCategoryType: CategoryType.income,
      ),
    );
  }
}
