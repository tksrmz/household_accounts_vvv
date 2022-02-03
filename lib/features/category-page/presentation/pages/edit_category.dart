import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_page.dart';
import 'package:household_accounts/features/category-page/presentation/widgets/category_editor.dart';

class EditCategoryPage extends StatelessWidget {
  final CategoryPageState _state;
  final String _targetCategoryId;

  const EditCategoryPage({
    required CategoryPageState state,
    required String categoryId,
    Key? key,
  })  : _state = state,
        _targetCategoryId = categoryId,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: CategoryEditor(
        onPressed: (nameController, budgetController, _) {
          _state.updateCategory(
            _targetCategoryId,
            nameController.text,
            budgetController.text,
          );
        },
        buttonChild: const Text('Edit'),
        mode: CategoryEditorMode.edit,
      ),
    );
  }
}
