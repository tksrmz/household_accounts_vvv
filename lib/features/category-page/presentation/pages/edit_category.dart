import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_list.dart';
import 'package:household_accounts/features/category-page/presentation/widgets/category_editor.dart';

class EditCategoryPage extends StatelessWidget {
  final CategoryListState _state;
  final String _targetCategoryId;

  const EditCategoryPage({
    required CategoryListState state,
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
        onPressed: (controller, _) {
          _state.updateCategory(_targetCategoryId, controller.text);
        },
        buttonChild: const Text('Edit'),
      ),
    );
  }
}
