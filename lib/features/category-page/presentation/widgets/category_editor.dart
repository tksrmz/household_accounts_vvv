import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';

typedef CategoryNameAndTypeHandler = void Function(
    TextEditingController, CategoryType);

enum CategoryEditorMode {
  add,
  edit,
}

class CategoryEditor extends StatefulWidget {
  final CategoryNameAndTypeHandler _onPressed;
  final Widget _buttonChild;
  final CategoryEditorMode _mode;

  const CategoryEditor({
    required CategoryNameAndTypeHandler onPressed,
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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      TextField(
        controller: _controller,
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

    children.add(
      ElevatedButton(
        onPressed: () {
          widget._onPressed(_controller, _selected!);
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
