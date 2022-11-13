import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';

typedef CategoryEditorOnSubmit = void Function(
  String name,
  int budget,
  CategoryType categoryType,
);

class CategoryEditorPage extends StatelessWidget {
  const CategoryEditorPage({
    required String title,
    required CategoryEditorOnSubmit onSubmit,
    String? initialName,
    int? initialBudget,
    CategoryType initialType = CategoryType.income,
    bool canChangeType = true,
    Key? key,
  })  : _title = title,
        _onSubmit = onSubmit,
        _initialName = initialName,
        _initialBudget = initialBudget,
        _initialType = initialType,
        _canChangeType = canChangeType,
        super(key: key);

  final String _title;
  final CategoryEditorOnSubmit _onSubmit;
  final String? _initialName;
  final int? _initialBudget;
  final CategoryType _initialType;
  final bool _canChangeType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _PageBody(
        onSubmit: _onSubmit,
        initialName: _initialName,
        initialBudget: _initialBudget,
        initialType: _initialType,
        canChangeType: _canChangeType,
      ),
    );
  }
}

class _PageBody extends StatefulWidget {
  const _PageBody({
    Key? key,
    required CategoryEditorOnSubmit onSubmit,
    CategoryType initialType = CategoryType.income,
    String? initialName,
    int? initialBudget,
    bool canChangeType = true,
  })  : _onSubmit = onSubmit,
        _initialType = initialType,
        _initialName = initialName,
        _initialBudget = initialBudget,
        _canChangeType = canChangeType,
        super(key: key);

  final CategoryEditorOnSubmit _onSubmit;
  final String? _initialName;
  final int? _initialBudget;
  final CategoryType _initialType;
  final bool _canChangeType;

  @override
  _PageBodyState createState() => _PageBodyState();
}

class _PageBodyState extends State<_PageBody> {
  // This property is nullable only because RadioListTile.onChanged
  // receives nullable value.
  late CategoryType? _selected;
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _selected = widget._initialType;
    _nameController = TextEditingController(
      text: widget._initialName,
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

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    // Add radio buttons to select category.
    final radioButtonOnChanged = widget._canChangeType ? _setSelected : null;
    children.add(
      RadioListTile<CategoryType>(
        title: const Text('Income'),
        value: CategoryType.income,
        groupValue: _selected,
        onChanged: radioButtonOnChanged,
      ),
    );
    children.add(
      RadioListTile<CategoryType>(
        title: const Text('Expense'),
        value: CategoryType.expense,
        groupValue: _selected,
        onChanged: radioButtonOnChanged,
      ),
    );

    children.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Category name',
            helperText: '1-${Category2.maxNameLength} characters only',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          autofocus: true,
          maxLength: Category2.maxNameLength,
          textInputAction: TextInputAction.next,
        ),
      ),
    );

    if (_selected == CategoryType.expense) {
      children.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _budgetController,
            decoration: InputDecoration(
              labelText: 'Budget',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
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
            widget._onSubmit(
              _nameController.text,
              budget ?? 0,
              _selected!,
            );
          }
        },
        child: const Text('Submit'),
      ),
    );

    return ListView(
      children: children,
    );
  }

  void _setSelected(CategoryType? value) {
    if (widget._canChangeType) {
      _budgetController.text =
          widget._initialBudget == null ? '' : widget._initialBudget.toString();
      setState(() {
        _selected = value;
      });
    }
  }
}
