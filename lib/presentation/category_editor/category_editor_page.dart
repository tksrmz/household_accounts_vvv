import 'package:flutter/material.dart';

import '../../entity/category.dart';

typedef CategoryEditorOnSubmit =
    void Function(String name, int budget, CategoryType categoryType);

class CategoryEditorPage extends StatelessWidget {
  const CategoryEditorPage({
    required String title,
    required CategoryEditorOnSubmit onSubmit,
    String? initialName,
    int? initialBudget,
    CategoryType initialType = CategoryType.income,
    bool canChangeType = true,
    super.key,
  }) : _title = title,
       _onSubmit = onSubmit,
       _initialName = initialName,
       _initialBudget = initialBudget,
       _initialType = initialType,
       _canChangeType = canChangeType;

  final String _title;
  final CategoryEditorOnSubmit _onSubmit;
  final String? _initialName;
  final int? _initialBudget;
  final CategoryType _initialType;
  final bool _canChangeType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
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
    required CategoryEditorOnSubmit onSubmit,
    CategoryType initialType = CategoryType.income,
    String? initialName,
    int? initialBudget,
    bool canChangeType = true,
  }) : _onSubmit = onSubmit,
       _initialType = initialType,
       _initialName = initialName,
       _initialBudget = initialBudget,
       _canChangeType = canChangeType;

  final CategoryEditorOnSubmit _onSubmit;
  final String? _initialName;
  final int? _initialBudget;
  final CategoryType _initialType;
  final bool _canChangeType;

  @override
  _PageBodyState createState() => _PageBodyState();
}

class _PageBodyState extends State<_PageBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;

  // state
  final List<bool> _categorySelection = [false, false];

  bool get _isExpenseSelected => _categorySelection[1];

  @override
  void initState() {
    super.initState();
    switch (widget._initialType) {
      case CategoryType.income:
        _categorySelection[0] = true;
        break;

      case CategoryType.expense:
        _categorySelection[1] = true;
        break;
    }
    _nameController = TextEditingController(text: widget._initialName);
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

    // Use callback that does nothing when this widget is not allowed to change
    // category type. I will not use null here, because it causes for the
    // buttons to gray out. Graying out is not appropriate as it becomes
    // difficult for the users to know which type of category they are
    // editing: income category type or expense category type.
    final toggleButtonsOnPressed = widget._canChangeType
        ? _setSelected
        : (_) {};
    children.add(
      LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ToggleButtons(
            isSelected: _categorySelection,
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth / _categorySelection.length - 10,
              minHeight: 48.0,
            ),
            onPressed: toggleButtonsOnPressed,
            children: const [Text('収入'), Text('支出')],
          ),
        ),
      ),
    );

    children.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'カテゴリ名',
            helperText: '1文字以上${CategoryBase.maxNameLength}文字以下',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          autofocus: true,
          maxLength: CategoryBase.maxNameLength,
          textInputAction: TextInputAction.next,
        ),
      ),
    );

    if (_isExpenseSelected) {
      children.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _budgetController,
            decoration: InputDecoration(
              labelText: '予算',
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
          if (budget == null && _isExpenseSelected) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: const Text('予算の入力が正しくありません')));
          } else {
            widget._onSubmit(
              _nameController.text,
              budget ?? 0,
              _isExpenseSelected ? CategoryType.expense : CategoryType.income,
            );
          }
        },
        child: const Text('登録'),
      ),
    );

    return ListView(children: children);
  }

  void _setSelected(int index) {
    if (widget._canChangeType) {
      _budgetController.text = widget._initialBudget == null
          ? ''
          : widget._initialBudget.toString();
      setState(() {
        for (
          int buttonIndex = 0;
          buttonIndex < _categorySelection.length;
          buttonIndex++
        ) {
          if (buttonIndex == index) {
            _categorySelection[buttonIndex] = true;
          } else {
            _categorySelection[buttonIndex] = false;
          }
        }
      });
    }
  }
}
