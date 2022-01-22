import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';

typedef CategoryNameAndTypeHandler = void Function(
    TextEditingController, CategoryType);

class CategoryEditor extends StatefulWidget {
  final CategoryNameAndTypeHandler _onPressed;
  final Widget _buttonChild;

  const CategoryEditor({
    required CategoryNameAndTypeHandler onPressed,
    required Widget buttonChild,
    Key? key,
  })  : _onPressed = onPressed,
        _buttonChild = buttonChild,
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
    final onChanged = (CategoryType? value) {
      setState(() {
        _selected = value;
      });
    };

    return Column(
      children: <Widget>[
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
        RadioListTile<CategoryType>(
          title: const Text('Income'),
          value: CategoryType.income,
          groupValue: _selected,
          onChanged: onChanged,
        ),
        RadioListTile<CategoryType>(
          title: const Text('Expense'),
          value: CategoryType.expense,
          groupValue: _selected,
          onChanged: onChanged,
        ),
        ElevatedButton(
          onPressed: () {
            widget._onPressed(_controller, _selected!);
            Navigator.pop(context);
          },
          child: widget._buttonChild,
        ),
      ],
    );
  }
}
