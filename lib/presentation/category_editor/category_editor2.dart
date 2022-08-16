import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';

typedef CategoryPropertiesHandler = void Function(
  String name,
  int budget,
  CategoryType categoryType,
);

enum CategoryEditorMode {
  add,
  edit,
}

class CategoryEditor extends StatefulWidget {
  const CategoryEditor({
    Key? key,
    required CategoryPropertiesHandler onPressed,
    required CategoryEditorMode mode,
    required CategoryType initialCategoryType,
    String initialCategoryName = '',
    int? initialBudget,
  })  : _onPressed = onPressed,
        _mode = mode,
        _initialCategoryType = initialCategoryType,
        _initialCategoryName = initialCategoryName,
        _initialBudget = initialBudget,
        super(key: key);

  final CategoryPropertiesHandler _onPressed;
  final CategoryEditorMode _mode;
  final String _initialCategoryName;
  final int? _initialBudget;
  final CategoryType _initialCategoryType;

  @override
  _CategoryEditorState createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  // This property is nullable only because RadioListTile.onChanged receives nullable value.
  late CategoryType? _selected;
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _selected = widget._initialCategoryType;
    _nameController = TextEditingController(
      text: widget._initialCategoryName,
    );
    _budgetController = TextEditingController(
      text: widget._initialBudget?.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Widget _selectElevatedButtonChild(CategoryEditorMode mode) {
    final child;
    switch (mode) {
      case CategoryEditorMode.add:
        child = const Text('Add');
        break;
      case CategoryEditorMode.edit:
        child = const Text('Edit');
        break;
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    children.add(
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Category name',
          helperText: '1-20 characters only',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.text,
        autofocus: true,
        maxLength: Category2.maxNameLength,
      ),
    );

    switch (widget._mode) {
      case CategoryEditorMode.add:
        // Add radio buttons to select category.
        final onChanged = (CategoryType? value) {
          setState(() {
            _selected = value;
          });
        };
        children.add(
          RadioListTile<CategoryType>(
            title: const Text('Income'),
            value: CategoryType.income,
            groupValue: _selected,
            onChanged: onChanged,
          ),
        );
        children.add(
          RadioListTile<CategoryType>(
            title: const Text('Expense'),
            value: CategoryType.expense,
            groupValue: _selected,
            onChanged: onChanged,
          ),
        );
        break;
      case CategoryEditorMode.edit:
        // Changing category type by editing is not supported.
        break;
    }

    if (_selected == CategoryType.expense) {
      children.add(
        TextField(
          controller: _budgetController,
          decoration: InputDecoration(
            labelText: 'Budget',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      );
    }

    children.add(
      ElevatedButton(
        onPressed: () {
          final int? budget = int.tryParse(_budgetController.text);
          if (budget == null && _selected == CategoryType.expense) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Invalid budget input.'),
              ),
            );
          } else {
            widget._onPressed(
              _nameController.text,
              budget ?? 0,
              _selected!,
            );
          }
        },
        child: _selectElevatedButtonChild(widget._mode),
      ),
    );

    return Column(
      children: children,
    );
  }
}
