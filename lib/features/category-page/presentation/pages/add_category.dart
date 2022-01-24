import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_list.dart';
import 'package:household_accounts/features/category-page/presentation/widgets/category_editor.dart';

class AddCategoryPage extends StatelessWidget {
  final CategoryListState _state;

  const AddCategoryPage({
    required CategoryListState state,
    Key? key,
  })  : _state = state,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new category'),
      ),
      body: CategoryEditor(
        onPressed: (nameController, budgetController, type) {
          _state.addCategory(nameController.text, type, budgetController.text);
        },
        buttonChild: const Text('Add'),
        mode: CategoryEditorMode.add,
      ),
    );
  }
}
