import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_list.dart';

class AddCategoryPage extends StatelessWidget {
  final CategoryListState _state;

  const AddCategoryPage({
    required CategoryListState state,
    Key? key,
  })  : _state = state,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: mock
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new category'),
      ),
      body: _CategoryEditor(
        onPressed: (controller, type) {
          _state.addCategory(controller.text, type);
        },
      ),
    );
  }
}

typedef CategoryNameAndTypeHandler = void Function(
    TextEditingController, CategoryType);

class _CategoryEditor extends StatefulWidget {
  final CategoryNameAndTypeHandler _onPressed;

  const _CategoryEditor({
    required CategoryNameAndTypeHandler onPressed,
    Key? key,
  })  : _onPressed = onPressed,
        super(key: key);

  @override
  _CategoryEditorState createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}
