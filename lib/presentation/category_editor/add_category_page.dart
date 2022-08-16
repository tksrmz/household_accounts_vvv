import 'package:flutter/material.dart';
import 'package:household_accounts/presentation/category_editor/category_editor2.dart'
    as ce2;
import 'package:household_accounts/entity/category_entity.dart';

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
