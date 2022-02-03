import 'package:flutter/material.dart';
import 'package:household_accounts/util/domain/entities/category.dart';

typedef CategoryPropertiesHandler = void Function(
  TextEditingController nameContrller,
  TextEditingController budgetController,
  CategoryType categoryType,
);

enum CategoryEditorMode {
  add,
  edit,
}

class CategoryEditor extends StatefulWidget {
  final CategoryPropertiesHandler _onPressed;
  final Widget _buttonChild;
  final CategoryEditorMode _mode;

  const CategoryEditor({
    required CategoryPropertiesHandler onPressed,
    required Widget buttonChild,
    required CategoryEditorMode mode,
    Key? key,
  })  : _onPressed = onPressed,
        _buttonChild = buttonChild,
        _mode = mode,
        super(key: key);

  @override
  _CategoryEditorState createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  // This property is nullable only because RadioListTile.onChanged receives nullable value.
  CategoryType? _selected = CategoryType.income;
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _budgetController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Category name',
          helperText: '1-20 alphabet characters only',
          counterText: '0 characters',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.text,
        autofocus: true,
        maxLength: Category.maxNameLength,
      ),
    ];

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

    children.add(TextField(
      controller: _budgetController,
      decoration: InputDecoration(
        labelText: 'Budget',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    ));

    children.add(
      ElevatedButton(
        onPressed: () {
          widget._onPressed(_nameController, _budgetController, _selected!);
          Navigator.pop(context);
        },
        child: widget._buttonChild,
      ),
    );

    return Column(
      children: children,
    );
  }
}
